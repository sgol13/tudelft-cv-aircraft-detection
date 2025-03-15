#!/usr/bin/env python3
# simple_aircraft_finetune.py

import os
import argparse
import torch
from ultralytics import YOLO
import logging

# Configure logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

def parse_args():
    parser = argparse.ArgumentParser(description='Fine-tune YOLOv8n for aircraft detection')
    parser.add_argument('--data', type=str, required=True, help='Path to data.yaml file')
    parser.add_argument('--weights', type=str, default='yolov8n.pt', help='Initial weights path')
    parser.add_argument('--epochs', type=int, default=100, help='Number of training epochs')
    parser.add_argument('--batch-size', type=int, default=16, help='Batch size')
    parser.add_argument('--img-size', type=int, default=1280, help='Image size (higher helps with tiny objects)')
    parser.add_argument('--device', type=str, default='', help='cuda device, i.e. 0 or 0,1,2,3 or cpu')
    parser.add_argument('--project', type=str, default='aircraft_detection', help='Project name')
    parser.add_argument('--name', type=str, default='yolov8n_finetune', help='Experiment name')
    parser.add_argument('--patience', type=int, default=20, help='Early stopping patience')
    parser.add_argument('--freeze', type=int, default=0, help='Number of layers to freeze (0=none)')
    parser.add_argument('--save-period', type=int, default=10, help='Save checkpoint every x epochs')
    parser.add_argument('--resume', type=str, default=None, help='Resume training from checkpoint')
    return parser.parse_args()

def freeze_model_layers(model, num_layers_to_freeze):
    """Freeze the first n layers of the model"""
    if num_layers_to_freeze <= 0:
        logger.info("No layers frozen")
        return model
    
    logger.info(f"Freezing the first {num_layers_to_freeze} layers")
    
    # For each layer up to the specified number
    for i, layer in enumerate(model.model.model[:num_layers_to_freeze]):
        for param in layer.parameters():
            param.requires_grad = False
            
        logger.info(f"Froze layer {i}: {layer.__class__.__name__}")
    
    # Log summary of frozen vs trainable parameters
    trainable_params = sum(p.numel() for p in model.parameters() if p.requires_grad)
    total_params = sum(p.numel() for p in model.parameters())
    logger.info(f"Trainable parameters: {trainable_params:,} of {total_params:,} ({trainable_params/total_params:.2%})")
    
    return model

def main():
    args = parse_args()
    
    # Load the pre-trained YOLOv8n model
    logger.info(f"Loading YOLOv8 model from {args.weights}")
    model = YOLO(args.weights)
    
    # Freeze layers if specified
    if args.freeze > 0:
        model = freeze_model_layers(model, args.freeze)
    
    # Set up training hyperparameters optimized for tiny aircraft detection
    logger.info("Starting training...")
    results = model.train(
        data=args.data,
        epochs=args.epochs,
        imgsz=args.img_size,
        batch=args.batch_size,
        patience=args.patience,
        device=args.device,
        workers=8,  # Adjust based on your CPU 
        pretrained=True,
        optimizer='Adam',  # Adam optimizer works well for fine-tuning
        lr0=0.001,  # Starting learning rate
        lrf=0.01,   # Final learning rate factor
        momentum=0.937,
        weight_decay=0.0005,
        warmup_epochs=3.0,
        warmup_momentum=0.8,
        warmup_bias_lr=0.1,
        box=7.5,    # Box loss gain
        cls=0.5,    # Classification loss gain
        dfl=1.5,    # Distribution focal loss gain
        fl_gamma=2.0,  # Focal loss gamma (higher helps with tiny objects)
        hsv_h=0.015,  # HSV augmentation for hue
        hsv_s=0.7,    # HSV augmentation for saturation (helps with sky color variations)
        hsv_v=0.4,    # HSV augmentation for brightness
        degrees=5.0,  # Rotation augmentation (small for aircraft orientation)
        translate=0.1,
        scale=0.5,    # Scale augmentation (helps with tiny objects)
        shear=0.0,    # No shear for aircraft
        perspective=0.0,  # No perspective change for aircraft
        flipud=0.0,   # No vertical flip for aircraft (rare to see upside-down)
        fliplr=0.5,   # Horizontal flip OK
        mosaic=1.0,   # Mosaic augmentation (helps with rare classes)
        mixup=0.1,    # Mixup augmentation
        copy_paste=0.0,  # No copy-paste for aircraft
        auto_augment='randaugment',  # Use random augmentation
        project=args.project,
        name=args.name,
        exist_ok=True,
        save_period=args.save_period,
        resume=args.resume,
        verbose=True,
    )
    
    # Evaluate the model on the validation set
    logger.info("Evaluating model...")
    metrics = model.val()
    logger.info(f"Validation results:")
    logger.info(f"  mAP50: {metrics.box.map50:.4f}")
    logger.info(f"  mAP50-95: {metrics.box.map:.4f}")
    
    # Save the model
    logger.info("Saving model...")
    model.export(format='onnx', dynamic=True, simplify=True)
    
    logger.info(f"Training complete! Results saved to {os.path.join(args.project, args.name)}")

if __name__ == "__main__":
    main()