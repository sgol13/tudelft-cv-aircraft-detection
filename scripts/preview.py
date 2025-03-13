import fiftyone as fo
import os


dataset = fo.Dataset.from_dir(
    dataset_type=fo.types.CVATVideoDataset,
    # data_path='data/labeling/1/videos',
    # labels_path='data/labeling/1/task_1',
    progress=True
)

for sample in dataset:
    sample["name"] = os.path.basename(sample.filepath)
    sample.save()

session = fo.launch_app(dataset)

session.wait()