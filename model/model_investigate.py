from ultralytics import YOLO

# Load the pre-trained YOLOv8 nano model
# This will automatically download the model weights if needed
model = YOLO('yolov8n.pt')
print(model.model.model)
