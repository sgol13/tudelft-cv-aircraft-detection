import os
import argparse
import xml.etree.ElementTree as ET
import glob
from pathlib import Path
import cv2
import shutil
import random
import numpy as np
from tqdm import tqdm

def parse_args():
    parser = argparse.ArgumentParser(description='Convert CVAT XML annotations to YOLO format with automatic orientation')
    parser.add_argument('--input_dir', type=str, required=True, help='Directory containing CVAT XML files')
    parser.add_argument('--output_dir', type=str, default='yolo_dataset', help='Output directory for YOLO dataset')
    parser.add_argument('--video_dir', type=str, required=True, help='Directory containing source videos')
    parser.add_argument('--train_ratio', type=float, default=0.7, help='Ratio of videos for training')
    parser.add_argument('--val_ratio', type=float, default=0.2, help='Ratio of videos for validation')
    parser.add_argument('--test_ratio', type=float, default=0.1, help='Ratio of videos for testing')
    parser.add_argument('--frame_interval', type=int, default=1, help='Extract every Nth frame (1=all frames)')
    parser.add_argument('--seed', type=int, default=42, help='Random seed for reproducibility')
    parser.add_argument('--target_size', type=str, default=None, help='Target size for resizing, format: WIDTHxHEIGHT')
    return parser.parse_args()

def create_dataset_structure(output_dir):
    """Create the YOLO dataset directory structure"""
    os.makedirs(output_dir, exist_ok=True)
    os.makedirs(os.path.join(output_dir, 'train', 'images'), exist_ok=True)
    os.makedirs(os.path.join(output_dir, 'train', 'labels'), exist_ok=True)
    os.makedirs(os.path.join(output_dir, 'val', 'images'), exist_ok=True)
    os.makedirs(os.path.join(output_dir, 'val', 'labels'), exist_ok=True)
    os.makedirs(os.path.join(output_dir, 'test', 'images'), exist_ok=True)
    os.makedirs(os.path.join(output_dir, 'test', 'labels'), exist_ok=True)

def create_class_mapping():
    """Create a mapping of class names to YOLO class indices"""
    # Customize this based on your CVAT labels
    return {
        'high_airliner_contrail': 0,
        'high_airliner': 1,
        'low_airliner': 2,
        'light_airplane': 3,
        'helicopter': 4,
        'other': 5,
        'contrail': 6
    }

def parse_cvat_annotations(xml_path, class_mapping):
    """Parse CVAT XML annotations and return frame indices and annotations"""
    try:
        tree = ET.parse(xml_path)
        root = tree.getroot()
        
        # Get the video source name and dimensions
        source = ''
        original_width = 0
        original_height = 0
        frame_count = 0
        
        for meta in root.findall('.//meta'):
            for task in meta.findall('.//task'):
                for src in task.findall('.//source'):
                    source = src.text.strip()
                for size in task.findall('.//original_size'):
                    width = size.find('.//width')
                    height = size.find('.//height')
                    if width is not None and height is not None:
                        original_width = int(width.text)
                        original_height = int(height.text)
                # Try to get frame count
                stop_frame = task.find('.//stop_frame')
                if stop_frame is not None:
                    frame_count = int(stop_frame.text) + 1
        
        video_name = Path(source).stem if source else Path(xml_path).stem
        
        # Dictionary to store annotations by frame
        frames_annotations = {}
        
        # Process all tracks
        for track in root.findall('.//track'):
            track_label = track.get('label')
            if track_label not in class_mapping:
                print(f"Warning: Label '{track_label}' not in class mapping, skipping")
                continue
                
            class_id = class_mapping[track_label]
            
            # Process all boxes in this track
            for box in track.findall('.//box'):
                frame_id = int(box.get('frame'))
                outside = int(box.get('outside'))
                
                # Skip if the object is outside the frame
                if outside == 1:
                    continue
                
                # Get box coordinates
                xtl = float(box.get('xtl'))
                ytl = float(box.get('ytl'))
                xbr = float(box.get('xbr'))
                ybr = float(box.get('ybr'))
                
                # Initialize frame annotations if needed
                if frame_id not in frames_annotations:
                    frames_annotations[frame_id] = []
                
                # Store the raw coordinates
                frames_annotations[frame_id].append({
                    'class_id': class_id,
                    'xtl': xtl,
                    'ytl': ytl,
                    'xbr': xbr,
                    'ybr': ybr
                })
        
        return video_name, frames_annotations, (original_width, original_height), frame_count
    
    except Exception as e:
        print(f"Error processing {xml_path}: {str(e)}")
        return None, {}, (0, 0), 0

