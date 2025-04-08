

if __name__ == '__main__':
    from ultralytics import YOLO

    # Load your partially trained model
    model = YOLO('./aircraft_detection/960_2/weights/best.pt')  # adjust the path to your weight file

    # Run validation on your test dataset
    results = model.val(data="datasets_960_2/data.yaml", split="test", conf=0.25, iou=0.7)
