import argparse
import os
from typing import List

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

def render_videos(xml_files: List[str]):
    video_names = [os.path.basename(file).split(".")[0] for file in xml_files]

    for video in video_names


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
    xml_files = get_all_files(labels_path, '.xml')

    with TemporaryDirectory() as temp_dir:
        print(f"Temp directory: {temp_dir}")

        render_videos(xml_files)
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
