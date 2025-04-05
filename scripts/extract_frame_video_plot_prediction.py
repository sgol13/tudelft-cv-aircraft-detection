import cv2
import xml.etree.ElementTree as ET
import numpy as np

def parse_cvat_annotations(xml_file, frame_number):
    """Parses the CVAT XML annotation file and extracts bounding boxes for the given frame."""
    tree = ET.parse(xml_file)
    root = tree.getroot()
    bboxes = []
    
    for track in root.findall("track"):
        label = track.get("label")
        for box in track.findall("box"):
            frame = int(box.get("frame"))
            if frame == frame_number:
                xtl = float(box.get("xtl"))
                ytl = float(box.get("ytl"))
                xbr = float(box.get("xbr"))
                ybr = float(box.get("ybr"))
                bboxes.append((label, xtl, ytl, xbr, ybr))
    
    return bboxes

def draw_bboxes_on_frame(frame, bboxes):
    """Draws bounding boxes on a video frame."""
    for label, xtl, ytl, xbr, ybr in bboxes:
        cv2.rectangle(frame, (int(xtl), int(ytl)), (int(xbr), int(ybr)), (0, 255, 0), 1)
        # cv2.putText(frame, label, (int(xtl), int(ytl) - 5), cv2.FONT_HERSHEY_SIMPLEX, 0.5, (0, 255, 0), 2)
    return frame

def process_video(video_path, xml_path, frame_number, output_image):
    """Extracts a specific frame from the video, overlays CVAT bounding boxes, and saves it."""
    cap = cv2.VideoCapture(video_path)
    rotation_flag = cap.get(cv2.CAP_PROP_ORIENTATION_META)
    cap.set(cv2.CAP_PROP_POS_FRAMES, frame_number)
    success, frame = cap.read()
    cap.release()
    
    if not success:
        print(f"Error: Could not read frame {frame_number} from {video_path}")
        return
    if rotation_flag == 90:
        frame = cv2.rotate(frame, cv2.ROTATE_90_CLOCKWISE)
    elif rotation_flag == 180:
        frame = cv2.rotate(frame, cv2.ROTATE_180)
    elif rotation_flag == 270:
        frame = cv2.rotate(frame, cv2.ROTATE_90_COUNTERCLOCKWISE)
    
    bboxes = parse_cvat_annotations(xml_path, frame_number)
    annotated_frame = draw_bboxes_on_frame(frame, bboxes)
    cv2.imwrite(output_image, annotated_frame)
    print(f"Saved annotated frame {frame_number} as {output_image}")

# Example usage
process_video("./data/videos/bb7da541.mp4", "./labels/bb7da541.xml", 10, "output_frame_aircraft.jpg")
