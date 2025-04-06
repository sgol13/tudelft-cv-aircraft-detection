import cv2
import json
import numpy as np
import argparse
import time
import os

def load_adsb_data(json_file):
    """Load ADS-B data from JSON file."""
    print(f"Loading ADS-B data from {json_file}...")
    with open(json_file, 'r') as f:
        data = json.load(f)
    
    # Extract the predictions (timestamps and aircraft data)
    predictions = data.get('predictions', [])
    
    # Create a timestamp-indexed dictionary for quick lookup
    timestamp_data = {}
    for pred in predictions:
        timestamp_data[pred['timestamp']] = pred['aircrafts']
    
    timestamps = sorted(timestamp_data.keys())
    print(f"Loaded data with {len(timestamps)} timestamps and {len(predictions[0]['aircrafts'])} aircraft")
    
    return timestamp_data, timestamps

def check_cuda_availability():
    """Check if CUDA is available in OpenCV and print GPU information."""
    # Check if OpenCV is built with CUDA support
    cuda_available = cv2.cuda.getCudaEnabledDeviceCount() > 0
    
    if cuda_available:
        print("CUDA acceleration is available and will be used")
        for i in range(cv2.cuda.getCudaEnabledDeviceCount()):
            cv2.cuda.printCudaDeviceInfo(i)
        return True
    else:
        print("CUDA acceleration is not available, using CPU processing")
        return False

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

def get_aircraft_data_for_frame(timestamp_data, timestamps, frame_number, fps):
    """Get the aircraft data closest to the current video frame."""
    # Calculate time in milliseconds from frame number
    video_time_ms = (frame_number / fps) * 1000
    
    # Find the closest timestamp in the JSON data
    # closest_timestamp = min(timestamps, key=lambda x: abs(x - video_time_ms))
    closest_timestamp = min(timestamps, key=lambda x: video_time_ms - x if video_time_ms >= x else float('inf'))
    return timestamp_data[closest_timestamp]

def draw_aircraft_overlay(frame, aircraft_data, colors, show_details=True):
    """
    Draw aircraft information onto the video frame with corrected coordinate system.
    
    Args:
    - frame: The video frame to draw on
    - aircraft_data: List of aircraft information dictionaries
    - colors: Dictionary to maintain consistent colors for each flight
    - show_details: Flag to enable/disable detailed aircraft information
    """
    # Get frame dimensions
    h, w = frame.shape[:2]
    
    # List to store aircraft that are actually visible on the screen
    visible_aircraft = []
    
    # First pass: Filter and prepare visible aircraft
    for aircraft in aircraft_data:
        # Get the normalized coordinates
        x_norm = aircraft['pos']['x']
        y_norm = aircraft['pos']['y']
        
        # Correct y-coordinate: invert the y-axis
        y_norm = 1 - y_norm
        
        # Skip aircraft that are outside the screen (outside the 0-1 range)
        if x_norm <= 0 or x_norm >= 1 or y_norm <= 0 or y_norm >= 1:
            continue
        
        # Convert normalized coordinates to pixel coordinates
        x = int(x_norm * w)
        y = int(y_norm * h)
        
        # Add this aircraft to visible aircraft list
        visible_aircraft.append((aircraft, x, y))
    
    # Print visible aircraft for debugging (optional)
    # print(visible_aircraft)
    
    # Second pass: Draw visible aircraft
    for aircraft, x, y in visible_aircraft:
        # Get aircraft color (consistent for each flight)
        flight_id = aircraft.get('flight', 'unknown')
        
        # Assign a consistent random color for each unique flight
        # if flight_id not in colors:
        #     colors[flight_id] = tuple(np.random.randint(0, 255, 3).tolist())
        # color = colors[flight_id]
        color = (219, 206, 55)  # Example color BGR
        
        # Draw aircraft marker (small filled circle)
        cv2.circle(frame, (x, y), 5, color, -1)
        
        # Draw detailed flight information if requested
        if show_details:
            # Prepare text information
            flight = aircraft.get('flight', 'unknown')
            altitude = aircraft.get('altitude', 0)
            speed = aircraft.get('speed', 0)
            heading = aircraft.get('heading_deg', 0)
            aircraft_type = aircraft.get('icao_type', '')
            
            # Format text lines
            text = f"{flight} ({aircraft_type})"
            # if altitude is not None and speed is not None and heading is not None:
            #     text2 = f"Alt: {int(altitude)}ft SPD: {int(speed)} HDG: {int(heading)}deg"
            #     # Draw second text line with background
            #     cv2.rectangle(frame, (x+8, y), (x+8+len(text2)*13, y+40), (0, 0, 0), -1)  # Solid black background
            #     cv2.rectangle(frame, (x+8, y), (x+8+len(text2)*13, y+40), color, 2)        # Colored border
            #     cv2.putText(frame, text2, (x+12, y+25), cv2.FONT_HERSHEY_SIMPLEX, 0.65, color, 2)
            
            # Draw first text line with background
            # cv2.rectangle(frame, (x+8, y-45), (x+8+len(text)*15, y), (0, 0, 0), -1)  # Solid black background
            # cv2.rectangle(frame, (x+8, y-45), (x+8+len(text)*15, y), color, 2)       # Colored border
            cv2.putText(frame, text, (x+12, y-15), cv2.FONT_HERSHEY_SIMPLEX, 0.7, color, 2)

            
    
    # Draw aircraft count on the frame
    cv2.putText(frame, f"Aircraft Visible: {len(visible_aircraft)}",
                (10, 30), cv2.FONT_HERSHEY_SIMPLEX, 0.7, (255, 255, 255), 2)

