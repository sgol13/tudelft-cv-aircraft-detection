import argparse
import logging
from ultralytics import YOLO

# Configure logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

def parse_args():
    parser = argparse.ArgumentParser(description='Train YOLOv8 for aircraft detection')
    parser.add_argument('--data', type=str, required=True, help='Path to data.yaml file')
    parser.add_argument('--weights', type=str, default='yolov8n.pt', help='Initial weights path')
    parser.add_argument('--epochs', type=int, default=100, help='Number of training epochs')
    parser.add_argument('--batch-size', type=int, default=16, help='Batch size')
    parser.add_argument('--img-size', type=int, default=1280, help='Image size')
    parser.add_argument('--device', type=str, default=0, help='cuda device, i.e. 0 or 0,1,2,3 or cpu')
    parser.add_argument('--project', type=str, default='aircraft_detection', help='Project name')
    parser.add_argument('--name', type=str, default='yolov8n_finetune', help='Experiment name')
    parser.add_argument('--resume', action='store_true', help='Resume training from last checkpoint')
    return parser.parse_args()

def main():
    args = parse_args()
    
    # Load the pre-trained YOLOv8 model
    logger.info(f"Loading YOLOv8 model from {args.weights}")
    model = YOLO(args.weights)
    
    # Set up training
    logger.info("Starting training...")
    results = model.train(
        data=args.data,
        epochs=args.epochs,
        imgsz=args.img_size,
        batch=args.batch_size,
        device=args.device,
        workers=8,
        pretrained=True,
        optimizer='Adam',
        lr0=0.001,
        lrf=0.01,
        momentum=0.937,
        weight_decay=0.0005,
        warmup_epochs=3.0,
        warmup_momentum=0.8,
        warmup_bias_lr=0.1,
        box=7.5,
        cls=0.5,
        dfl=1.5,
        degrees=5.0,
        translate=0.1,
        scale=0.5,
        shear=0.0,
        perspective=0.0,
        flipud=0.0,
        fliplr=0.5,
        mosaic=1.0,
        mixup=0.1,
        copy_paste=0.0,
        auto_augment='randaugment',
        project=args.project,
        name=args.name,
        resume=args.resume
    )
    
    # Evaluate the model
    logger.info("Evaluating model...")
    metrics = model.val()
    logger.info(f"Validation results:")
    logger.info(f"  mAP50: {metrics.box.map50:.4f}")
    logger.info(f"  mAP50-95: {metrics.box.map:.4f}")
    
    logger.info(f"Training complete! Results saved to {args.project}/{args.name}")

if __name__ == "__main__":
    main()