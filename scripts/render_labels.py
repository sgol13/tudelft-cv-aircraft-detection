import argparse
import xml.etree.ElementTree as ET
import cv2
import os


def parse_cvat_annotations(xml_path):
    tree = ET.parse(xml_path)
    root = tree.getroot()

    annotations_by_frame = {}

    for track in root.findall("track"):
        label = track.get("label")

        for box in track.findall("box"):
            frame_id = int(box.get("frame"))
            x1 = float(box.get("xtl"))
            y1 = float(box.get("ytl"))
            x2 = float(box.get("xbr"))
            y2 = float(box.get("ybr"))
            occluded = int(box.get("occluded"))

            if frame_id not in annotations_by_frame:
                annotations_by_frame[frame_id] = []

            annotations_by_frame[frame_id].append({
                "bbox": (int(x1), int(y1), int(x2), int(y2)),
                "label": label,
                "occluded": occluded
            })

    return annotations_by_frame



def render_labels(video_path: str, labels_path: str, output_path):
    annotations_by_frame = parse_cvat_annotations(labels_path)

    cap = cv2.VideoCapture(video_path)
    if not cap.isOpened():
        raise ValueError(f"Cannot open video file {video_path}")

    fps = int(cap.get(cv2.CAP_PROP_FPS))
    frame_width = int(cap.get(cv2.CAP_PROP_FRAME_WIDTH))
    frame_height = int(cap.get(cv2.CAP_PROP_FRAME_HEIGHT))
    rotation_flag = cap.get(cv2.CAP_PROP_ORIENTATION_META)

    os.makedirs(os.path.dirname(output_path), exist_ok=True)

    if rotation_flag in [90, 270]:
        frame_width, frame_height = frame_height, frame_width

    out = cv2.VideoWriter(output_path, cv2.VideoWriter_fourcc(*"avc1"), fps, (frame_width, frame_height))

    frame_id = 0
    while cap.isOpened():
        ret, frame = cap.read()
        if not ret:
            break

        if rotation_flag == 90:
            frame = cv2.rotate(frame, cv2.ROTATE_90_CLOCKWISE)
        elif rotation_flag == 180:
            frame = cv2.rotate(frame, cv2.ROTATE_180)
        elif rotation_flag == 270:
            frame = cv2.rotate(frame, cv2.ROTATE_90_COUNTERCLOCKWISE)

        overlay = frame.copy()

        if frame_id in annotations_by_frame:
            for ann in annotations_by_frame[frame_id]:
                x1, y1, x2, y2 = ann["bbox"]
                label = ann["label"]
                occluded = ann["occluded"]

                opacity = 0.3
                color = (0, 255, 0) if not occluded else (0, 0, 255)

                # draw a semi-transparent rectangle on the overlay
                cv2.rectangle(frame, (x1, y1), (x2, y2), color, thickness=1)

                # blend the overlay with the original frame
                frame = cv2.addWeighted(overlay, opacity, frame, 1 - opacity, 0)

                cv2.putText(frame, label, (x1, y1 - 5), cv2.FONT_HERSHEY_SIMPLEX, 0.5, color, 1)

        out.write(frame)
        frame_id += 1

    cap.release()
    out.release()
    cv2.destroyAllWindows()




def main():
    parser = argparse.ArgumentParser(description='Render a video with given labels (CVAT format).')
    parser.add_argument('video', type=str, help='Path to the video file')
    parser.add_argument('labels', type=str, help='Path to the CVAT XML annotation file')
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
