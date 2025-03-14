import argparse
import os
from typing import List

import fiftyone as fo
from tempfile import TemporaryDirectory
import xml.etree.ElementTree as ET
from tqdm import tqdm

from common import VIDEOS_DIR, RENDERED_LABELS_DIR
from render_labels import render_labels


def get_all_files(labels_path: str, extension: str):
    assert extension.startswith('.')

    xml_files = []
    for root, dirs, files in os.walk(labels_path):
        for file in files:
            if file.endswith(extension):
                xml_files.append(os.path.join(root, file))

    return xml_files

def prepare_videos(xml_files: List[str], output_dir: str):

    for xml_file in tqdm(xml_files, desc='Rendering videos'):
        video_name = os.path.basename(xml_file).split(".")[0]
        video_path = os.path.join(VIDEOS_DIR, video_name) + '.mp4'
        output_path = os.path.join(output_dir, video_name) + '.mp4'

        if not os.path.exists(output_path):
            render_labels(video_path, xml_file, output_path)


def start_fiftyone(videos_dir: str):
    dataset = fo.Dataset.from_videos_dir(videos_dir)

    for sample in dataset:
        sample["name"] = os.path.basename(sample.filepath)
        sample.save()

    session = fo.launch_app(dataset)
    session.wait()


def preview(labels_path: str, clean: bool):
    xml_files = get_all_files(labels_path, '.xml')

    output_dir = os.path.join(RENDERED_LABELS_DIR, labels_path.replace('/', '_'))

    os.makedirs(output_dir, exist_ok=True)
    if clean:
        os.system(f"rm -rf {output_dir}")

    prepare_videos(xml_files, output_dir)
    start_fiftyone(output_dir)



def main():
    parser = argparse.ArgumentParser(description='Preview videos in fiftyone.')
    parser.add_argument('path', type=str, help='Path to a directory with labels to preview')
    parser.add_argument('-c', '--clean', action='store_true', help='Rerender all videos')

    args = parser.parse_args()

    preview(args.path, args.clean)


if __name__ == "__main__":
    main()
