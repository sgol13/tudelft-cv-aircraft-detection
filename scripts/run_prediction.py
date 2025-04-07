import os
import csv
import numpy as np
from ultralytics import YOLO
from pathlib import Path
import glob
from tqdm import tqdm

def create_predictions_csv(model_path, images_folder, output_csv):
    """
    Generate CSV with predictions from YOLOv8 model in YOLO format (normalized)
    
    Args:
        model_path: Path to the YOLOv8 weights file
        images_folder: Folder containing images to predict on
        output_csv: Path to save the predictions CSV
    """
    # Load the YOLOv8 model
    model = YOLO(model_path)
    
    # Create CSV file
    with open(output_csv, 'w', newline='') as f:
        writer = csv.writer(f)
        writer.writerow(['image_name', 'class_id', 'confidence', 
                         'x_center', 'y_center', 'width', 'height'])
        
        # Get all image files from the folder
        image_extensions = ['*.jpg', '*.jpeg', '*.png', '*.bmp']
        image_paths = []
        for ext in image_extensions:
            image_paths.extend(glob.glob(os.path.join(images_folder, ext)))

        # Run YOLOv8 inference
        results = model(images_folder, stream=True, verbose=False)

        image_count = len(os.listdir(images_folder))

        with tqdm(total=image_count) as bar:
            # Get normalized xywh boxes (YOLO format), confidence scores, and class IDs
            for result in results:
                img_name = os.path.basename(result.path)
                if result.boxes is not None and len(result.boxes) > 0:
                    # Get the boxes in normalized xywh format (YOLO format)
                    boxes = result.boxes.xywhn.cpu().numpy()  # normalized xywh format
                    conf = result.boxes.conf.cpu().numpy()
                    cls_ids = result.boxes.cls.cpu().numpy().astype(int)

                    # Get class names if available
                    # if hasattr(result.names, 'values'):
                    #     cls_names = [result.names[c] for c in cls_ids]
                    # else:
                    #     cls_names = [f"class_{c}" for c in cls_ids]

                    # Write predictions to CSV in YOLO format
                    for i in range(len(boxes)):
                        x_center, y_center, width, height = boxes[i]
                        writer.writerow([
                            img_name,
                            cls_ids[i],
                            conf[i],
                            x_center, y_center, width, height
                        ])
                else:
                    # No detections for this image
                    writer.writerow([img_name, -1, 0.0, 0, 0, 0, 0])
                bar.update()

def create_ground_truth_csv(labels_folder, output_csv, class_mapping=None):
    """
    Generate CSV with ground truth from YOLO format labels
    Keep original YOLO format (normalized x_center, y_center, width, height)
    
    Args:
        labels_folder: Folder containing ground truth label files
        output_csv: Path to save the ground truth CSV
        class_mapping: Optional dictionary mapping class IDs to names
    """
    # Create CSV file
    with open(output_csv, 'w', newline='') as f:
        writer = csv.writer(f)
        writer.writerow(['image_name', 'class_id', 
                         'x_center', 'y_center', 'width', 'height'])
        
        # Get all label files
        label_files = glob.glob(os.path.join(labels_folder, '*.txt'))
        
        # Process each label file
        for label_path in label_files:
            # Get corresponding image name (assuming same name, different extension)
            base_name = os.path.basename(label_path).replace('.txt', '')
            img_name = base_name + '.jpg'  # Default to jpg, could check multiple extensions
            
            # Read the label file
            with open(label_path, 'r') as lf:
                lines = lf.readlines()
                
                if not lines:
                    # Empty label file (no objects)
                    writer.writerow([img_name, -1, 0, 0, 0, 0])
                    continue
                
                # Process each label line - keep in original YOLO format
                for line in lines:
                    parts = line.strip().split()
                    if len(parts) >= 5:
                        class_id = int(parts[0])
                        # YOLO format: class_id, x_center, y_center, width, height (normalized)
                        x_center, y_center, width, height = map(float, parts[1:5])
                        
                        # Get class name if mapping is provided
                        # class_name = class_mapping.get(class_id, f"class_{class_id}") if class_mapping else f"class_{class_id}"
                        
                        # Write to CSV in original YOLO format
                        writer.writerow([
                            img_name,
                            class_id,
                            x_center, y_center, width, height
                        ])

if __name__ == "__main__":
    process_queue = {
        "640_2": "datasets_640_2",
        "640_4": "datasets_640_2",
        "640_8": "datasets_640_2",
        "640_16": "datasets_640_2",
        "640_32": "datasets_640_2",
        "960_2": "datasets_960_2",
        "960_2_loose": "datasets_960_2",
        "960_2_split_25": "datasets_960_2",
        "960_2_split_50": "datasets_960_2",
        "960_2_split_75": "datasets_960_2",
        "1440_2": "datasets_1440_2",
        "1920_2": "datasets_1920_2"
    }

    for key, value in process_queue.items():
        # Set paths
        model_weights = f"./aircraft_detection/{key}/weights/best.pt"  # Path to your YOLOv8 nano weights
        images_folder = f"./{value}/test/images"  # Path to your images folder
        labels_folder = f"./{value}/test/labels"  # Path to your ground truth labels folder

        # Optional: Define class mapping (class_id -> class_name)
        # If you have a specific class mapping, define it here
        # Example: {0: 'person', 1: 'car', 2: 'dog', ...}
        class_mapping = None

        # Generate CSVs - both in YOLO format
        create_predictions_csv(model_weights, images_folder, f"results/{key}/predictions.csv")
        create_ground_truth_csv(labels_folder, f"results/{key}/ground_truth.csv", class_mapping)

        print(f"Completed {key}")
    