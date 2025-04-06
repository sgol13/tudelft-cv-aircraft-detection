import cv2
import os
import numpy as np
from ultralytics import YOLO
from tqdm import tqdm
from collections import deque

# Import specific methods from the existing scripts
from display_video import (
    apply_orientation,
    resize_for_inference,
    rescale_detections,
    draw_predictions
)

from adsb_overlay import (
    load_adsb_data,
    draw_aircraft_overlay
)

def draw_rounded_rectangle(img, x1, y1, x2, y2, color, thickness=-1, radius=10, alpha=1.0):
    """
    Draw a rounded rectangle on an image with optional transparency.
    
    Args:
        img: Image to draw on
        x1, y1: Top-left corner
        x2, y2: Bottom-right corner
        color: Rectangle color (BGR)
        thickness: Line thickness (-1 for filled)
        radius: Corner radius
        alpha: Opacity (0.0-1.0)
        
    Returns:
        None (modifies img in-place)
    """
    # Create a separate canvas for the rectangle
    if alpha < 1.0:
        overlay = img.copy()
    
    # Draw the main rectangle
    cv2.rectangle(
        overlay if alpha < 1.0 else img,
        (x1 + radius, y1),
        (x2 - radius, y2),
        color, thickness)
    cv2.rectangle(
        overlay if alpha < 1.0 else img,
        (x1, y1 + radius),
        (x2, y2 - radius),
        color, thickness)
    
    # Draw the four corner circles
    cv2.circle(
        overlay if alpha < 1.0 else img,
        (x1 + radius, y1 + radius),
        radius, color, thickness)
    cv2.circle(
        overlay if alpha < 1.0 else img,
        (x2 - radius, y1 + radius),
        radius, color, thickness)
    cv2.circle(
        overlay if alpha < 1.0 else img,
        (x1 + radius, y2 - radius),
        radius, color, thickness)
    cv2.circle(
        overlay if alpha < 1.0 else img,
        (x2 - radius, y2 - radius),
        radius, color, thickness)
    
    # Apply transparency if needed
    if alpha < 1.0:
        cv2.addWeighted(overlay, alpha, img, 1 - alpha, 0, img)

def calculate_distance(point1, point2):
    """
    Calculate Euclidean distance between two points.
    
    Args:
        point1: Tuple or list (x, y)
        point2: Tuple or list (x, y)
        
    Returns:
        float: Euclidean distance
    """
    return np.sqrt((point1[0] - point2[0])**2 + (point1[1] - point2[1])**2)

def find_closest_adsb_aircraft(detection_center, aircraft_data, frame_width, frame_height):
    """
    Find the closest ADS-B aircraft to a detection center point.
    
    Args:
        detection_center: Tuple (x, y) center point of detection
        aircraft_data: List of aircraft information dictionaries
        frame_width: Width of the frame
        frame_height: Height of the frame
        
    Returns:
        tuple: (closest aircraft dict, distance) or (None, float('inf')) if no match
    """
    closest_aircraft = None
    min_distance = float('inf')
    
    # Normalize detection center
    norm_detection_x = detection_center[0] / frame_width
    norm_detection_y = detection_center[1] / frame_height
    
    for aircraft in aircraft_data:
        # Get normalized coordinates from ADS-B data
        adsb_x = aircraft['pos']['x']
        adsb_y = 1 - aircraft['pos']['y']  # Invert y-axis as in draw_aircraft_overlay
        
        # Allow matching with aircraft slightly outside the view
        # (we still consider aircraft that have one coordinate outside the [0,1] range)
        if (adsb_x < -0.2 or adsb_x > 1.2 or adsb_y < -0.2 or adsb_y > 1.2):
            continue
        
        # Calculate distance in normalized coordinates
        distance = calculate_distance((norm_detection_x, norm_detection_y), (adsb_x, adsb_y))
        
        if distance < min_distance:
            min_distance = distance
            closest_aircraft = aircraft
    
    return closest_aircraft, min_distance

