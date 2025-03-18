import argparse
import concurrent.futures
import os

from tqdm import tqdm
from cvat_sdk import make_client, Client
from cvat_sdk.core.proxies.tasks import Task

from common import get_task_path

CVAT_HOST = "http://localhost:8080"
CVAT_USERNAME = "szymong"
CVAT_PASSWORD = "cvatpassword"  # only local, can be commited


def get_cvat_project_id(client: Client, project_name: str):
    for project in client.projects.list():
        if project.name == project_name:
            return project.id

    return None

def upload_labels_to_cvat_task(task: Task, labels_dir: str):
    video_id = task.name.split('.')[0]
    labels_path = os.path.join(labels_dir, f'{video_id}.xml')

    if os.path.isfile(labels_path):
        task.import_annotations("CVAT 1.1", labels_path)
    else:
        print(f"Labels for video {video_id} not found")

def upload_labels_to_cvat_project(client: Client, cvat_project_id: int, labels_dir: str):
    cvat_project = client.projects.retrieve(cvat_project_id)
    cvat_tasks = cvat_project.get_tasks()

    with concurrent.futures.ThreadPoolExecutor() as executor:
        futures = [executor.submit(upload_labels_to_cvat_task, task, labels_dir) for task in cvat_tasks]

        for future in tqdm(concurrent.futures.as_completed(futures), total=len(futures), desc="Uploading labels"):
            future.result()


def upload_labels_to_cvat(task_id: str):
    labels_path = os.path.join(get_task_path(task_id), f'task_{task_id}')

    with make_client(host=CVAT_HOST, credentials=(CVAT_USERNAME, CVAT_PASSWORD)) as client:
        cvat_project_id = get_cvat_project_id(client, task_id)
        assert cvat_project_id, f"Project {task_id} not found in CVAT"

        print(f"Uploading labels to the project #{cvat_project_id} (task {task_id})")

        upload_labels_to_cvat_project(client, cvat_project_id, labels_path)


def main():
    parser = argparse.ArgumentParser(description='Upload a labeling task to CVAT')
    parser.add_argument('task_id', type=str, help='ID of the task to upload, should be an integer')

    args = parser.parse_args()

    upload_labels_to_cvat(args.task_id)


if __name__ == "__main__":
    main()
