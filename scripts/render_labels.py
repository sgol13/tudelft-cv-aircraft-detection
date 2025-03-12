import argparse
import json
import cv2
import os


def render_labels(video_path: str, labels_path: str, output_path: str):
    with open(labels_path) as f:
        coco_data = json.load(f)

    # Create a mapping from category_id to category name
    category_map = {category["id"]: category["name"] for category in coco_data["categories"]}

    # Map image ID to annotations
    annotations_by_image = {}
    for ann in coco_data["annotations"]:
        image_id = ann["image_id"]
        if image_id not in annotations_by_image:
            annotations_by_image[image_id] = []
        annotations_by_image[image_id].append(ann)

    cap = cv2.VideoCapture(video_path)

    if not cap.isOpened():
        raise ValueError(f"Cannot open video file {video_path}")

    # Get video properties
    fps = int(cap.get(cv2.CAP_PROP_FPS))
    frame_width = int(cap.get(cv2.CAP_PROP_FRAME_WIDTH))
    frame_height = int(cap.get(cv2.CAP_PROP_FRAME_HEIGHT))

    # Ensure output directory exists
    os.makedirs(os.path.dirname(output_path), exist_ok=True)

    # Define output video writer
    out = cv2.VideoWriter(output_path, cv2.VideoWriter_fourcc(*"mp4v"), fps, (frame_width, frame_height))

    frame_id = 1
    while cap.isOpened():
        ret, frame = cap.read()
        if not ret:
            break  # End of video

        # hack to solve the upside-down videos issue
        rotation_flag = cap.get(cv2.CAP_PROP_ORIENTATION_META)
        if rotation_flag == 180:
            frame = cv2.rotate(frame, cv2.ROTATE_180)

        # Draw bounding boxes if annotations exist for this frame
        if frame_id in annotations_by_image:

            for ann in annotations_by_image[frame_id]:
                x, y, w, h = map(int, ann["bbox"])
                category_id = ann["category_id"]

                # Check if the object is occluded
                is_occluded = ann["attributes"].get("occluded", False)

                # Choose color based on occlusion status
                color = (0, 0, 255) if is_occluded else (0, 255, 0)  # Red for occluded, Green for non-occluded
                thickness = 1

                # Get category name
                category_name = category_map.get(category_id, "Unknown")

                # Draw rectangle (bounding box)
                cv2.rectangle(frame, (x, y), (x + w, y + h), color, thickness)

                # Draw label
                label = f"{category_name}"
                cv2.putText(frame, label, (x, y - 5), cv2.FONT_HERSHEY_SIMPLEX, 0.5, color, thickness)

        # Write frame to output video
        out.write(frame)
        frame_id += 1

    cap.release()
    out.release()
    cv2.destroyAllWindows()


def main():
    parser = argparse.ArgumentParser(description='Render a video with given labels (COCO 1.0 format).')
    parser.add_argument('video', type=str, help='Path to the video file')
    parser.add_argument('labels', type=str, help='Path to the labels file')
    parser.add_argument('--output', type=str, help='Output directory (labels dir by default)', default=None)

    args = parser.parse_args()

    if args.output is None:
        args.output = os.path.dirname(args.labels)

    video_filename = os.path.basename(args.video)
    video_name, video_ext = os.path.splitext(video_filename)
    output_filename = f"{video_name}_labeled{video_ext}"
    output_path = os.path.join(args.output, output_filename)

    render_labels(args.video, args.labels, output_path)

    print(f"Rendering complete! Saved as {output_path}")


if __name__ == "__main__":
    main()