def process_video(video_file, json_file, output_file, show_preview=False, show_details=True):
    """Process the video with ADS-B data overlay."""
    # Set CUDA environment variables for better performance
    os.environ['OPENCV_OPENCL_RUNTIME'] = ''  # Prefer CUDA over OpenCL
    os.environ['OPENCV_CUDA_GPU'] = '0'       # Use first GPU
    
    # Check for CUDA availability
    cuda_enabled = check_cuda_availability()
    
    # Load ADS-B data
    timestamp_data, timestamps = load_adsb_data(json_file)
    
    # Open video file
    print(f"Opening video file: {video_file}")
    cap = cv2.VideoCapture(video_file)
    
    # Get video properties
    fps = cap.get(cv2.CAP_PROP_FPS)
    orig_width = int(cap.get(cv2.CAP_PROP_FRAME_WIDTH))
    orig_height = int(cap.get(cv2.CAP_PROP_FRAME_HEIGHT))
    total_frames = int(cap.get(cv2.CAP_PROP_FRAME_COUNT))
    
    # Get orientation metadata (if available)
    rotation_flag = 0
    try:
        rotation_flag = int(cap.get(cv2.CAP_PROP_ORIENTATION_META))
        if rotation_flag != 0:
            print(f"Video orientation metadata: {rotation_flag} degrees - automatic rotation will be applied")
    except:
        print("No orientation metadata found or not supported by this OpenCV version")
    
    # Check if we need to swap dimensions due to rotation
    need_dim_swap = rotation_flag in [90, 270]
    if need_dim_swap:
        print(f"Swapping dimensions due to {rotation_flag}° rotation")
        width, height = orig_height, orig_width
    else:
        width, height = orig_width, orig_height
    
    print(f"Video properties: {width}x{height}, {fps} FPS, {total_frames} frames")
    print(f"Processing mode: {'GPU (CUDA)' if cuda_enabled else 'CPU'}")
    
    # Create VideoWriter object for output
    fourcc = cv2.VideoWriter_fourcc(*'mp4v')
    out = cv2.VideoWriter(output_file, fourcc, fps, (width, height))
    
    # Create CUDA stream if CUDA is enabled
    if cuda_enabled:
        stream = cv2.cuda_Stream()
    
    # Dictionary to store colors for each flight
    colors = {}
    
    # Process each frame
    frame_number = 0
    while cap.isOpened():
        ret, frame = cap.read()
        if not ret:
            break
            
        # Apply orientation correction
        frame = apply_orientation(frame, rotation_flag)
        
        # Get aircraft data for current frame
        aircraft_data = get_aircraft_data_for_frame(timestamp_data, timestamps, frame_number, fps)
        
        if cuda_enabled:
            # Upload frame to GPU memory
            gpu_frame = cv2.cuda_GpuMat()
            gpu_frame.upload(frame)
            
            # Basic processing only - no filters
            # The frame is processed on GPU but without additional enhancements
            
            # Download frame back to CPU for drawing operations
            frame = gpu_frame.download()
            
        # Draw aircraft on frame
        draw_aircraft_overlay(frame, aircraft_data, colors, show_details=show_details)
        
        # Add frame counter
        cv2.putText(frame, f"Frame: {frame_number}/{total_frames}",
                   (10, height - 10), cv2.FONT_HERSHEY_SIMPLEX, 0.5, (255, 255, 255), 1)
        
        # Write frame to output video
        out.write(frame)
        
        # Show preview if requested
        if show_preview:
            cv2.namedWindow('ADS-B Overlay', cv2.WINDOW_NORMAL)
            cv2.imshow('ADS-B Overlay', frame)
            if cv2.waitKey(1) & 0xFF == ord('q'):
                break
        
        # Update frame number and print progress
        frame_number += 1
        if frame_number % 100 == 0:
            print(f"Processed {frame_number}/{total_frames} frames ({frame_number/total_frames*100:.1f}%)")
            if cuda_enabled:
                try:
                    free_mem, total_mem = cv2.cuda.deviceMemInfo()
                    print(f"GPU Memory: {(total_mem-free_mem)/1024/1024:.1f}MB used, {free_mem/1024/1024:.1f}MB free")
                except:
                    pass  # Older OpenCV versions might not support deviceMemInfo
    
    # Release resources
    cap.release()
    out.release()
    if show_preview:
        cv2.destroyAllWindows()
        
    # Free CUDA resources if used
    if cuda_enabled:
        try:
            cv2.cuda.resetDevice()
        except:
            pass  # Older OpenCV versions might not support resetDevice
    
    print(f"Video processing complete. Output saved to {output_file}")

def main():
    # Set up argument parser
    parser = argparse.ArgumentParser(description='Create ADS-B data overlay on video')
    parser.add_argument('video_file', help='Path to the video file')
    parser.add_argument('json_file', help='Path to the ADS-B JSON data file')
    parser.add_argument('--output', '-o', default='output.mp4', help='Output file path (default: output.mp4)')
    parser.add_argument('--preview', '-p', action='store_true', help='Show preview during processing')
    parser.add_argument('--no-details', '-nd', action='store_true', help="Don't show detailed aircraft information")
    
    # Parse arguments
    args = parser.parse_args()
    
    # Process video
    start_time = time.time()
    process_video(args.video_file, args.json_file, args.output, 
                  show_preview=args.preview, 
                  show_details=not args.no_details)
    
    processing_time = time.time() - start_time
    print(f"Total processing time: {processing_time:.2f} seconds")
    
    # Calculate processing rate
    try:
        cap = cv2.VideoCapture(args.video_file)
        total_frames = int(cap.get(cv2.CAP_PROP_FRAME_COUNT))
        cap.release()
        fps = total_frames / processing_time
        print(f"Processing speed: {fps:.2f} frames per second")
    except:
        pass

if __name__ == "__main__":
    main()
    