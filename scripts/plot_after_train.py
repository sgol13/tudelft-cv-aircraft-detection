from ultralytics import YOLO
import cv2

# Load your trained model
model = YOLO('./aircraft_detection/yolov8n_finetune6/weights/best.pt')

# Path to test image
image_path = './datasets/yolo_data/train/images/3cdfa11e_000002.jpg'

# Run inference
results = model(image_path, save=True, conf=0.25)  # Will save to runs/detect/predict

# If you want to display the image with predictions
result = results[0]
boxes = result.boxes  # Bounding boxes
        
# Get the plotted image with detections
plotted_img = result.plot()

# Display the image
cv2.imshow("Aircraft Detection", plotted_img)
cv2.waitKey(0)  # Wait until a key is pressed
cv2.destroyAllWindows()