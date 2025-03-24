import os
import fiftyone as fo

DATA_DIR = 'data'
LABELING_DIR = os.path.join(DATA_DIR, "labeling")
VIDEOS_DIR = os.path.join(DATA_DIR, "videos")

RENDERED_LABELS_DIR = os.path.join(DATA_DIR, "rendered_labels")

def get_task_path(task_id: str):
    return os.path.join(LABELING_DIR, task_id)


def start_fiftyone(videos_dir: str):
    dataset = fo.Dataset.from_videos_dir(videos_dir)

    for sample in dataset:
        sample["name"] = os.path.basename(sample.filepath)
        sample.save()

    session = fo.launch_app(dataset)
    session.wait()