import os
import cv2
import numpy as np
from ultralytics import YOLO
from tqdm import tqdm


def apply_orientation(frame, rotation_flag):
    """
    Apply orientation correction based on rotation flag from video metadata
    
    Args:
        frame: Input frame (numpy array)
        rotation_flag: Rotation value from video metadata (0, 90, 180, or 270)
        
    Returns:
        numpy.ndarray: Rotated frame
    """
    if rotation_flag == 90:
        return cv2.rotate(frame, cv2.ROTATE_90_CLOCKWISE)
    elif rotation_flag == 180:
        return cv2.rotate(frame, cv2.ROTATE_180)
    elif rotation_flag == 270:
        return cv2.rotate(frame, cv2.ROTATE_90_COUNTERCLOCKWISE)
    else:
        return frame  # No rotation neededimport os

def resize_for_inference(frame, target_size):
    """
    Resize frame to target size with padding to maintain aspect ratio
    
    Args:
        frame: Input frame (numpy array)
        target_size: Target size for inference (int)
        
    Returns:
        tuple: (resized frame, transformation info for rescaling)
    """
    # Get original dimensions
    h, w = frame.shape[:2]
    
    # Calculate scaling to preserve aspect ratio
    scale = min(target_size / w, target_size / h)
    
    # Calculate new dimensions
    new_w = int(w * scale)
    new_h = int(h * scale)
    
    # Resize frame
    resized = cv2.resize(frame, (new_w, new_h), interpolation=cv2.INTER_AREA)
    
    # Create square canvas for inference
    square_img = np.zeros((target_size, target_size, 3), dtype=np.uint8)
    
    # Calculate offsets for centering
    offset_x = (target_size - new_w) // 2
    offset_y = (target_size - new_h) // 2
    
    # Place resized image on square canvas
    square_img[offset_y:offset_y + new_h, offset_x:offset_x + new_w] = resized
    
    # For debugging: optionally draw a border around the actual image area
    # cv2.rectangle(square_img, (offset_x, offset_y), (offset_x + new_w, offset_y + new_h), (0, 255, 0), 2)
    
    # Return square image and transformation info for later use
    # We return: scale factor, x padding offset, y padding offset, original width, original height
    return square_img, (scale, offset_x, offset_y, w, h)

def rescale_detections(detections, transform_info):
    """
    Rescale detections back to original resolution
    
    Args:
        detections: List of detections [x1, y1, x2, y2, conf, class_id]
        transform_info: Transformation info from resize_for_inference
        
    Returns:
        list: Rescaled detections
    """
    scale, offset_x, offset_y, orig_w, orig_h = transform_info
    
    rescaled_detections = []
    for det in detections:
        # Extract detection info (assuming [x1, y1, x2, y2, conf, class_id])
        x1, y1, x2, y2, conf, class_id = det
        
        # First, subtract the padding offset to get coordinates in the resized image
        # (not the padded square image used for inference)
        x1 = x1 - offset_x
        y1 = y1 - offset_y
        x2 = x2 - offset_x
        y2 = y2 - offset_y
        
        # Now, apply inverse scaling to get back to original image dimensions
        x1 = x1 / scale
        y1 = y1 / scale
        x2 = x2 / scale
        y2 = y2 / scale
        
        # Ensure coordinates are within original image bounds
        x1 = max(0, min(orig_w, x1))
        y1 = max(0, min(orig_h, y1))
        x2 = max(0, min(orig_w, x2))
        y2 = max(0, min(orig_h, y2))
        
        # Skip boxes that are too small or invalid after rescaling,
        # or boxes that were entirely in the padded area
        if x2 <= x1 or y2 <= y1 or x2 <= 0 or y2 <= 0 or x1 >= orig_w or y1 >= orig_h:
            continue
            
        rescaled_detections.append([x1, y1, x2, y2, conf, class_id])
        
    return rescaled_detections

def draw_predictions(frame, detections, class_names, show_conf=True):
    """
    Draw detection boxes and labels on frame
    
    Args:
        frame: Original frame
        detections: List of detections [x1, y1, x2, y2, conf, class_id]
        class_names: List of class names
        show_conf: Whether to show confidence scores
        
    Returns:
        numpy.ndarray: Frame with drawn predictions
    """
    # Create a copy of the frame to avoid modifying the original
    result_frame = frame.copy()
    
    for det in detections:
        x1, y1, x2, y2, conf, class_id = det
        
        # Convert to integers for drawing
        x1, y1, x2, y2 = int(x1), int(y1), int(x2), int(y2)
        class_id = int(class_id)
        
        # Get class color (using HSV color space for better distinction)
        # Convert class_id to a hue value (0-179)
        hue = int(179 * ((class_id * 77) % 17) / 17.0)  # Using prime numbers for better distribution
        color = cv2.cvtColor(np.uint8([[[hue, 255, 255]]]), cv2.COLOR_HSV2BGR)[0, 0].tolist()
        
        # Draw box
        cv2.rectangle(result_frame, (x1, y1), (x2, y2), color, 1)
        
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
        cv2.rectangle(result_frame, (x1, y1 - text_size[1] - 10), (x1 + text_size[0], y1), color, -1)
        
        # Draw label text
        cv2.putText(result_frame, label, (x1, y1 - 5), cv2.FONT_HERSHEY_SIMPLEX, 0.5, (255, 255, 255), 2)
        
    return result_frame

