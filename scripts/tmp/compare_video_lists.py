import os


def read_filenames(directory: str):
    try:
        filenames = os.listdir(directory)
        filenames = [f for f in filenames if f.endswith('.mp4')]
        return filenames
    except FileNotFoundError:
        print(f"The directory {directory} does not exist.")
        return []


def read_lines_from_file(file_path: str):
    with open(file_path, 'r') as file:
        lines = [line.strip() for line in file.readlines()]

    while lines and lines[-1].strip() == '':
        lines.pop()

    lines = [line for line in lines if line.endswith('.mp4')]

    return lines


def main():
    videos = set(read_filenames('data/videos'))
    list = set(read_lines_from_file('data/video_list.txt'))

    print(f'videos: {len(videos)}')
    print(f'list: {len(list)}')

    print(f"list - videos: {list - videos}")
    print(f"videos - list: {videos - list}")


if __name__ == "__main__":
    main()
