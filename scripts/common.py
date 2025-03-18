import os

DATA_DIR = 'data'
LABELING_DIR = os.path.join(DATA_DIR, "labeling")
VIDEOS_DIR = os.path.join(DATA_DIR, "videos")

RENDERED_LABELS_DIR = os.path.join(DATA_DIR, "rendered_labels")

def get_task_path(task_id: str):
    return os.path.join(LABELING_DIR, task_id)