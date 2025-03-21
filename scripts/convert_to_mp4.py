import argparse
import os
import subprocess

MP4_FORMAT = '.mp4'
OTHER_VIDEO_FORMATS = ('.avi', '.mov', '.mkv')

def convert_to_mp4(file_path: str):
    output_path = os.path.splitext(file_path)[0] + MP4_FORMAT
    print(f"Converting {file_path}")
    subprocess.run(['ffmpeg', '-i', file_path, output_path], check=True)
    os.remove(file_path)

def process_all_videos(directory: str):
    for root, _, files in os.walk(directory):
        for file in files:
            if file.lower().endswith(OTHER_VIDEO_FORMATS):
                file_path = os.path.join(root, file)
                print(f"Converting {file_path}")
                convert_to_mp4(os.path.join(root, file))


def main():
    parser = argparse.ArgumentParser(description='Convert all videos to MP4')
    parser.add_argument('directory', type=str, help='Directory to process')

    args = parser.parse_args()

    if not os.path.isdir(args.directory):
        print(f"The directory {args.directory} does not exist.")
        return

    print(f"Processing directory: {args.directory}")

    process_all_videos(args.directory)

if __name__ == "__main__":
    main()