def process_frame(frame, model, class_names, inference_size=960, show_conf=True, output_path=None):
    """
    Process a single frame with the YOLOv8 model
    
    Args:
        frame: Input frame
        model: Loaded YOLO model
        class_names: List of class names
        inference_size: Size for model inference
        conf_threshold: Confidence threshold for detections
        show_conf: Whether to show confidence scores
        output_path: Path to save the output frame (None to skip saving)
        
    Returns:
        numpy.ndarray: Frame with drawn predictions
    """
    # Resize frame for inference
    inference_frame, transform_info = resize_for_inference(frame, inference_size)
    
    # Run inference
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
    
    # Draw detections on the original frame
    output_frame = draw_predictions(frame, rescaled_detections, class_names, show_conf)
    
    # Save the output frame if path is provided
    if output_path is not None:
        cv2.imwrite(output_path, output_frame)
        print(f"Saved processed frame to {output_path}")
        
    return output_frame

def process_video(video_path, model_path, output_path=None, inference_size=960, class_names=None, show_conf=True, fps=None):
    """
    Process a video and render predictions
    
    Args:
        video_path: Path to input video
        model_path: Path to YOLOv8 model weights
        output_path: Path for output video (None for auto-naming)
        inference_size: Size for model inference
        conf_threshold: Confidence threshold for detections
        class_names: List of class names (None to use model names)
        show_conf: Whether to show confidence scores
        fps: FPS for output video (None to use input video's FPS)
        
    Returns:
        str: Path to the output video
    """
    # Load the model
    print(f"Loading YOLOv8 model from {model_path}")
    model = YOLO(model_path)
    
    # Get class names from model or arguments
    if class_names is None:
        # Try to get class names from model
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
    output_fps = video_fps if fps is None else fps
    total_frames = int(cap.get(cv2.CAP_PROP_FRAME_COUNT))
    
    # Get rotation metadata
    rotation_flag = int(cap.get(cv2.CAP_PROP_ORIENTATION_META))
    
    # If we have a 90° or 270° rotation, we need to swap width and height for the output
    if rotation_flag in [90, 270]:
        width, height = height, width
        print(f"Video has {rotation_flag}° rotation, swapping dimensions to {width}x{height}")
    else:
        print(f"Video properties: {width}x{height}, {video_fps} FPS, {total_frames} frames")
        if rotation_flag:
            print(f"Video has {rotation_flag}° rotation")
    
    # Set output path
    if output_path is None:
        base_name = os.path.basename(video_path)
        name, ext = os.path.splitext(base_name)
        output_path = os.path.join(os.path.dirname(video_path), f"{name}_predictions.mp4")
    
    print(f"Output will be saved to: {output_path}")
    
    # Create VideoWriter
    fourcc = cv2.VideoWriter_fourcc(*'mp4v')
    out = cv2.VideoWriter(output_path, fourcc, output_fps, (width, height))
    
    # Process frames
    progress_bar = tqdm(total=total_frames, desc="Processing video")
    
    while True:
        ret, frame = cap.read()
        if not ret:
            break
        
        # Apply orientation correction
        frame = apply_orientation(frame, rotation_flag)
        
        # Process the frame
        output_frame = process_frame(
            frame, model, class_names, 
            inference_size=inference_size,
            show_conf=show_conf
        )
        
        # Write frame to output video
        out.write(output_frame)
        
        # Update progress
        progress_bar.update(1)
    
    # Clean up
    cap.release()
    out.release()
    progress_bar.close()
    
    print(f"Processing complete! Output saved to {output_path}")
    return output_path

def load_model(model_path):
    """
    Load a YOLOv8 model
    
    Args:
        model_path: Path to model weights
        
    Returns:
        YOLO: Loaded model
    """
    return YOLO(model_path)

# Example usage:
if __name__ == "__main__":
    # This is just an example of how to use the functions
    # video_path = "./data/videos/76cda50e.mp4"
    video_path = "./data/videos/4b9e18a9.mp4"
    model_path = "./yolov8n_finetune11_960_2/weights/best.pt"
    output_path = "./output_video.mp4"
    # Simple usage
    process_video(video_path, model_path, output_path)
    
    # Advanced usage
    # process_video(
    #     video_path=video_path,
    #     model_path=model_path,
    #     output_path="custom_output.mp4",
    #     inference_size=640,
    #     conf_threshold=0.5,
    #     class_names=["contrail", "aircraft"],
    #     show_conf=True,
    #     fps=30
    # )
    
    # # Process a single frame
    # model = load_model(model_path)
    # frame = cv2.imread("sample_frame.jpg")
    # processed = process_frame(
    #     frame=frame,
    #     model=model,
    #     class_names=["contrail", "aircraft"],
    #     output_path="processed_frame.jpg"
    # )