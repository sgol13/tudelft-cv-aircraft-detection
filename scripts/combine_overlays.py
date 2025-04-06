import cv2
import os
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

def process_combined_video(
    video_path, 
    model_path, 
    json_path, 
    output_path=None, 
    inference_size=960, 
    class_names=None, 
    show_conf=True, 
    show_adsb_details=True
):
    """
    Process a video with object detection and ADS-B overlay
    
    Args:
        video_path: Path to input video
        model_path: Path to YOLOv8 model weights
        json_path: Path to ADS-B JSON data
        output_path: Path for output video (None for auto-naming)
        inference_size: Size for model inference
        class_names: List of class names (None to use model names)
        show_conf: Whether to show confidence scores for detections
        show_adsb_details: Whether to show detailed ADS-B aircraft information
    
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
        output_path = os.path.join(os.path.dirname(video_path), f"{name}_combined.mp4")
    
    print(f"Output will be saved to: {output_path}")
    
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
        
        # Draw object detection predictions
        frame_with_detections = draw_predictions(frame, rescaled_detections, class_names, show_conf)
        
        # Get aircraft data for current frame
        aircraft_data = get_aircraft_data_for_frame(timestamp_data, timestamps, frame_number, video_fps)
        
        # Draw ADS-B overlay
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

# Function to get aircraft data for a specific frame (same as in adsb_overlay.py)
def get_aircraft_data_for_frame(timestamp_data, timestamps, frame_number, fps):
    """Get the aircraft data closest to the current video frame."""
    # Calculate time in milliseconds from frame number
    video_time_ms = (frame_number / fps) * 1000
    
    # Find the closest timestamp in the JSON data
    closest_timestamp = min(timestamps, key=lambda x: abs(x - video_time_ms))
    
    return timestamp_data[closest_timestamp]

# Example usage
if __name__ == "__main__":
    video_path = "./app_recordings/videos/1743945766002.mp4"
    model_path = "./best.pt"
    json_path = "./app_recordings/adsb/1743945766002.json"
    output_path = "./combined_output_2.mp4"
    
    process_combined_video(
        video_path=video_path,
        model_path=model_path,
        json_path=json_path,
        output_path=output_path,
        show_conf=True,
        show_adsb_details=True
    )