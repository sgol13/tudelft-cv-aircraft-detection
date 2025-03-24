import fiftyone as fo
import os
import argparse

from common import start_fiftyone

def main():
    parser = argparse.ArgumentParser(description='Preview videos in a directory')
    parser.add_argument('dir', type=str, help='Directory to preview')

    args = parser.parse_args()

    if not os.path.isdir(args.dir):
        print(f"The directory {args.dir} does not exist.")
        return

    start_fiftyone(args.dir)

if __name__ == "__main__":
    main()