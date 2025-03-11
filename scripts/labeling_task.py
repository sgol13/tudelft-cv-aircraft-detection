import argparse
import os
import shutil
from asyncio import log
from typing import List

import requests
import csv

from tqdm import tqdm

from common import VIDEOS_DIR, LABELING_DIR


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
    task_content = [f'{v}.mp4' for v in task_content if v]

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
    task_videos_path = os.path.join(get_task_path(task_id), 'videos')
    os.makedirs(task_videos_path, exist_ok=True)

    filenames = fetch_task_filenames_from_spreadsheet(task_id)
    print(f"TASK {task_id}\n{len(filenames)} videos")

    num_copied = copy_videos_to_task(task_videos_path, filenames, VIDEOS_DIR)
    num_removed = remove_extra_files(task_videos_path, filenames)

    print(f"Updated: {num_copied} added, {num_removed} removed")


def finalize_task(task_id: int):
    pass


def main():
    parser = argparse.ArgumentParser(
        description='Update a labeling task (sync with spreadsheet), optionally finalize it.')
    parser.add_argument('task_id', type=str, help='ID of the task to update, should be an integer')
    parser.add_argument('-f', '--finalize', action='store_true', help='Finalize the task, render videos with bboxes.')

    args = parser.parse_args()

    update_task(args.task_id)

    if args.finalize:
        finalize_task(args.task_id)


if __name__ == "__main__":
    main()
