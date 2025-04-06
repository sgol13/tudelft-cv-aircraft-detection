import csv
from io import StringIO

import numpy as np
import pandas as pd
import requests

ground_truth_path = '../data/ground_truth_test.csv'
predictions_path = '../data/predictions_test.csv'


def add_video_name_column(df: pd.DataFrame):
    df['video_name'] = df['image_name'].str.split('_').str[0] + ".mp4"


def fetch_video_data_from_spreadsheet():
    file_id = "1hAqC2Pz3xIEqdslCMa91_bKWBSlOHUs2sL5UKU8Wr7c"
    gid = "286481740"
    csv_url = f"https://docs.google.com/spreadsheets/d/{file_id}/export?format=csv&gid={gid}"

    response = requests.get(csv_url)
    response.raise_for_status()  # Raise error if request fails

    sheet_df = pd.read_csv(StringIO(response.text))
    sheet_df = sheet_df[sheet_df['status'] == "verified"]
    sheet_df = sheet_df[[
        'name',
        'weather',
        'birds (0/1)',
        'other contrail (0/1)',
        'window (0/1)',
        'sunset (0/1)',
        'issues (0/1)'
    ]]
    sheet_df.rename(columns={
        'name': 'video_name',
        'birds (0/1)': 'birds',
        'other contrail (0/1)': 'other_contrail',
        'window (0/1)': 'window',
        'sunset (0/1)': 'sunset',
        'issues (0/1)': 'issues'
    }, inplace=True)
    bool_cols = ['birds', 'other_contrail', 'window', 'sunset', 'issues']
    sheet_df[bool_cols] = sheet_df[bool_cols].astype('boolean')

    return sheet_df


def append_sheet_data(input_df: pd.DataFrame):
    add_video_name_column(input_df)
    sheet_df = fetch_video_data_from_spreadsheet()
    merged_df = input_df.merge(sheet_df, how='inner', on='video_name')
    return merged_df


def get_true_positives(ground_truth: pd.DataFrame, predictions: pd.DataFrame, confidence_threshold=0.5):
    # Add prefixes to differentiate columns after merge
    gt_prefixed = ground_truth.rename(columns={col: f'gt_{col}' for col in ground_truth.columns if col != 'image_name'})
    pred_prefixed = predictions.rename(
        columns={col: f'pred_{col}' for col in predictions.columns if col != 'image_name'})

    # Perform a inner join on image name
    merged_df = gt_prefixed.merge(pred_prefixed, how='inner', on='image_name')

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
    filtered_df['distance'] = np.sqrt((filtered_df['gt_x_center'] - filtered_df['pred_x_center']) ** 2 + (
                filtered_df['gt_y_center'] - filtered_df['pred_y_center']) ** 2)

    # Keep only the row with the minimum distance for each ground truth entry
    true_positives_combined = filtered_df.loc[filtered_df.groupby(
        ['image_name', 'gt_class_id', 'gt_x_center', 'gt_y_center', 'gt_width', 'gt_height']
    )['distance'].idxmin()]

    true_positives_combined['iou'] = compute_intersection_over_union(true_positives_combined)

    return true_positives_combined


def get_false_positives(predictions: pd.DataFrame, true_positives_combined: pd.DataFrame):
    true_positives_pred = true_positives_combined.loc[:, [
                                                             'image_name',
                                                             'pred_class_id',
                                                             'pred_confidence',
                                                             'pred_x_center',
                                                             'pred_y_center',
                                                             'pred_width',
                                                             'pred_height',
                                                             'distance'
                                                         ]].copy().rename(columns=lambda x: x.removeprefix('pred_'))

    return pd.concat([predictions.copy(), true_positives_pred.copy()]).drop_duplicates(keep=False)


def get_false_negatives(ground_truth: pd.DataFrame, true_positives_combined: pd.DataFrame):
    true_positives_gt = true_positives_combined.loc[:, [
                                                           'image_name',
                                                           'gt_class_id',
                                                           'gt_x_center',
                                                           'gt_y_center',
                                                           'gt_width',
                                                           'gt_height'
                                                       ]].copy().rename(columns=lambda x: x.removeprefix('gt_'))

    return pd.concat([ground_truth, true_positives_gt.copy()]).drop_duplicates(keep=False)


