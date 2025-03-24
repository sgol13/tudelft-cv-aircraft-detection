import argparse
import csv
import os
from concurrent.futures import ThreadPoolExecutor
from typing import List, Optional, Set, Dict, Union
import pandas as pd
import cv2
import hashlib
import ffmpeg
import requests
from tqdm import tqdm
import shutil
from collections import defaultdict

NUM_THREADS = 10

Video = Dict[str, Union[str, float, int]]


def get_current_videos_from_spreadsheet() -> List[str]:
    file_id = "1hAqC2Pz3xIEqdslCMa91_bKWBSlOHUs2sL5UKU8Wr7c"
    gid = "286481740"
    csv_url = f"https://docs.google.com/spreadsheets/d/{file_id}/export?format=csv&gid={gid}"

    response = requests.get(csv_url)
    response.raise_for_status()  # Raise error if request fails

    rows = list(csv.reader(response.text.splitlines()))

    # for it, row in enumerate(rows[:10]):
    #     print(it, row[:6])

    assert rows[0][1] == 'name', "The second column is not 'name'"

    names = [row[1] for row in rows[1:] if row[1]]

    assert all(name.endswith('.mp4') for name in names), "Not all names are .mp4 files"

    return names


def get_new_videos_paths(directory: str) -> List[str]:
    print("\nSkipping files:")
    video_files = []
    for root, _, files in os.walk(directory):
        for file in files:
            if file.lower().endswith('.mp4'):
                video_files.append(os.path.join(root, file))
            else:
                print(f"{root}/{file}")

    return video_files


def hash_mp4(video_path):
    """
    Compute the SHA-1 hash of the first and last frames of a video
    """
    cap = cv2.VideoCapture(video_path)
    if not cap.isOpened():
        return None

    total_frames = int(cap.get(cv2.CAP_PROP_FRAME_COUNT))
    frame_indices = [0, total_frames - 1] if total_frames > 1 else [0]
    hasher = hashlib.sha1()

    for idx in frame_indices:
        cap.set(cv2.CAP_PROP_POS_FRAMES, idx)
        ret, frame = cap.read()
        if ret:
            frame = cv2.resize(frame, (64, 64)).tobytes()
            hasher.update(frame)

    cap.release()
    return hasher.hexdigest()


def extract_video_metadata(video_path: str) -> Dict[str, Optional[Union[float, int, str]]]:
    try:
        vid = ffmpeg.probe(video_path)
    except ffmpeg.Error as e:
        raise RuntimeError(f"ffprobe error on file {video_path}: {e.stderr}")

    streams = vid['streams']
    video_stream = next((s for s in streams if s['codec_type'] == 'video'), None)

    if not video_stream:
        raise ValueError(f"No video stream found in the file {video_path}")

    timestamp = video_stream.get('tags', {}).get('creation_time')
    width = video_stream.get('width')
    height = video_stream.get('height')
    duration = round(float(video_stream.get('duration', 0)), 2)
    framerate = int(eval(video_stream.get('r_frame_rate', '0/1')))  # Convert fraction to float
    total_frames = int(video_stream.get('nb_frames', 0))

    return {
        "timestamp": timestamp,
        "resolution": f'{width}x{height}',
        "duration": duration,
        "framerate": framerate,
        "total_frames": total_frames
    }


def read_video(video_path: str) -> Video:
    filename = os.path.basename(video_path)
    directory_name = os.path.basename(os.path.dirname(video_path))

    metadata = extract_video_metadata(video_path)
    hash_value = hash_mp4(video_path)
    hash_prefix = hash_value[:8]  # 8 digits, ~0.2% collision probability on 10k videos

    return metadata | {
        'name': hash_prefix + '.mp4',
        'original_name': filename,
        'source': directory_name,
        'path': video_path,
    }


def process_videos(video_paths: List[str]):
    with ThreadPoolExecutor(max_workers=NUM_THREADS) as executor:
        video_futures = executor.map(read_video, video_paths)
        videos = list(tqdm(video_futures, total=len(video_paths), desc="Processing videos"))

    return videos


def verify_no_duplicates(videos: List[Video]) -> bool:
    hash_to_videos = defaultdict(list)
    for video in videos:
        hash_to_videos[video['name']].append(video)

    duplicates = {
        hash_value: video_list
        for hash_value, video_list in hash_to_videos.items()
        if len(video_list) > 1
    }

    if duplicates:
        print("\nDuplicate videos found:")
        for hash_value, video_list in duplicates.items():
            print(f"\nHash: {hash_value}")
            for video in video_list:
                print(f"{video['path']}")
        return True
    else:
        print("\nNo duplicate videos found")
        return False


def save_csv_output(videos: List[Video], output_dir: str):
    columns_to_save = ['name', 'original_name', 'source', 'timestamp', 'resolution', 'duration', 'framerate',
                       'total_frames']
    df = pd.DataFrame(videos)
    os.makedirs(output_dir, exist_ok=True)
    df.to_csv(os.path.join(output_dir, 'new_videos.csv'), index=False, columns=columns_to_save)
    print(f"Results saved to {output_dir}/new_videos.csv")


def copy_video(video: Video, output_dir: str):
    dest_path = os.path.join(output_dir, video['name'])
    if os.path.exists(dest_path):
        raise RuntimeError(f"{dest_path} already exists")

    shutil.copy(video['path'], dest_path)


def copy_all_videos(videos: List[Video], output_dir: str):
    os.makedirs(output_dir, exist_ok=True)

    for video in tqdm(videos, desc="Copying videos"):
        copy_video(video, output_dir)


def add_videos(directory: str, output_dir: Optional[str], copy_videos: bool):
    current_videos: Set[str] = set(get_current_videos_from_spreadsheet())
    print(f"{len(current_videos)} videos in the dataset")

    new_video_paths: List[str] = get_new_videos_paths(directory)
    print(f"{len(new_video_paths)} mp4 videos found")

    videos = process_videos(new_video_paths)

    if verify_no_duplicates(videos):
        return

    new_videos = [v for v in videos if v['name'] not in current_videos]

    print(f"{len(new_videos)} new mp4 videos found")

    if output_dir:
        save_csv_output(new_videos, output_dir)

    if copy_videos:
        copy_all_videos(new_videos, output_dir)


def main():
    parser = argparse.ArgumentParser(description='Add videos to the dataset')
    parser.add_argument('directory', type=str, help='Directory with new videos to process')
    parser.add_argument('--output', type=str, help='Output directory for new videos and csv file')
    parser.add_argument('--copy', action='store_true', help="Copy videos (otherwise only csv output)")

    args = parser.parse_args()

    if not os.path.isdir(args.directory):
        print(f"The directory {args.directory} does not exist.")
        return

    print(f"Processing directory: {args.directory}")

    if args.output:
        print(f"Output directory: {args.output}")
        if os.path.exists(args.output) and os.listdir(args.output):
            print(f"The output directory {args.output} is not empty.")
            return
    else:
        print("No output directory provided")

    add_videos(args.directory, args.output, args.copy)


if __name__ == "__main__":
    main()
