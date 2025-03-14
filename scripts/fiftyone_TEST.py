import fiftyone as fo
import os

# Load dataset
# dataset = fo.Dataset.from_dir(
#     # dataset_type=fo.types.CVATVideoDataset,
#     data_path='../data/preview',
#     # labels_path='../data/labeling/1/task_1',
#     progress=True
# )

dataset = fo.Dataset.from_videos_dir('data/preview')

for sample in dataset:
    sample["name"] = os.path.basename(sample.filepath)
    sample.save()


session = fo.launch_app(dataset)
session.wait()