def draw_matched_aircraft(frame, detection, aircraft, class_names, color, show_conf=True):
    """
    Draw a matched aircraft with combined detection and ADS-B data.
    
    Args:
        frame: Video frame
        detection: Detection data [x1, y1, x2, y2, conf, class_id]
        aircraft: ADS-B aircraft data dictionary
        class_names: List of class names
        color: Color tuple for drawing
        show_conf: Whether to show confidence scores
        
    Returns:
        None (modifies frame in-place)
    """
    x1, y1, x2, y2, conf, cls_id = detection
    
    # Convert to integers for drawing
    x1, y1, x2, y2 = int(x1), int(y1), int(x2), int(y2)
    class_id = int(cls_id)
    
    # Draw bounding box
    cv2.rectangle(frame, (x1, y1), (x2, y2), color, 2)
    
    # Get flight details
    flight = aircraft.get('flight', 'unknown').strip()
    
    # Prepare label text
    if class_id < len(class_names):
        model_label = class_names[class_id]
    else:
        model_label = f"Class {class_id}"
    
    # Format the combined label
    if flight:
        label1 = f"{model_label} ({flight})"
    else:
        label1 = model_label
        
    if show_conf:
        label1 += f" {conf:.2f}"
    
    # Draw text background
    text_size, _ = cv2.getTextSize(label1, cv2.FONT_HERSHEY_SIMPLEX, 0.5, 2)
    
    # Draw background rectangle for text
    cv2.rectangle(frame, 
                 (x1, y1 - text_size[1] - 10), 
                 (x1 + text_size[0] + 10, y1), 
                 color, -1)
    
    # Draw label text
    cv2.putText(frame, label1, (x1 + 5, y1 - 5), 
                cv2.FONT_HERSHEY_SIMPLEX, 0.5, (255, 255, 255), 2)


class AircraftTracker:
    """
    A simple tracker to maintain persistence of aircraft detections over multiple frames.
    This helps with stabilizing ADS-B information display when model detections flicker.
    """
    def __init__(self, max_history=30):
        """
        Initialize the tracker.
        
        Args:
            max_history: Maximum number of frames to maintain history for each flight
        """
        self.tracked_flights = {}  # Dictionary of flight_id -> tracking info
        self.max_history = max_history
    
    def update(self, detections, matched_aircraft):
        """
        Update the tracker with new detections and their matched aircraft.
        
        Args:
            detections: List of detection boxes [x1, y1, x2, y2, conf, class_id]
            matched_aircraft: List of matching aircraft data dictionaries (or None)
            
        Returns:
            List of dictionaries with tracking information to display
        """
        current_flights = set()
        display_items = []
        
        # Process current detections and their matched aircraft
        for i, det in enumerate(detections):
            aircraft = matched_aircraft[i]
            
            if aircraft is None:
                # No aircraft matched to this detection
                continue
                
            # Get flight ID (use as tracking ID)
            flight_id = aircraft.get('flight', '').strip()
            if not flight_id:
                # Skip if no valid flight ID
                continue
                
            current_flights.add(flight_id)
            
            # Extract detection coordinates
            x1, y1, x2, y2, conf, cls_id = det
            
            # Update tracking information
            if flight_id not in self.tracked_flights:
                # Create new tracking entry
                self.tracked_flights[flight_id] = {
                    'positions': deque(maxlen=self.max_history),
                    'last_seen': 0,
                    'aircraft': aircraft
                }
            
            # Add current position to history
            self.tracked_flights[flight_id]['positions'].append((x1, y1, x2, y2))
            self.tracked_flights[flight_id]['last_seen'] = 0  # Reset age counter
            self.tracked_flights[flight_id]['aircraft'] = aircraft  # Update aircraft data
            
            # Add to display items
            display_items.append({
                'flight_id': flight_id,
                'detection': det,
                'aircraft': aircraft,
                'age': 0  # Current frame
            })
        
        # Check for flights that were tracked but not detected in this frame
        for flight_id, track_info in self.tracked_flights.items():
            # Skip if already processed in current detections
            if flight_id in current_flights:
                continue
            
            # Increment age counter for this track
            track_info['last_seen'] += 1
            
            # If within persistence window, add to display items using last known position
            if track_info['last_seen'] <= self.max_history and track_info['positions']:
                # Get the most recent position
                last_pos = track_info['positions'][-1]
                
                # Create a synthetic detection
                synth_det = [
                    last_pos[0],  # x1
                    last_pos[1],  # y1
                    last_pos[2],  # x2
                    last_pos[3],  # y2
                    0.0,          # Set low confidence for synthetic detections
                    0             # Default class ID
                ]
                
                # Add to display items
                display_items.append({
                    'flight_id': flight_id,
                    'detection': synth_det,
                    'aircraft': track_info['aircraft'],
                    'age': track_info['last_seen']  # How many frames since last seen
                })
        
        # Clean up old tracks
        flights_to_remove = []
        for flight_id, track_info in self.tracked_flights.items():
            if track_info['last_seen'] > self.max_history:
                flights_to_remove.append(flight_id)
        
        for flight_id in flights_to_remove:
            del self.tracked_flights[flight_id]
        
        return display_items