def apply_orientation(frame, rotation_flag):
    """Apply orientation correction based on rotation flag"""
    if rotation_flag == 90:
        return cv2.rotate(frame, cv2.ROTATE_90_CLOCKWISE)
    elif rotation_flag == 180:
        return cv2.rotate(frame, cv2.ROTATE_180)
    elif rotation_flag == 270:
        return cv2.rotate(frame, cv2.ROTATE_90_COUNTERCLOCKWISE)
    else:
        return frame  # No rotation needed

def extract_frames_with_auto_orientation(video_path, output_dir, video_name, xml_dimensions, 
                                         frame_interval=1):
    """Extract frames with orientation correction based on video metadata"""
    print(f"Extracting frames from {video_path} (every {frame_interval} frame)...")
    
    # Create output directory
    frames_dir = os.path.join(output_dir, 'frames', video_name)
    os.makedirs(frames_dir, exist_ok=True)
    
    # Open video file
    video = cv2.VideoCapture(video_path)
    
    if not video.isOpened():
        print(f"Error: Could not open video {video_path}")
        return {}, (0, 0), 0
    
    # Get video properties
    frame_width = int(video.get(cv2.CAP_PROP_FRAME_WIDTH))
    frame_height = int(video.get(cv2.CAP_PROP_FRAME_HEIGHT))
    frame_count = int(video.get(cv2.CAP_PROP_FRAME_COUNT))
    
    # Try to get rotation metadata
    rotation_flag = video.get(cv2.CAP_PROP_ORIENTATION_META)
    
    print(f"Video metadata - dimensions: {frame_width}x{frame_height}, rotation: {rotation_flag}")
    print(f"CVAT dimensions: {xml_dimensions[0]}x{xml_dimensions[1]}")
    
    # Extract frames with orientation correction
    extracted_frames = {}
    frame_idx = 0
    
    with tqdm(total=frame_count, desc=f"Extracting frames from {video_name}") as pbar:
        while True:
            ret, frame = video.read()
            if not ret:
                break
                
            # Extract only every Nth frame
            if frame_idx % frame_interval == 0:
                # Apply orientation correction based on metadata
                corrected_frame = apply_orientation(frame, rotation_flag)
                
                frame_path = os.path.join(frames_dir, f"{video_name}_{frame_idx:06d}.jpg")
                cv2.imwrite(frame_path, corrected_frame)
                extracted_frames[frame_idx] = frame_path
                
            frame_idx += 1
            pbar.update(1)
    
    video.release()
    
    # Get dimensions from the first extracted frame (after rotation)
    if extracted_frames:
        corrected_frame = cv2.imread(next(iter(extracted_frames.values())))
        if corrected_frame is not None:
            height, width = corrected_frame.shape[:2]
            dimensions = (width, height)
        else:
            dimensions = (frame_width, frame_height)
    else:
        dimensions = (frame_width, frame_height)
    
    # If rotation is 90 or 270 degrees, width and height were swapped
    if rotation_flag in [90, 270]:
        print(f"90-degree rotation detected, dimensions after rotation: {dimensions[0]}x{dimensions[1]}")
    
    print(f"Extracted {len(extracted_frames)} frames from {video_path}")
    print(f"Frame dimensions after orientation correction: {dimensions[0]}x{dimensions[1]}")
    return extracted_frames, dimensions, len(extracted_frames)

