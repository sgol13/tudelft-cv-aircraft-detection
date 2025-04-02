import os
import argparse
import cv2
import numpy as np

def parse_args():
    parser = argparse.ArgumentParser(description='Visualize YOLO format labels on images')
    parser.add_argument('--image_path', type=str, required=True, help='Path to the image')
    parser.add_argument('--label_path', type=str, required=True, help='Path to YOLO label .txt file (default: same as image but .txt)')
    parser.add_argument('--output_path', type=str, help='Path to save visualized image (default: prediction.jpg)')
    return parser.parse_args()

# Define colors for the two classes (BGR format)
COLORS = [
    (0, 0, 255),  # Red for class 0 (contrail)
    (0, 255, 0)   # Green for class 1 (aircraft)
]

# Class names
CLASS_NAMES = ['contrail', 'aircraft']

def parse_yolo_label(label_path, img_width, img_height):
    """Parse YOLO format label file and convert to pixel coordinates"""
    boxes = []
    
    if not os.path.exists(label_path):
        print(f"Warning: Label file {label_path} does not exist")
        return boxes
    
    try:
        with open(label_path, 'r') as f:
            for line in f.readlines():
                parts = line.strip().split()
                if len(parts) >= 5:
                    class_id = int(parts[0])
                    # YOLO format: class_id, x_center, y_center, width, height (normalized)
                    x_center, y_center, width, height = map(float, parts[1:5])
                    
                    # Convert normalized coordinates to pixel coordinates
                    x1 = int((x_center - width/2) * img_width)
                    y1 = int((y_center - height/2) * img_height)
                    x2 = int((x_center + width/2) * img_width)
                    y2 = int((y_center + height/2) * img_height)
                    
                    boxes.append({
                        'class_id': class_id,
                        'x1': x1,
                        'y1': y1,
                        'x2': x2,
                        'y2': y2
                    })
    except Exception as e:
        print(f"Error parsing label file {label_path}: {str(e)}")
    
    return boxes

def draw_boxes(image, boxes):
    """Draw bounding boxes on the image"""
    img_with_boxes = image.copy()
    
    for box in boxes:
        class_id = box['class_id']
        if class_id >= len(COLORS):
            color = (255, 255, 255)  # White for unknown classes
        else:
            color = COLORS[class_id]
            
        x1, y1 = box['x1'], box['y1']
        x2, y2 = box['x2'], box['y2']
        
        # Draw rectangle
        cv2.rectangle(img_with_boxes, (x1, y1), (x2, y2), color, 2)
        
        # Draw label
        label = CLASS_NAMES[class_id] if class_id < len(CLASS_NAMES) else f"class_{class_id}"
        cv2.putText(img_with_boxes, label, (x1, y1 - 10), 
                    cv2.FONT_HERSHEY_SIMPLEX, 0.5, color, 2)
    
    return img_with_boxes

def main():
    args = parse_args()
    
    # Load the image
    image_path = args.image_path
    image = cv2.imread(image_path)
    if image is None:
        print(f"Error: Could not load image from {image_path}")
        return
    
    img_height, img_width = image.shape[:2]
    
    # Determine label path if not provided
    label_path = args.label_path
    if label_path is None:
        label_path = os.path.splitext(image_path)[0] + '.txt'
        print(f"Using label file: {label_path}")
    
    # Parse YOLO labels
    boxes = parse_yolo_label(label_path, img_width, img_height)
    print(f"Found {len(boxes)} bounding boxes")
    
    # Draw boxes on image
    annotated_image = draw_boxes(image, boxes)
    
    # Save or display the result
    output_path = args.output_path if args.output_path else "prediction.jpg"
    cv2.imwrite(output_path, annotated_image)
    print(f"Saved annotated image to {output_path}")
    
    # Display the image
    cv2.imshow("YOLO Labels", annotated_image)
    print("Press any key to close the window...")
    cv2.waitKey(0)
    cv2.destroyAllWindows()

if __name__ == "__main__":
    main()
    