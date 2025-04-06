import cv2
import os
import numpy as np
from ultralytics import YOLO
from tqdm import tqdm

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
    x1, y1, x2, y2, conf, class_id = detection
    
    # Convert to integers for drawing
    x1, y1, x2, y2 = int(x1), int(y1), int(x2), int(y2)
    class_id = int(class_id)
    
    # Draw bounding box
    cv2.rectangle(frame, (x1, y1), (x2, y2), color, 2)
    
    # Get flight details
    flight = aircraft.get('flight', 'unknown').strip()
    altitude = aircraft.get('altitude', 0)
    speed = aircraft.get('speed', 0)
    heading = aircraft.get('heading_deg', 0)
    aircraft_type = aircraft.get('icao_type', '')
    
    # Prepare label text
    if class_id < len(class_names):
        model_label = class_names[class_id]
    else:
        model_label = f"Class {class_id}"
    
    # Format the combined label
    label1 = f"{model_label} ({flight})"
    if show_conf:
        label1 += f" {conf:.2f}"
    
    label2 = f"Type: {aircraft_type}"
    label3 = f"Alt: {int(altitude)}ft Spd: {int(speed)} Hdg: {int(heading)}°"
    
    # Draw text background
    text_size1, _ = cv2.getTextSize(label1, cv2.FONT_HERSHEY_SIMPLEX, 0.5, 2)
    text_size2, _ = cv2.getTextSize(label2, cv2.FONT_HERSHEY_SIMPLEX, 0.5, 2)
    text_size3, _ = cv2.getTextSize(label3, cv2.FONT_HERSHEY_SIMPLEX, 0.5, 2)
    
    max_width = max(text_size1[0], text_size2[0], text_size3[0])
    total_height = text_size1[1] + text_size2[1] + text_size3[1] + 15  # Add some padding
    
    # Draw background rectangle for all text
    cv2.rectangle(frame, 
                 (x1, y1 - total_height - 10), 
                 (x1 + max_width + 10, y1), 
                 color, -1)
    
    # Draw label text
    cv2.putText(frame, label1, (x1 + 5, y1 - total_height + 15), 
                cv2.FONT_HERSHEY_SIMPLEX, 0.5, (255, 255, 255), 2)
    cv2.putText(frame, label2, (x1 + 5, y1 - total_height + 15 + text_size1[1] + 5), 
                cv2.FONT_HERSHEY_SIMPLEX, 0.5, (255, 255, 255), 2)
    cv2.putText(frame, label3, (x1 + 5, y1 - total_height + 15 + text_size1[1] + text_size2[1] + 10), 
                cv2.FONT_HERSHEY_SIMPLEX, 0.5, (255, 255, 255), 2)

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
    match_mode=False
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
        print(f"Video has {rotation_flag}° rotation, swapping dimensions to {width}x{height}")
    
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
            
            # For each model detection, find the closest ADS-B aircraft
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
                
                # Get detection color
                class_id = int(cls_id)
                hue = int(179 * ((class_id * 77) % 17) / 17.0)
                color = cv2.cvtColor(np.uint8([[[hue, 255, 255]]]), cv2.COLOR_HSV2BGR)[0, 0].tolist()
                
                if closest_aircraft is not None:
                    # Draw matched information
                    draw_matched_aircraft(matched_frame, det, closest_aircraft, class_names, color, show_conf)
                else:
                    # Draw regular detection if no match
                    x1, y1, x2, y2 = int(x1), int(y1), int(x2), int(y2)
                    cv2.rectangle(matched_frame, (x1, y1), (x2, y2), color, 2)
                    
                    # Prepare label text
                    if class_id < len(class_names):
                        label = f"{class_names[class_id]}"
                        if show_conf:
                            label += f" {conf:.2f}"
                    else:
                        label = f"Class {class_id}"
                        if show_conf:
                            label += f" {conf:.2f}"
                    
                    # Draw label background
                    text_size, _ = cv2.getTextSize(label, cv2.FONT_HERSHEY_SIMPLEX, 0.5, 2)
                    cv2.rectangle(matched_frame, (x1, y1 - text_size[1] - 10), (x1 + text_size[0], y1), color, -1)
                    
                    # Draw label text
                    cv2.putText(matched_frame, label, (x1, y1 - 5), cv2.FONT_HERSHEY_SIMPLEX, 0.5, (255, 255, 255), 2)
            
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
    
    args = parser.parse_args()
    
    process_combined_video(
        video_path=args.video_path,
        model_path=args.model_path,
        json_path=args.json_path,
        output_path=args.output,
        inference_size=args.inference_size,
        show_conf=not args.no_conf,
        show_adsb_details=not args.no_adsb_details,
        match_mode=args.match
    )