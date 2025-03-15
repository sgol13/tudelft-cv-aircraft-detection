from ultralytics import YOLO
import cv2
import numpy as np
import os

# Load your trained model
model = YOLO('./aircraft_detection/yolov8n_finetune6/weights/best.pt')

# Path to test image
image_path = './datasets/yolo_data/train/images/3cdfa11e_000002.jpg'
label_path = image_path.replace('images', 'labels').replace('.jpg', '.txt')

# Class names (adjust based on your data.yaml)
class_names = ['high_airliner_contrail', 'high_airliner', 'low_airliner', 
               'light_airplane', 'helicopter', 'other', 'contrail']

# Colors for different boxes
pred_color = (0, 255, 0)  # Green for predictions
gt_color = (0, 0, 255)    # Red for ground truth

def calculate_iou(box1, box2):
    """Calculate Intersection over Union between two boxes [x1, y1, x2, y2]"""
    # Calculate intersection area
    x_left = max(box1[0], box2[0])
    y_top = max(box1[1], box2[1])
    x_right = min(box1[2], box2[2])
    y_bottom = min(box1[3], box2[3])
    
    if x_right < x_left or y_bottom < y_top:
        return 0.0  # No intersection
    
    intersection_area = (x_right - x_left) * (y_bottom - y_top)
    
    # Calculate union area
    box1_area = (box1[2] - box1[0]) * (box1[3] - box1[1])
    box2_area = (box2[2] - box2[0]) * (box2[3] - box2[1])
    union_area = box1_area + box2_area - intersection_area
    
    # Calculate IoU
    if union_area <= 0:
        return 0.0
    return intersection_area / union_area

# Run inference
results = model(image_path)
result = results[0]

# Load the image
original_img = cv2.imread(image_path)
if original_img is None:
    print(f"Error: Could not load image from {image_path}")
    exit(1)
    
img_height, img_width = original_img.shape[:2]

# Create a working copy
img = original_img.copy()

# Get predicted boxes
pred_boxes = []
for box in result.boxes:
    x1, y1, x2, y2 = box.xyxy[0].cpu().numpy()
    conf = box.conf[0].item()
    cls_id = int(box.cls[0].item())
    
    pred_boxes.append((cls_id, int(x1), int(y1), int(x2), int(y2), conf))
    
    # Draw prediction box
    cv2.rectangle(img, (int(x1), int(y1)), (int(x2), int(y2)), pred_color, 2)
    
    # Add label
    label = f"{class_names[cls_id]} {conf:.2f}"
    cv2.putText(img, label, (int(x1), int(y1) - 10), cv2.FONT_HERSHEY_SIMPLEX, 
                0.5, pred_color, 2)

# Get ground truth boxes
gt_boxes = []
if os.path.exists(label_path):
    print(f"Found label file: {label_path}")
    with open(label_path, 'r') as f:
        for line in f.readlines():
            parts = line.strip().split()
            if len(parts) == 5:
                cls_id = int(parts[0])
                x_center, y_center, width, height = map(float, parts[1:5])
                
                # Convert normalized coordinates to pixel coordinates
                x1 = int((x_center - width/2) * img_width)
                y1 = int((y_center - height/2) * img_height)
                x2 = int((x_center + width/2) * img_width)
                y2 = int((y_center + height/2) * img_height)
                
                gt_boxes.append((cls_id, x1, y1, x2, y2))
                
                # Draw ground truth box
                cv2.rectangle(img, (x1, y1), (x2, y2), gt_color, 2)
                
                # Add label
                label = f"GT: {class_names[cls_id]}"
                cv2.putText(img, label, (x1, y1 - 25), cv2.FONT_HERSHEY_SIMPLEX, 
                            0.5, gt_color, 2)
else:
    print(f"Warning: No label file found at {label_path}")

