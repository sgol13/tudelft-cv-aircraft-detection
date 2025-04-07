from ultralytics import YOLO

# Load your partially trained model
model = YOLO('aircraft_detection/960_2/weights/best.pt')  # adjust the path to your weight file

# Run validation on your test dataset
results = model.val(data='path/to/your/data.yaml')