def convert_to_yolo_format(annotation, img_width, img_height, target_width=None, target_height=None):
    """
    Convert box coordinates to YOLO format, optionally handling resizing
    
    Args:
        annotation: Dictionary with box coordinates
        img_width: Original image width
        img_height: Original image height
        target_width: Target width after resizing (if applicable)
        target_height: Target height after resizing (if applicable)
    
    Returns:
        YOLO format annotation string
    """
    xtl = annotation['xtl']
    ytl = annotation['ytl']
    xbr = annotation['xbr']
    ybr = annotation['ybr']
    
    # Ensure coordinates are within image bounds
    xtl = max(0, min(img_width, xtl))
    ytl = max(0, min(img_height, ytl))
    xbr = max(0, min(img_width, xbr))
    ybr = max(0, min(img_height, ybr))
    
    # If target dimensions are provided, adjust coordinates
    if target_width is not None and target_height is not None:
        # Calculate scaling factors
        width_scale = target_width / img_width
        height_scale = target_height / img_height
        
        # Apply scaling
        xtl = xtl * width_scale
        ytl = ytl * height_scale
        xbr = xbr * width_scale
        ybr = ybr * height_scale
        
        # Update dimensions for normalization
        img_width = target_width
        img_height = target_height
    
    # Convert to YOLO format: <class> <x_center> <y_center> <width> <height>
    # Where x, y, width, height are normalized to [0, 1]
    x_center = (xtl + xbr) / (2 * img_width)
    y_center = (ytl + ybr) / (2 * img_height)
    width = (xbr - xtl) / img_width
    height = (ybr - ytl) / img_height
    
    # Ensure values are within [0, 1]
    x_center = max(0, min(1, x_center))
    y_center = max(0, min(1, y_center))
    width = max(0, min(1, width))
    height = max(0, min(1, height))
    
    return f"{annotation['class_id']} {x_center:.6f} {y_center:.6f} {width:.6f} {height:.6f}"

def split_videos(video_list, train_ratio, val_ratio, seed=42):
    """Split videos into train, validation, and test sets"""
    # Set seed for reproducibility
    random.seed(seed)
    
    # Shuffle the video list
    shuffled = video_list.copy()
    random.shuffle(shuffled)
    
    # Calculate split indices
    n = len(shuffled)
    train_idx = int(n * train_ratio)
    val_idx = train_idx + int(n * val_ratio)
    
    # Split into sets
    train_videos = shuffled[:train_idx]
    val_videos = shuffled[train_idx:val_idx]
    test_videos = shuffled[val_idx:]
    
    # Return sets
    return {
        'train': set(train_videos),
        'val': set(val_videos),
        'test': set(test_videos)
    }

def resize_image(image_path, target_width, target_height, output_path):
    """Resize an image to target dimensions preserving aspect ratio"""
    img = cv2.imread(image_path)
    if img is None:
        print(f"Warning: Could not read image {image_path}")
        return False
    
    # Calculate scaling to preserve aspect ratio
    h, w = img.shape[:2]
    scale = min(target_width / w, target_height / h)
    
    # New dimensions
    new_w = int(w * scale)
    new_h = int(h * scale)
    
    # Resize image
    resized = cv2.resize(img, (new_w, new_h), interpolation=cv2.INTER_AREA)
    
    # Create canvas of target size (filled with black)
    canvas = np.zeros((target_height, target_width, 3), dtype=np.uint8)
    
    # Calculate position to center the image
    x_offset = (target_width - new_w) // 2
    y_offset = (target_height - new_h) // 2
    
    # Place the resized image on the canvas
    canvas[y_offset:y_offset+new_h, x_offset:x_offset+new_w] = resized
    
    # Save the result
    return cv2.imwrite(output_path, canvas)

