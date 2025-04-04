import csv

import numpy as np
import pandas as pd
import requests

ground_truth_path = '../data/ground_truth_test.csv'
predictions_path = '../data/predictions_test.csv'


def add_video_name_column(df: pd.DataFrame):
    df['video_name'] = df['image_name'].str.split('_').str[1]


def fetch_video_data_from_spreadsheet():
    file_id = "1hAqC2Pz3xIEqdslCMa91_bKWBSlOHUs2sL5UKU8Wr7c"
    gid = "286481740"
    csv_url = f"https://docs.google.com/spreadsheets/d/{file_id}/export?format=csv&gid={gid}"

    response = requests.get(csv_url)
    response.raise_for_status()  # Raise error if request fails

    rows = list(csv.reader(response.text.splitlines()))


def get_true_positives(ground_truth: pd.DataFrame, predictions: pd.DataFrame, confidence_threshold=0.5):
    # Add prefixes to differentiate columns after merge
    gt_prefixed = ground_truth.add_prefix('gt_')
    pred_prefixed = predictions.add_prefix('pred_')

    # Perform a inner join on image name
    merged_df = gt_prefixed.merge(pred_prefixed, how='inner', left_on='gt_image_name', right_on='pred_image_name')

    # Filter on class and bounding box containment
    filtered_df = merged_df.loc[
        (merged_df['gt_class_id'] == merged_df['pred_class_id'])
        &
        (merged_df['pred_confidence'] >= confidence_threshold)
        &
        (np.abs(merged_df['pred_x_center'] - merged_df['gt_x_center']) * 2 <= merged_df['gt_width'])
        &
        (np.abs(merged_df['pred_y_center'] - merged_df['gt_y_center']) * 2 <= merged_df['gt_height'])
    ].copy()

    # Compute the Euclidean distance (leaving out the square root, since it is proportional and inefficient to compute)
    filtered_df['distance'] = np.sqrt((filtered_df['gt_x_center'] - filtered_df['pred_x_center']) ** 2 + (filtered_df['gt_y_center'] - filtered_df['pred_y_center']) ** 2)

    # Keep only the row with the minimum distance for each ground truth entry
    min_distance_df = filtered_df.loc[filtered_df.groupby(
        ['gt_image_name', 'gt_class_id', 'gt_x_center', 'gt_y_center', 'gt_width', 'gt_height']
    )['distance'].idxmin()]

    true_positives_gt = min_distance_df.loc[:, [
        'gt_image_name',
        'gt_class_id',
        'gt_x_center',
        'gt_y_center',
        'gt_width',
        'gt_height'
    ]].copy().rename(columns=lambda x: x.removeprefix('gt_'))

    true_positives_pred = min_distance_df.loc[:, [
        'pred_image_name',
        'pred_class_id',
        'pred_confidence',
        'pred_x_center',
        'pred_y_center',
        'pred_width',
        'pred_height',
        'distance'
    ]].copy().rename(columns=lambda x: x.removeprefix('pred_'))

    return min_distance_df, true_positives_gt, true_positives_pred


def get_false_positives(predictions: pd.DataFrame, true_positives_pred: pd.DataFrame):
    return pd.concat([predictions.copy(), true_positives_pred.copy()]).drop_duplicates(keep=False)


def get_false_negatives(ground_truth: pd.DataFrame, true_positives_gt: pd.DataFrame):
    return pd.concat([ground_truth, true_positives_gt.copy()]).drop_duplicates(keep=False)


def compute_intersection_over_union(box1: pd.DataFrame, box2: pd.DataFrame):
    x_bound_1_left = box1['x_center'] - box1['width'] / 2
    x_bound_1_right = box1['x_center'] + box1['width'] / 2
    y_bound_1_top = box1['y_center'] - box1['height'] / 2
    y_bound_1_bottom = box1['y_center'] + box1['height'] / 2

    x_bound_2_left = box2['x_center'] - box2['width'] / 2
    x_bound_2_right = box2['x_center'] + box2['width'] / 2
    y_bound_2_top = box2['y_center'] - box2['height'] / 2
    y_bound_2_bottom = box2['y_center'] + box2['height'] / 2

    # Compute intersection boundaries using stack + min/max along axis=0
    x_intersection_left = np.maximum(x_bound_1_left, x_bound_2_left)
    x_intersection_right = np.minimum(x_bound_1_right, x_bound_2_right)
    y_intersection_top = np.maximum(y_bound_1_top, y_bound_2_top)
    y_intersection_bottom = np.minimum(y_bound_1_bottom, y_bound_2_bottom)

    # Compute intersection area
    intersection_width = (x_intersection_right - x_intersection_left).clip(lower=0, upper=1)
    intersection_height = (y_intersection_bottom - y_intersection_top).clip(lower=0, upper=1)
    area_intersection = intersection_width * intersection_height

    # Compute individual box areas
    area_1 = box1['width'] * box1['height']
    area_2 = box2['width'] * box2['height']

    # Compute union area
    area_union = area_1 + area_2 - area_intersection

    # Compute IoU, avoiding division by zero
    iou = area_intersection / area_union
    iou[area_union == 0] = 0  # If union is 0, set IoU to 0

    return iou


def filter_data(df_unfiltered: pd.DataFrame, fn_condition) -> pd.DataFrame:

    df_filtered = df_unfiltered.copy()
    return df_filtered


def evaluate(true_positives, false_positives, false_negatives) -> dict:

    predicted_positives = true_positives.shape[0] + false_positives.shape[0]
    ground_truth_positives = true_positives.shape[0] + false_negatives.shape[0]

    recall = true_positives.shape[0] / ground_truth_positives
    precision = true_positives.shape[0] / predicted_positives
    f1 = 0.0 if (precision + recall) == 0 else (2 * precision * recall) / (precision + recall)

    return {
        "recall": recall,
        "precision": precision,
        "f1": f1,
        "center_error_avg": true_positives['distance'].mean(),
        "iou_avg": true_positives['iou'].mean(),
        "confidence_avg": true_positives['pred_confidence'].mean(),
    }


def main():

    ground_truth_df = pd.read_csv(ground_truth_path)
    predictions_df = pd.read_csv(predictions_path)

    # add_video_name_column(ground_truth_df)
    # ground_truth_df.drop(columns=['video_name'])

    tp_combined, tp_gt, tp_pred = get_true_positives(ground_truth_df, predictions_df)
    tp_combined['iou'] = compute_intersection_over_union(tp_gt, tp_pred)

    fp = get_false_positives(predictions_df, tp_pred)
    fn = get_false_negatives(ground_truth_df, tp_gt)

    metrics = evaluate(tp_combined, fp, fn)

    print(f"Recall: {metrics['recall']}")
    print(f"Precision: {metrics['precision']}")
    print(f"F1 Score: {metrics['f1']}")
    print(f"Center Error Avg: {metrics['center_error_avg']}")
    print(f"IoU Avg: {metrics['iou_avg']}")
    print(f"Confidence Avg: {metrics['confidence_avg']}")


if __name__ == "__main__":
    main()