def draw_tracked_aircraft(frame, track_item, class_names, show_conf=True):
    """
    Draw a tracked aircraft with its flight information using a consistent styled display.
    
    Args:
        frame: Video frame
        track_item: Dictionary with tracking information
        class_names: List of class names (not used in this version)
        show_conf: Whether to show confidence scores (not used in this version)
        
    Returns:
        None (modifies frame in-place)
    """
    detection = track_item['detection']
    aircraft = track_item['aircraft']
    
    x1, y1, x2, y2, conf, cls_id = detection
    
    # Calculate center of the detection box
    center_x = int((x1 + x2) / 2)
    center_y = int((y1 + y2) / 2)
    
    # Define colors
    dot_color = (180, 0, 180)  # Purple color in BGR
    box_color = (80, 80, 80)   # Gray color in BGR
    
    # Get flight details
    flight = aircraft.get('flight', 'unknown').strip()
    aircraft_type = aircraft.get('icao_type', '')
    altitude = aircraft.get('altitude')
    speed = aircraft.get('speed')
    heading = aircraft.get('heading_deg')
    distance = aircraft.get('distance')
    latitude = aircraft.get('latitude')
    longitude = aircraft.get('longitude')
    
    # Create a list of labels to display (only non-null values)
    labels = []
    
    # Format flight number and aircraft type on first line
    first_line = []
    if flight and flight != 'unknown':
        first_line.append(flight)
    if aircraft_type:
        first_line.append(f"({aircraft_type})")
    
    if first_line:
        labels.append(" ".join(first_line))
    
    # Add distance if available
    if distance is not None:
        # Convert to kilometers and round to one decimal place
        distance_km = distance / 1000
        labels.append(f"{distance_km:.0f} km")
    
    # Format second line with speed, heading, altitude
    second_line = []
    if speed is not None:
        second_line.append(f"{int(speed)} kn")
    if heading is not None:
        second_line.append(f"{int(heading)}deg")
    if altitude is not None:
        second_line.append(f"{int(altitude)} ft")
    
    if second_line:
        labels.append(", ".join(second_line))
    
    # Add coordinates if available
    coord_line = []
    if latitude is not None:
        # Convert decimal to degrees, minutes, seconds format
        lat_deg = int(latitude)
        lat_min = int((latitude - lat_deg) * 60)
        lat_sec = int(((latitude - lat_deg) * 60 - lat_min) * 60)
        lat_dir = "N" if latitude >= 0 else "S"
        coord_line.append(f"{abs(lat_deg)}deg{abs(lat_min)}'{abs(lat_sec)}\" {lat_dir}")
    
    if longitude is not None:
        # Convert decimal to degrees, minutes, seconds format
        lon_deg = int(longitude)
        lon_min = int((longitude - lon_deg) * 60)
        lon_sec = int(((longitude - lon_deg) * 60 - lon_min) * 60)
        lon_dir = "E" if longitude >= 0 else "W"
        coord_line.append(f"{abs(lon_deg)}deg{abs(lon_min)}'{abs(lon_sec)}\" {lon_dir}")
    
    if coord_line:
        labels.append("; ".join(coord_line))
    
    # If no labels, at least show something
    if not labels:
        labels.append("Aircraft")
    
    # Calculate text sizes for each line
    text_sizes = []
    for label in labels:
        text_size, _ = cv2.getTextSize(label, cv2.FONT_HERSHEY_SIMPLEX, 0.5, 1)
        text_sizes.append(text_size)
    
    # Find the maximum width for the background rectangle
    max_width = max([size[0] for size in text_sizes]) if text_sizes else 0
    
    # Calculate the total height needed
    line_height = text_sizes[0][1] + 5 if text_sizes else 0  # Adding a small gap between lines
    total_height = line_height * len(labels)
    
    # Draw the purple dot at the center of detection
    cv2.circle(frame, (center_x, center_y), 5, dot_color, -1)
    
    # Calculate the position of the info box
    box_x1 = center_x + 10
    box_x2 = min(frame.shape[1], box_x1 + max_width + 20)
    box_y1 = max(0, center_y - total_height//2 - 5)
    box_y2 = min(frame.shape[0], box_y1 + total_height + 10)
    
    # Set fixed opacity
    alpha = 0.5
    
    # Create an overlay for the semi-transparent rectangle
    overlay = frame.copy()
    
    # Draw rounded rectangle on overlay
    radius = 8
    
    # Draw main rectangle
    cv2.rectangle(overlay, 
                 (box_x1 + radius, box_y1), 
                 (box_x2 - radius, box_y2), 
                 box_color, -1)
    cv2.rectangle(overlay, 
                 (box_x1, box_y1 + radius), 
                 (box_x2, box_y2 - radius), 
                 box_color, -1)
    
    # Draw the four corner circles
    cv2.circle(overlay, (box_x1 + radius, box_y1 + radius), radius, box_color, -1)
    cv2.circle(overlay, (box_x2 - radius, box_y1 + radius), radius, box_color, -1)
    cv2.circle(overlay, (box_x1 + radius, box_y2 - radius), radius, box_color, -1)
    cv2.circle(overlay, (box_x2 - radius, box_y2 - radius), radius, box_color, -1)
    
    # Apply the semi-transparent overlay to the frame
    cv2.addWeighted(overlay, alpha, frame, 1 - alpha, 0, frame)
    
    # Draw text directly on the frame (solid, not transparent)
    for i, label in enumerate(labels):
        # y_pos = box_y1 + 10 + line_height * (i + 1)
        y_pos = box_y1 + 20 + line_height * i
        cv2.putText(frame, label, (box_x1 + 10, y_pos),
                    cv2.FONT_HERSHEY_SIMPLEX, 0.5, (255, 255, 255), 1)


def get_aircraft_data_for_frame(timestamp_data, timestamps, frame_number, fps):
    """Get the aircraft data closest to the current video frame."""
    # Calculate time in milliseconds from frame number
    video_time_ms = (frame_number / fps) * 1000
    
    # Find the closest timestamp in the JSON data
    closest_timestamp = min(timestamps, key=lambda x: abs(x - video_time_ms))
    
    return timestamp_data[closest_timestamp]

def process_combined_video(
    video_path, 
    model_path, 
    json_path, 
    output_path=None, 
    inference_size=960, 
    class_names=None, 
    show_conf=True, 
    show_adsb_details=True,
    match_mode=False,
    persistence_frames=30
):
    """
    Process a video with object detection and ADS-B overlay.
    
    Args:
        video_path: Path to input video
        model_path: Path to YOLOv8 model weights
        json_path: Path to ADS-B JSON data
        output_path: Path for output video (None for auto-naming)
        inference_size: Size for model inference
        class_names: List of class names (None to use model names)
        show_conf: Whether to show confidence scores for detections
        show_adsb_details: Whether to show detailed ADS-B aircraft information
        match_mode: Whether to match ADS-B data with model detections
        persistence_frames: Number of frames to maintain aircraft visibility after detection disappears
    
    Returns:
        str: Path to the output video
    """
    # Load the object detection model
    print(f"Loading YOLOv8 model from {model_path}")
    model = YOLO(model_path)
    
    # Load ADS-B data
    timestamp_data, timestamps = load_adsb_data(json_path)
    
    # Get class names from model or arguments
    if class_names is None:
        try:
            class_names = model.names
        except AttributeError:
            class_names = [f"class_{i}" for i in range(10)]  # Default fallback
    
    print(f"Using class names: {class_names}")
    
    # Open the input video
    cap = cv2.VideoCapture(video_path)
    if not cap.isOpened():
        print(f"Error: Could not open video {video_path}")
        return None
    
    # Get video properties
    width = int(cap.get(cv2.CAP_PROP_FRAME_WIDTH))
    height = int(cap.get(cv2.CAP_PROP_FRAME_HEIGHT))
    video_fps = cap.get(cv2.CAP_PROP_FPS)
    total_frames = int(cap.get(cv2.CAP_PROP_FRAME_COUNT))
    
    # Get rotation metadata
    rotation_flag = int(cap.get(cv2.CAP_PROP_ORIENTATION_META))
    
    # Adjust dimensions for rotated video
    if rotation_flag in [90, 270]:
        width, height = height, width
        print(f"Video has {rotation_flag}deg rotation, swapping dimensions to {width}x{height}")
    
    # Set output path
    if output_path is None:
        base_name = os.path.basename(video_path)
        name, _ = os.path.splitext(base_name)
        suffix = "_matched" if match_mode else "_combined"
        output_path = os.path.join(os.path.dirname(video_path), f"{name}{suffix}.mp4")
    
    print(f"Output will be saved to: {output_path}")
    print(f"Running in {'matching' if match_mode else 'separate overlay'} mode")
    
    # Create VideoWriter
    fourcc = cv2.VideoWriter_fourcc(*'mp4v')
    out = cv2.VideoWriter(output_path, fourcc, video_fps, (width, height))
    
    # Initialize color dictionary for consistent aircraft colors
    colors = {}
    
    # Process frames
    progress_bar = tqdm(total=total_frames, desc="Processing video")
    frame_number = 0
    
    # Initialize aircraft tracker if in match mode
    aircraft_tracker = None
    if match_mode:
        aircraft_tracker = AircraftTracker(max_history=persistence_frames)
    
    while True:
        ret, frame = cap.read()
        if not ret:
            break
        
        # Apply orientation correction
        frame = apply_orientation(frame, rotation_flag)
        
        # Prepare frame for object detection
        inference_frame, transform_info = resize_for_inference(frame, inference_size)
        
        # Run object detection
        results = model.predict(inference_frame, verbose=False)[0]
        
        # Process detections
        detections = []
        for box in results.boxes:
            x1, y1, x2, y2 = box.xyxy[0].cpu().numpy()
            conf = box.conf[0].item()
            cls_id = int(box.cls[0].item())
            detections.append([x1, y1, x2, y2, conf, cls_id])
        
        # Rescale detections to original resolution
        rescaled_detections = rescale_detections(detections, transform_info)
        
        # Get aircraft data for current frame
        aircraft_data = get_aircraft_data_for_frame(timestamp_data, timestamps, frame_number, video_fps)
        
        if match_mode:
            # Create a new frame for matched output
            matched_frame = frame.copy()
            
            # Prepare matched_aircraft list aligned with detections
            matched_aircraft = []
            for det in rescaled_detections:
                x1, y1, x2, y2, conf, cls_id = det
                
                # Calculate detection center
                center_x = (x1 + x2) / 2
                center_y = (y1 + y2) / 2
                
                # Find closest ADS-B aircraft
                closest_aircraft, distance = find_closest_adsb_aircraft(
                    (center_x, center_y), 
                    aircraft_data, 
                    width, height
                )
                
                matched_aircraft.append(closest_aircraft)
            
            # Update tracker with current detections and get items to display
            display_items = aircraft_tracker.update(rescaled_detections, matched_aircraft)
            
            # Draw all tracked items
            for track_item in display_items:
                draw_tracked_aircraft(matched_frame, track_item, class_names, show_conf)
            
            # Write frame to output video
            out.write(matched_frame)
        else:
            # Original mode: separate model detections and ADS-B overlay
            # Draw object detection predictions first
            frame_with_detections = draw_predictions(frame, rescaled_detections, class_names, show_conf)
            
            # Then draw ADS-B overlay
            draw_aircraft_overlay(frame_with_detections, aircraft_data, colors, show_details=show_adsb_details)
            
            # Write frame to output video
            out.write(frame_with_detections)
        
        # Update progress
        progress_bar.update(1)
        frame_number += 1
    
    # Clean up
    cap.release()
    out.release()
    progress_bar.close()
    
    print(f"Processing complete! Output saved to {output_path}")
    return output_path

# Example usage
if __name__ == "__main__":
    import argparse
    
    parser = argparse.ArgumentParser(description="Process video with object detection and ADS-B overlay")
    parser.add_argument("video_path", help="Path to the input video file")
    parser.add_argument("model_path", help="Path to the YOLOv8 model weights")
    parser.add_argument("json_path", help="Path to the ADS-B JSON data file")
    parser.add_argument("--output", "-o", help="Path for output video (optional)")
    parser.add_argument("--inference-size", type=int, default=960, help="Size for model inference (default: 960)")
    parser.add_argument("--no-conf", action="store_true", help="Hide confidence scores for detections")
    parser.add_argument("--no-adsb-details", action="store_true", help="Hide detailed ADS-B aircraft information")
    parser.add_argument("--match", action="store_true", help="Enable matching mode between detections and ADS-B data")
    parser.add_argument("--persistence", type=int, default=30, 
                        help="Number of frames to maintain aircraft visibility after detection disappears (default: 30)")
    
    args = parser.parse_args()
    
    process_combined_video(
        video_path=args.video_path,
        model_path=args.model_path,
        json_path=args.json_path,
        output_path=args.output,
        inference_size=args.inference_size,
        show_conf=not args.no_conf,
        show_adsb_details=not args.no_adsb_details,
        match_mode=args.match,
        persistence_frames=args.persistence
    )
    