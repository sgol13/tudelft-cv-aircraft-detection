import argparse
import logging
from ultralytics import YOLO
import torch
# Configure logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

def parse_args():
    parser = argparse.ArgumentParser(description='Train YOLOv8 for aircraft detection')
    parser.add_argument('--data', type=str, required=True, help='Path to data.yaml file')
    parser.add_argument('--weights', type=str, default='yolov8n.pt', help='Initial weights path')
    parser.add_argument('--epochs', type=int, default=10, help='Number of training epochs')
    parser.add_argument('--batch-size', type=int, default=24, help='Batch size')
    parser.add_argument('--img-size', type=int, default=960, help='Image size')
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
    if torch.cuda.is_available():
        device_count = torch.cuda.device_count()
        current_device = torch.cuda.current_device()
        device_name = torch.cuda.get_device_name(current_device)
        
        logger.info(f"CUDA is available! Found {device_count} device(s)")
        logger.info(f"Current device: {current_device} - {device_name}")
        
        # Show device properties
        device_props = torch.cuda.get_device_properties(current_device)
        logger.info(f"GPU Memory: {device_props.total_memory / 1024**3:.2f} GB")
        logger.info(f"CUDA Capability: {device_props.major}.{device_props.minor}")
        
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
        degrees=0.0,
        translate=0.1,
        scale=0.2,
        shear=0.0,
        perspective=0.0,
        flipud=0.0,
        fliplr=0.5,
        mosaic=1.0,
        mixup=0.0,
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