# Calculate and draw IoU for each pair of boxes
for gt_box in gt_boxes:
    gt_cls_id, gt_x1, gt_y1, gt_x2, gt_y2 = gt_box
    
    for pred_box in pred_boxes:
        pred_cls_id, pred_x1, pred_y1, pred_x2, pred_y2, conf = pred_box
        
        # Calculate IoU
        iou = calculate_iou([gt_x1, gt_y1, gt_x2, gt_y2], 
                           [pred_x1, pred_y1, pred_x2, pred_y2])
        
        # If boxes overlap, draw IoU
        if iou > 0.01:  # Only show non-trivial overlaps
            # Get centroid of overlap area
            overlap_x = (max(gt_x1, pred_x1) + min(gt_x2, pred_x2)) // 2
            overlap_y = (max(gt_y1, pred_y1) + min(gt_y2, pred_y2)) // 2
            
            # Draw IoU value
            iou_text = f"IoU: {iou:.2f}"
            cv2.putText(img, iou_text, (overlap_x, overlap_y), 
                        cv2.FONT_HERSHEY_SIMPLEX, 0.6, (255, 255, 0), 2)
            
            print(f"IoU between GT {class_names[gt_cls_id]} and Pred {class_names[pred_cls_id]}: {iou:.4f}")

# Save the initial comparison image
cv2.imwrite("prediction_vs_groundtruth.jpg", img)
print(f"Saved comparison to prediction_vs_groundtruth.jpg")

# Variables for zooming
zoom_factor = 1.0
zoom_center_x = img_width // 2
zoom_center_y = img_height // 2
max_zoom = 10.0
min_zoom = 1.0

def zoom_image(img, factor, center_x, center_y):
    """Zoom into an image at specified center with given factor"""
    h, w = img.shape[:2]
    
    # Calculate ROI size
    roi_w = int(w / factor)
    roi_h = int(h / factor)
    
    # Calculate ROI corner points
    x1 = max(0, int(center_x - roi_w // 2))
    y1 = max(0, int(center_y - roi_h // 2))
    
    # Adjust if ROI exceeds image boundaries
    if x1 + roi_w > w:
        x1 = w - roi_w
    if y1 + roi_h > h:
        y1 = h - roi_h
    
    # Extract ROI
    roi = img[y1:y1+roi_h, x1:x1+roi_w]
    
    # Resize ROI back to original image size
    zoomed = cv2.resize(roi, (w, h), interpolation=cv2.INTER_LINEAR)
    return zoomed

def on_mouse(event, x, y, flags, param):
    global zoom_factor, zoom_center_x, zoom_center_y, img
    
    if event == cv2.EVENT_MOUSEWHEEL:
        # Mouse wheel up (zoom in)
        if flags > 0:
            zoom_factor = min(max_zoom, zoom_factor * 1.1)
        # Mouse wheel down (zoom out)
        else:
            zoom_factor = max(min_zoom, zoom_factor / 1.1)
        
    elif event == cv2.EVENT_LBUTTONDOWN:
        # Set new zoom center
        zoom_center_x = x
        zoom_center_y = y

    # Update zoomed image
    display_img = zoom_image(img, zoom_factor, zoom_center_x, zoom_center_y)
    cv2.putText(display_img, f"Zoom: {zoom_factor:.1f}x", (20, 30), 
                cv2.FONT_HERSHEY_SIMPLEX, 0.7, (0, 255, 255), 2)
    cv2.imshow("Prediction vs Ground Truth (Scroll to zoom, click to center)", display_img)

# Create window and set mouse callback
cv2.namedWindow("Prediction vs Ground Truth (Scroll to zoom, click to center)")
cv2.setMouseCallback("Prediction vs Ground Truth (Scroll to zoom, click to center)", on_mouse)

# Initial display
cv2.imshow("Prediction vs Ground Truth (Scroll to zoom, click to center)", img)
print("Instructions:")
print("- Scroll mouse wheel to zoom in/out")
print("- Click to set the center point for zooming")
print("- Press 'q' or ESC to exit")

# Wait for key press
while True:
    key = cv2.waitKey(0) & 0xFF
    if key == ord('q') or key == 27:  # 'q' or ESC
        break

cv2.destroyAllWindows()
