from ultralytics import YOLO

model = YOLO('yolov8n.pt')

model.export(format='torchscript', imgsz=960, int8=False)

class_names = model.names
print(class_names)

with open('labels.txt', 'w') as f:
    for name in class_names.values():
        f.write(f"{name}\n")
