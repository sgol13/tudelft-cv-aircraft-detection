import argparse
import os
import shutil
from tqdm import tqdm

TASK_VIDEOS_PATH = 'videos'


def find_txt_file(directory: str) -> str:
    for file in os.listdir(directory):
        if file.endswith('.txt'):
            return os.path.join(directory, file)
    raise FileNotFoundError("No .txt file found in the directory")


def read_filenames_from_file(file_path: str):
    with open(file_path, 'r') as file:
        filenames = [line.strip() + '.mp4' for line in file]
    return filenames


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

    print(task_path)
    txt_file_path = find_txt_file(task_path)
    filenames = read_filenames_from_file(txt_file_path)

    print(task_videos_dir)
    print(txt_file_path)

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
