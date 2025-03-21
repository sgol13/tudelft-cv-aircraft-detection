import os

def rename_files(directory: str):
    for filename in os.listdir(directory):
        if filename.startswith("('") and filename.endswith("',).mp4"):
            new_filename = filename[2:10] + ".mp4"
            old_path = os.path.join(directory, filename)
            new_path = os.path.join(directory, new_filename)
            os.rename(old_path, new_path)
            print(f"Renamed: {filename} -> {new_filename}")

def main():
    directory = 'data/new_videos'
    if not os.path.isdir(directory):
        print(f"The directory {directory} does not exist.")
        return

    rename_files(directory)

if __name__ == "__main__":
    main()