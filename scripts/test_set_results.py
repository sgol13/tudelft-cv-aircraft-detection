if __name__ == '__main__':
    from ultralytics import YOLO

    # Load your partially trained model
    model = YOLO("D:\\code-projects\\Python_projects\\tudelft-cv-aircraft-detection\\aircraft_detection\\yolov8n_finetune11_960_2\\weights\\best.pt")  # adjust the path to your weight file

    # Run validation on test set
    results = model.val(data="D:\\code-projects\\Python_projects\\tudelft-cv-aircraft-detection\\datasets_960_2_fixed\\data.yaml", split='test', iou=0.1)