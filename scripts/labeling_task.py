import argparse
import os
import shutil
import re
from typing import List

from tqdm import tqdm
import requests
import csv

TASK_VIDEOS_PATH = 'videos'

def get_task_id(task_path: str) -> str:
    dir_name = os.path.basename(os.path.normpath(task_path))

    try:
        task_id = re.search(r'\d+$', dir_name).group()
    except AttributeError:
        raise ValueError(f"Cannot read task ID from the directory name {dir_name}")

    return task_id

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
        raise ValueError(f"Task ID {task_id} not found in the first row.")

    task_column = [row[column_index] for row in rows]

    try:
        videos_row_index = task_column.index('videos')
    except ValueError:
        raise ValueError(f"'videos' row not found in the task {task_id} column.")

    task_content = task_column[videos_row_index + 1:]
    task_content = [f'{v}.mp4' for v in task_content if v]

    return task_content


def copy_files_to_videos_dir(task_videos_dir: str, filenames: list, all_videos_dir: str):
    filenames = set(filenames)

    existing_files = set(os.listdir(task_videos_dir))
    files_to_copy = set(filenames) - existing_files

    # copy new files
    for filename in tqdm(files_to_copy):
        src_path = os.path.join(all_videos_dir, filename)
        dest_path = os.path.join(task_videos_dir, filename)
        if os.path.exists(src_path):
            shutil.copy(src_path, dest_path)
        else:
            raise RuntimeError(f"File {src_path} does not exist")

    # remove extra files
    extra_files = existing_files - filenames
    for filename in extra_files:
        file_path = os.path.join(task_videos_dir, filename)
        os.remove(file_path)
        print(f"Removed extra file: {file_path}")


def update_labeling_task(task_path: str, all_videos_dir: str):
    task_videos_dir = os.path.join(task_path, TASK_VIDEOS_PATH)
    os.makedirs(task_videos_dir, exist_ok=True)

    task_id = get_task_id(task_path)
    filenames = fetch_task_filenames_from_spreadsheet(task_id)

    print("Copying videos...")
    copy_files_to_videos_dir(task_videos_dir, filenames, all_videos_dir)


def main():
    parser = argparse.ArgumentParser(
        description='Update videos in a task directory based on videos list in a txt file.')
    parser.add_argument('task_path', type=str, help='Labeling task directory')
    parser.add_argument('all_videos_dir', type=str, help='Path to a directory with all videos (soruce).')

    args = parser.parse_args()

    print(f"Task directory: {args.task_path}")
    print(f"All videos directory: {args.all_videos_dir}")

    update_labeling_task(args.task_path, args.all_videos_dir)


if __name__ == "__main__":
    main()
