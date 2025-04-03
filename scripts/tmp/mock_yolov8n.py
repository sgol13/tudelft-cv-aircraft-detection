from ultralytics import YOLO

model = YOLO('yolov8n.pt')

# model.export(format='tflite', imgsz=1920, int8=False, half=True)

class_names = model.names
print(model.names)

# Save class names to labels.txt
with open('labels.txt', 'w') as f:
    for name in class_names.values():
        f.write(f"{name}\n")