def process_video(xml_file, video_dir, output_dir, split, target_size=None, frame_interval=1):
    """Process a single video with its annotations"""
    # Parse annotations
    video_name, annotations, xml_dims, xml_frame_count = parse_cvat_annotations(
        xml_file, create_class_mapping())
    
    if not video_name:
        print(f"Failed to extract video name from {xml_file}")
        return
    
    # Find video file
    video_path = None
    for ext in ['.mp4', '.avi', '.mov', '.mkv']:
        potential_path = os.path.join(video_dir, video_name + ext)
        if os.path.exists(potential_path):
            video_path = potential_path
            break
    
    if not video_path:
        print(f"Warning: Could not find video file for {video_name}")
        return
    
    # Extract frames with auto orientation detection
    extracted_frames, frame_dimensions, actual_frame_count = extract_frames_with_auto_orientation(
        video_path, output_dir, video_name, xml_dims, frame_interval)
    
    if not extracted_frames:
        print(f"Failed to extract frames from {video_path}")
        return
    
    # Use frame dimensions for annotation conversion
    source_width, source_height = frame_dimensions
    
    # Parse target size if provided
    target_width, target_height = None, None
    if target_size and 'x' in target_size:
        target_width, target_height = map(int, target_size.split('x'))
        print(f"Target size: {target_width}x{target_height}")
    
    # Determine destination path based on the split
    dest_split = None
    for split_name, videos in split.items():
        if video_name in videos:
            dest_split = split_name
            break
    
    if not dest_split:
        print(f"Warning: {video_name} not found in any split")
        return
    
    # Process each extracted frame
    print(f"Processing {len(extracted_frames)} frames from {video_name}...")
    for frame_idx, frame_path in tqdm(extracted_frames.items(), desc=f"Processing {video_name}"):
        frame_filename = os.path.basename(frame_path)
        label_filename = os.path.splitext(frame_filename)[0] + '.txt'
        
        # Determine destination paths
        img_dest = os.path.join(output_dir, dest_split, 'images', frame_filename)
        label_dest = os.path.join(output_dir, dest_split, 'labels', label_filename)
        
        # Copy/resize image
        if target_width and target_height:
            # Resize and center image
            resize_success = resize_image(frame_path, target_width, target_height, img_dest)
            if not resize_success:
                print(f"Warning: Failed to resize {frame_path}")
                continue
        else:
            # Just copy the image
            shutil.copy2(frame_path, img_dest)
        
        # Create label file (with annotations if available)
        if frame_idx in annotations:
            with open(label_dest, 'w') as f:
                for annotation in annotations[frame_idx]:
                    yolo_annotation = convert_to_yolo_format(
                        annotation, source_width, source_height, target_width, target_height)
                    f.write(yolo_annotation + '\n')
        else:
            # Create empty label file
            open(label_dest, 'w').close()
    
    print(f"Processed {video_name}: {len(extracted_frames)} frames added to {dest_split} set")

def create_data_yaml(output_dir, class_mapping):
    """Create the data.yaml file for YOLOv8 training"""
    class_names = [k for k, v in sorted(class_mapping.items(), key=lambda item: item[1])]
    
    with open(os.path.join(output_dir, 'data.yaml'), 'w') as f:
        f.write(f"train: {os.path.join('train', 'images')}\n")
        f.write(f"val: {os.path.join('val', 'images')}\n")
        f.write(f"test: {os.path.join('test', 'images')}\n\n")
        
        f.write(f"nc: {len(class_names)}\n")
        f.write(f"names: {class_names}\n")

def main():
    args = parse_args()
    
    # Create output directory structure
    create_dataset_structure(args.output_dir)
    
    # Find all XML files in the input directory
    xml_files = glob.glob(os.path.join(args.input_dir, '*.xml'))
    print(f"Found {len(xml_files)} XML files")
    
    # Extract video names from XML files
    video_names = []
    for xml_file in xml_files:
        try:
            tree = ET.parse(xml_file)
            root = tree.getroot()
            
            # Get the video source name
            source = ''
            for meta in root.findall('.//meta'):
                for task in meta.findall('.//task'):
                    for src in task.findall('.//source'):
                        source = src.text.strip()
                        break
            
            video_name = Path(source).stem if source else Path(xml_file).stem
            video_names.append(video_name)
        except Exception as e:
            print(f"Error extracting video name from {xml_file}: {str(e)}")
    
    # Create the video split
    split = split_videos(video_names, args.train_ratio, args.val_ratio, args.seed)
    
    print(f"Video split:")
    print(f"  Train: {len(split['train'])} videos")
    print(f"  Validation: {len(split['val'])} videos")
    print(f"  Test: {len(split['test'])} videos")
    
    # Process each XML file
    for xml_file in xml_files:
        # Process the video
        process_video(
            xml_file, 
            args.video_dir, 
            args.output_dir, 
            split, 
            target_size=args.target_size,
            frame_interval=args.frame_interval
        )
    
    # Create data.yaml file
    create_data_yaml(args.output_dir, create_class_mapping())
    
    # Print statistics
    train_images = len(os.listdir(os.path.join(args.output_dir, 'train', 'images')))
    val_images = len(os.listdir(os.path.join(args.output_dir, 'val', 'images')))
    test_images = len(os.listdir(os.path.join(args.output_dir, 'test', 'images')))
    
    print(f"\nDataset statistics:")
    print(f"  Training images: {train_images}")
    print(f"  Validation images: {val_images}")
    print(f"  Test images: {test_images}")
    print(f"  Total images: {train_images + val_images + test_images}")
    print(f"\nDataset creation complete. YOLO dataset created in {args.output_dir}")

if __name__ == "__main__":
    main()