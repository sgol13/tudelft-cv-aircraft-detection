import argparse
import os


from cvat_sdk.core.proxies.tasks import ResourceType
from tqdm import tqdm

from common import LABELING_DIR
from cvat_sdk import make_client, Client

CVAT_HOST = "http://localhost:8080"
CVAT_USERNAME = "szymong"
CVAT_PASSWORD = "cvatpassword"  # only local, can be commited

LABELS_CONFIG = [
    {
        "name": "contrail",
        "color": "#2900ff",
        "type": "rectangle",
        "attributes": []
    },
    {
        "name": "high_airliner",
        "color": "#b83df5",
        "type": "rectangle",
        "attributes": []
    },
    {
        "name": "low_airliner",
        "color": "#ffcc33",
        "type": "rectangle",
        "attributes": []
    },
    {
        "name": "light_airplane",
        "color": "#83e070",
        "type": "rectangle",
        "attributes": []
    },
    {
        "name": "helicopter",
        "color": "#24b353",
        "type": "rectangle",
        "attributes": []
    },
    {
        "name": "other",
        "color": "#51b90a",
        "type": "rectangle",
        "attributes": []
    },
    {
        "name": "high_airliner_contrail",
        "color": "#8c78f0",
        "type": "rectangle",
        "attributes": []
    },
    {
        "name": "faint_contrail",
        "color": "#ff003f",
        "type": "rectangle",
        "attributes": []
    }
]


def get_task_path(task_id: str):
    return os.path.join(LABELING_DIR, task_id)


def create_cvat_project(client: Client, project_name: str):
    project = client.projects.create({
        "name": project_name,
        "labels": LABELS_CONFIG
    })
    return project.id


def create_cvat_task(client: Client, cvat_project_id: int, video_path: str, labels_path: str):
    task_spec = {
        'name': os.path.basename(video_path),
        'project_id': cvat_project_id,
    }

    task = client.tasks.create_from_data(
        spec=task_spec,
        resource_type=ResourceType.LOCAL,
        resources=[video_path],
        annotation_path=labels_path,
        annotation_format="CVAT 1.1",
    )

    return task.id


def upload_videos_and_labels(client: Client, task_id: str, cvat_project_id: int):
    task_path = get_task_path(task_id)
    task_videos_dir = os.path.join(task_path, 'videos')
    task_labels_dir = os.path.join(task_path, f'task_{task_id}')

    videos = [file for file in os.listdir(task_videos_dir) if file.endswith('.mp4')]

    for video in tqdm(videos, desc="Uploading videos"):
        video_path = os.path.join(task_videos_dir, video)
        labels_path = os.path.join(task_labels_dir, f'{video.split('.')[0]}.xml')
        assert os.path.isfile(labels_path)

        create_cvat_task(client, cvat_project_id, video_path, labels_path)


def upload_to_cvat(task_id: str):
    with make_client(host=CVAT_HOST, credentials=(CVAT_USERNAME, CVAT_PASSWORD)) as client:
        cvat_project_id = create_cvat_project(client, task_id)
        upload_videos_and_labels(client, task_id, cvat_project_id)


def main():
    parser = argparse.ArgumentParser(description='Upload a labeling task to CVAT')
    parser.add_argument('task_id', type=str, help='ID of the task to upload, should be an integer')

    args = parser.parse_args()

    upload_to_cvat(args.task_id)


if __name__ == "__main__":
    main()
