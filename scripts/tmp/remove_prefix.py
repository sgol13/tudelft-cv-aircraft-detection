import argparse
import os

def remove_prefix_from_files(directory: str):
    for filename in os.listdir(directory):
        if filename.startswith("Copy of "):
            new_filename = filename[len("Copy of "):]
            old_path = os.path.join(directory, filename)
            new_path = os.path.join(directory, new_filename)
            os.rename(old_path, new_path)
            print(f"Renamed: {filename} -> {new_filename}")

def main():
    parser = argparse.ArgumentParser(description='Remove "Copy of " prefix from filenames in a directory')
    parser.add_argument('dir', type=str, help='Directory to process')

    args = parser.parse_args()
    remove_prefix_from_files(args.dir)

if __name__ == "__main__":
    main()