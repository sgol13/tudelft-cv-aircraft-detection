import argparse
import os
import shutil
from typing import List
import re
import requests
import csv

from tqdm import tqdm

from common import VIDEOS_DIR, LABELING_DIR
from render_labels import render_labels


def get_task_path(task_id: str):
    return os.path.join(LABELING_DIR, task_id)


def fetch_task_filenames_from_spreadsheet(task_id: str) -> List[str]:
    file_id = "1hAqC2Pz3xIEqdslCMa91_bKWBSlOHUs2sL5UKU8Wr7c"
    gid = "216287426"
    csv_url = f"https://docs.google.com/spreadsheets/d/{file_id}/export?format=csv&gid={gid}"

    response = requests.get(csv_url)
    response.raise_for_status()  # Raise error if request fails

    rows = list(csv.reader(response.text.splitlines()))

    # for it, row in enumerate(rows):
    #     print(it, row[:6])

    try:
        column_index = rows[0].index(task_id)
    except ValueError:
        raise ValueError(f"Task {task_id} does not exist.")

    task_column = [row[column_index] for row in rows]

    try:
        videos_row_index = task_column.index('videos')
    except ValueError:
        raise ValueError(f"[spreadsheet error]: 'videos' row not found in the task {task_id} column.")

    task_content = task_column[videos_row_index + 1:]
    task_content = [v for v in task_content if v]

    return task_content


def copy_videos_to_task(task_videos_dir: str, filenames: List[str], all_videos_dir: str):
    existing_files = set(os.listdir(task_videos_dir))
    files_to_copy = set(filenames) - existing_files

    if not files_to_copy:
        return 0

    for filename in tqdm(files_to_copy, desc="Copying task videos"):
        src_path = os.path.join(all_videos_dir, filename)
        dest_path = os.path.join(task_videos_dir, filename)
        if os.path.exists(src_path):
            shutil.copy(src_path, dest_path)
        else:
            raise RuntimeError(f"File {src_path} does not exist")

    return len(files_to_copy)


def remove_extra_files(task_videos_dir: str, filenames: List[str]):
    existing_files = set(os.listdir(task_videos_dir))
    extra_files = existing_files - set(filenames)

    if not extra_files:
        return 0

    for filename in tqdm(extra_files, desc="Removing extra files"):
        file_path = os.path.join(task_videos_dir, filename)
        os.remove(file_path)

    return len(extra_files)


def update_task(task_id: str):
    filenames = fetch_task_filenames_from_spreadsheet(task_id)
    print(f"TASK {task_id}\n{len(filenames)} videos")

    task_path = get_task_path(task_id)
    task_videos_path = os.path.join(task_path, 'videos')
    os.makedirs(task_videos_path, exist_ok=True)
    os.makedirs(os.path.join(task_path, 'cvat'), exist_ok=True)

    num_copied = copy_videos_to_task(task_videos_path, filenames, VIDEOS_DIR)
    num_removed = remove_extra_files(task_videos_path, filenames)

    print(f"Updated: {num_copied} added, {num_removed} removed")


def extract_video_name_from_zip_name(filename: str) -> str:
    try:
        name = re.search(r'task_(\w+)\.mp4', filename).group(1)
    except AttributeError:
        raise ValueError(f"Invalid zip name: {filename}")
    return name


def unzip_cvat_labels(cvat_dir: str, output_dir: str):
    zip_files = [file for file in os.listdir(cvat_dir) if file.endswith('.zip')]

    videos_to_filenames = {}
    for zip_file in tqdm(zip_files, desc="Unzipping CVAT annotations"):
        video_name = extract_video_name_from_zip_name(zip_file)

        if video_name in videos_to_filenames:
            raise ValueError(
                f"Duplicate labels for the video: {video_name} [{zip_file}] [{videos_to_filenames[video_name]}]")
        videos_to_filenames[video_name] = zip_file

        shutil.unpack_archive(os.path.join(cvat_dir, zip_file), output_dir)

        shutil.move(os.path.join(output_dir, 'annotations.xml'),
                    os.path.join(output_dir, f'{video_name}.xml'))


def verify_task(videos_dir: str, output_dir: str, list_tasks: bool):
    task_videos = set(file for file in os.listdir(videos_dir))
    labeled_videos = set(f'{file.split('.')[0]}.mp4' for file in os.listdir(output_dir))

    missing_videos = task_videos - labeled_videos

    print(f'Labeled videos: {len(labeled_videos)} / {len(task_videos)}')

    if not missing_videos:
        print("TASK COMPLETE")
    elif list_tasks:
        print("NOT LABELED:")
        for video in missing_videos:
            print(video)


def finalize_task(task_id: str, list_tasks: bool):
    task_path = get_task_path(task_id)
    cvat_dir = os.path.join(task_path, 'cvat')
    output_dir = os.path.join(task_path, f'task_{task_id}')
    videos_dir = os.path.join(task_path, 'videos')
    os.makedirs(output_dir, exist_ok=True)

    unzip_cvat_labels(cvat_dir, output_dir)
    verify_task(videos_dir, output_dir, list_tasks)


def labeling_task_script(task_id: str, list_tasks: bool):
    update_task(task_id)
    finalize_task(task_id, list_tasks)


def main():
    parser = argparse.ArgumentParser(description='Update a labeling task')
    parser.add_argument('task_id', type=str, help='ID of the task to update, should be an integer')
    parser.add_argument('-l', '--list', action='store_true', help='List all not labeled videos', default=False)

    args = parser.parse_args()

    labeling_task_script(args.task_id, list_tasks=args.list)


if __name__ == "__main__":
    main()
