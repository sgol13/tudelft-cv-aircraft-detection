import argparse
import os
import fiftyone as fo
from tempfile import TemporaryDirectory
import xml.etree.ElementTree as ET

from common import VIDEOS_DIR


def get_all_files(labels_path: str, extension: str):
    assert extension.startswith('.')

    xml_files = []
    for root, dirs, files in os.walk(labels_path):
        for file in files:
            if file.endswith(extension):
                xml_files.append(os.path.join(root, file))

    return xml_files


def increment_frame_ids(root: ET.Element):
    """
    CVAT format uses 0-based frame IDs. Increment them by 1 to match fiftyone's 1-based frame IDs.
    """
    for box in root.findall(".//box"):
        frame = int(box.get("frame"))
        box.set("frame", str(frame + 1))


def mark_occluded_frames(root: ET.Element):
    removed_bboxes = []

    for track in root.findall(".//track"):
        bboxes = track.findall("box")
        for box in bboxes:
            if box.get("occluded") == "1":
                removed_bboxes.append((track.get("label"), box))
                track.remove(box)

        # if removed_bboxes:
        #     new_track = ET.Element("track", {
        #         "id": str(len(root.findall(".//track"))),
        #         "label": f"{removed_bboxes[0][0]}[x]",
        #         "source": "file"
        #     })
        #     for _, box in removed_bboxes:
        #         new_track.append(box)
        #     root.append(new_track)


def start_fiftyone(videos_path: str, labels_path: str):
    dataset = fo.Dataset.from_dir(
        dataset_type=fo.types.CVATVideoDataset,
        data_path=videos_path,
        labels_path=labels_path,
        progress=True
    )

    for sample in dataset:
        sample["name"] = os.path.basename(sample.filepath)
        sample.save()

    session = fo.launch_app(dataset)
    session.wait()


def preview(labels_path: str):
    xml_files = get_all_files(labels_path)
    videos = [file.split(".")[0] for file in xml_files]
    print(videos)

    with TemporaryDirectory() as temp_dir:
        print(f"Temp directory: {temp_dir}")
        # for xml_file in xml_files:
        #     tree = ET.parse(xml_file)
        #
        #     root = tree.getroot()
        #     increment_frame_ids(root)
        #     mark_occluded_frames(root)
        #
        #     temp_file_path = os.path.join(temp_dir, os.path.basename(xml_file))
        #     tree.write(temp_file_path)

        # start_fiftyone(VIDEOS_DIR, temp_dir)



def main():
    parser = argparse.ArgumentParser(description='Preview videos in fiftyone.')
    parser.add_argument('path', type=str, help='Path to a directory with labels to preview')

    args = parser.parse_args()

    preview(args.path)


if __name__ == "__main__":
    main()