def compute_intersection_over_union(tp: pd.DataFrame):
    x_bound_1_left = tp['gt_x_center'] - tp['gt_width'] / 2
    x_bound_1_right = tp['gt_x_center'] + tp['gt_width'] / 2
    y_bound_1_top = tp['gt_y_center'] - tp['gt_height'] / 2
    y_bound_1_bottom = tp['gt_y_center'] + tp['gt_height'] / 2

    x_bound_2_left = tp['pred_x_center'] - tp['pred_width'] / 2
    x_bound_2_right = tp['pred_x_center'] + tp['pred_width'] / 2
    y_bound_2_top = tp['pred_y_center'] - tp['pred_height'] / 2
    y_bound_2_bottom = tp['pred_y_center'] + tp['pred_height'] / 2

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
    area_1 = tp['gt_width'] * tp['gt_height']
    area_2 = tp['pred_width'] * tp['pred_height']

    # Compute union area
    area_union = area_1 + area_2 - area_intersection

    # Compute IoU, avoiding division by zero
    iou = area_intersection / area_union
    iou[area_union == 0] = 0  # If union is 0, set IoU to 0

    return iou


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
    # Read files
    ground_truth_df = pd.read_csv(ground_truth_path)
    predictions_df = pd.read_csv(predictions_path)

    # Separate true positive, false positives and false negatives
    tp = get_true_positives(ground_truth_df, predictions_df)

    fp = get_false_positives(predictions_df, tp)
    fn = get_false_negatives(ground_truth_df, tp)

    # Filtering
    tp = append_sheet_data(tp)
    fp = append_sheet_data(fp)
    fn = append_sheet_data(fn)

    tp_weather_clear = tp[tp['weather'] == "clear_sky"]
    tp_weather_clouds = tp[tp['weather'] == "clouds"]
    tp_weather_overcast = tp[tp['weather'] == "overcast"]
    fp_weather_clear = fp[fp['weather'] == "clear"]
    fp_weather_clouds = fp[fp['weather'] == "clouds"]
    fp_weather_overcast = fp[fp['weather'] == "overcast"]
    fn_weather_clear = fn[fn['weather'] == "clear"]
    fn_weather_clouds = fn[fn['weather'] == "clouds"]
    fn_weather_overcast = fn[fn['weather'] == "overcast"]

    tp_bird = tp[tp['birds'] == True]
    tp_no_bird = tp[tp['birds'] == False]
    fp_bird = fp[fp['birds'] == True]
    fp_no_bird = fp[fp['birds'] == False]
    fn_bird = fn[fn['birds'] == True]
    fn_no_bird = fn[fn['birds'] == False]

    tp_contrail = tp[tp['other_contrail'] == True]
    tp_no_contrail = tp[tp['other_contrail'] == False]
    fp_contrail = fp[fp['other_contrail'] == True]
    fp_no_contrail = fp[fp['other_contrail'] == False]
    fn_contrail = fn[fn['other_contrail'] == True]
    fn_no_contrail = fn[fn['other_contrail'] == False]

    tp_window = tp[tp['window'] == True]
    tp_no_window = tp[tp['window'] == False]
    fp_window = fp[fp['window'] == True]
    fp_no_window = fp[fp['window'] == False]
    fn_window = fn[fn['window'] == True]
    fn_no_window = fn[fn['window'] == False]

    tp_sunset = tp[tp['sunset'] == True]
    tp_no_sunset = tp[tp['sunset'] == False]
    fp_sunset = fp[fp['sunset'] == True]
    fp_no_sunset = fp[fp['sunset'] == False]
    fn_sunset = fn[fn['sunset'] == True]
    fp_no_sunset = fn[fn['sunset'] == False]

    tp_issues = tp[tp['issues'] == True]
    tp_no_issues = tp[tp['issues'] == False]
    fp_issues = fp[fp['issues'] == True]
    fp_no_issues = fp[fp['issues'] == False]
    fn_issues = fn[fn['issues'] == True]
    fn_no_issues = fn[fn['issues'] == False]

    # Evaluation
    eval = evaluate(tp, fp, fn)

    eval_weather_clear = evaluate(tp_weather_clear, fp_weather_clear, fn_weather_clear)
    eval_weather_clouds = evaluate(tp_weather_clouds, fp_weather_clouds, fn_weather_clouds)
    eval_weather_overcast = evaluate(tp_weather_overcast, fp_weather_overcast, fn_weather_overcast)

    eval_bird = evaluate(tp_bird, fp_bird, fn_bird)
    eval_no_bird = evaluate(tp_no_bird, fp_no_bird, fn_no_bird)

    eval_contrail = evaluate(tp_contrail, fp_contrail, fn_contrail)
    eval_no_contrail = evaluate(tp_no_contrail, fp_no_contrail, fn_no_contrail)

    eval_window = evaluate(tp_window, fp_window, fn_window)
    eval_no_window = evaluate(tp_no_window, fp_no_window, fn_no_window)

    eval_sunset = evaluate(tp_sunset, fp_sunset, fn_sunset)
    eval_no_sunset = evaluate(tp_no_sunset, fp_no_sunset, fn_sunset)

    eval_issues = evaluate(tp_issues, fp_issues, fn_issues)
    eval_no_issues = evaluate(tp_no_issues, fp_no_issues, fn_no_issues)

    print(f"Recall: {eval['recall']}")
    print(f"Precision: {eval['precision']}")
    print(f"F1 Score: {eval['f1']}")
    print(f"Center Error Avg: {eval['center_error_avg']}")
    print(f"IoU Avg: {eval['iou_avg']}")
    print(f"Confidence Avg: {eval['confidence_avg']}")


if __name__ == "__main__":
    main()
