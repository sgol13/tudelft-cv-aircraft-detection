import argparse
import io
import os
import pprint
import shutil
from typing import List
import re
import requests
import csv

from tqdm import tqdm

from common import VIDEOS_DIR, LABELING_DIR
from render_labels import render_labels
from cvat_sdk.api_client import Configuration, ApiClient, exceptions
from cvat_sdk.api_client.models import *

CONFIGURATION = Configuration(
    host="http://localhost:8080",
    username='szymong',
    password='cvatpassword', # only local, can be commited
)

def get_task_path(task_id: str):
    return os.path.join(LABELING_DIR, task_id)


def create_cvat_project(project_name: str):
    with ApiClient(CONFIGURATION) as api_client:
        project_request = ProjectWriteRequest(
            name=project_name,
            labels=[],
            owner_id=1,
            assignee_id=1,
        )

        try:
            data, response = api_client.projects_api.create(project_request)
            return data['id']

        except exceptions.ApiException as e:
            print(f"Exception when calling ProjectsApi.create(): {e}")
            return None

def create_cvat_task(cvat_project_id: int, video_path: str):
    print(video_path)
    with ApiClient(CONFIGURATION) as api_client:
        task_request = TaskWriteRequest(
            name=os.path.basename(video_path),
            project_id=int(cvat_project_id),
            owner_id=1,
            assignee_id=1,
        )

        try:
            task_data, response = api_client.tasks_api.create(task_request)

            task_id = task_data.id

            with open(video_path, "rb") as video_file:
                file_obj = io.BytesIO(video_file.read())
                print(type(video_file), type(file_obj))
                print(cvat_project_id)
                # print(type(video_file))
                data_request = DataRequest(
                    client_files=[video_file],
                    image_quality=100,
                    storage_method=StorageMethod("cache"),
                    storage=StorageType("local"),
                )

                api_client.tasks_api.create_data(
                    task_id,
                    upload_finish=True,
                    upload_multiple=True,
                    upload_start=True,
                    data_request=data_request,
                )

            return task_data
        except exceptions.ApiException as e:
            print(f"Exception when calling TasksApi.create(): {e}")
            return None


def upload_videos(cvat_project_id: int, task_path: str):
    task_videos_dir = os.path.join(task_path, 'videos')
    videos = [file for file in os.listdir(task_videos_dir) if file.endswith('.mp4')]

    for video in tqdm(videos, desc="Uploading videos"):
        video_path = os.path.join(task_videos_dir, video)
        create_cvat_task(cvat_project_id, video_path)


def upload_labels():
    pass

def upload_to_cvat(task_id: str):
    task_path = get_task_path(task_id)

    # cvat_project_id = create_cvat_project(task_id)
    cvat_project_id = 48

    upload_videos(cvat_project_id, task_path)


def main():
    parser = argparse.ArgumentParser(description='Upload a labeling task to CVAT')
    parser.add_argument('task_id', type=str, help='ID of the task to upload, should be an integer')

    args = parser.parse_args()

    upload_to_cvat(args.task_id)


if __name__ == "__main__":
    main()
