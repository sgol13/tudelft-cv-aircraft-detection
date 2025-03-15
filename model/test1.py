from ultralytics import YOLO
import torch
print(f"CUDA available: {torch.cuda.is_available()}")
print(f"CUDA version: {torch.version.cuda}")

# Load the pre-trained YOLOv8 nano model
# This will automatically download the model weights if needed
model = YOLO('yolov8n.pt')

# Run inference on an image
results = model('./plane_sky_visible.jpg', device=0)  # or use a URL
print(results)
# Display or process results
for r in results:
    print(f"Detected {len(r.boxes)} objects")

# Visualize results
results[0].show()  # Displays the image with detections overlaid
