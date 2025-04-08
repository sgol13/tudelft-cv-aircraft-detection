import csv
import os
from io import StringIO

import numpy as np
import pandas as pd
import requests

synthetic_predictions_path = 'data/synthetic_pred.csv'
synthetic_ground_truth_path = 'data/synthetic_gt.csv'


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
    sheet_df.rename(
        columns={
            'name': 'video_name',
            'birds (0/1)': 'birds',
            'other contrail (0/1)': 'other_contrail',
            'window (0/1)': 'window',
            'sunset (0/1)': 'sunset',
            'issues (0/1)': 'issues'
        }, inplace=True
    )
    bool_cols = ['birds', 'other_contrail', 'window', 'sunset', 'issues']
    sheet_df[bool_cols] = sheet_df[bool_cols].astype('boolean')

    return sheet_df


def append_sheet_data(input_df: pd.DataFrame):
    add_video_name_column(input_df)
    sheet_df = fetch_video_data_from_spreadsheet()
    merged_df = input_df.merge(sheet_df, how='inner', on='video_name')
    return merged_df


def get_true_positives(
        predictions: pd.DataFrame,
        ground_truth: pd.DataFrame,
        confidence_threshold=0.25,
        iou_threshold=0.50
):
    # Add prefixes to differentiate columns after merge
    gt_prefixed = ground_truth.rename(columns={col: f'gt_{col}' for col in ground_truth.columns if col != 'image_name'})
    pred_prefixed = predictions.rename(
        columns={col: f'pred_{col}' for col in predictions.columns if col != 'image_name'}
    )

    # Perform a inner join on image name
    merged_df = gt_prefixed.merge(pred_prefixed, how='inner', on='image_name')

    # Compute the Euclidean distance (leaving out the square root, since it is proportional and inefficient to compute)
    merged_df['distance'] = np.sqrt(
        (merged_df['gt_x_center'] - merged_df['pred_x_center']) ** 2 + (
                merged_df['gt_y_center'] - merged_df['pred_y_center']) ** 2
    )

    merged_df['iou'] = compute_intersection_over_union(merged_df)

    # Filter on class and bounding box containment
    filtered_df = merged_df.loc[
        (merged_df['gt_class_id'] == merged_df['pred_class_id'])
        &
        (merged_df['pred_confidence'] >= confidence_threshold)
        &
        (merged_df['iou'] > 0.0)
        # &
        # (merged_df['distance'] < distance_threshold)
        # &
        # (np.abs(merged_df['pred_x_center'] - merged_df['gt_x_center']) * 2 <= merged_df['gt_width'])
        # &
        # (np.abs(merged_df['pred_y_center'] - merged_df['gt_y_center']) * 2 <= merged_df['gt_height'])
    ].copy()

    # Keep only the row with the minimum distance for each ground truth entry
    true_positives_combined = filtered_df.loc[filtered_df.groupby(
        ['image_name', 'gt_class_id', 'gt_x_center', 'gt_y_center', 'gt_width', 'gt_height']
    )['pred_confidence'].idxmax()]

    return true_positives_combined


def get_false_positives(predictions: pd.DataFrame, true_positives_combined: pd.DataFrame):
    true_positives_pred = true_positives_combined.loc[:, [
                                                             'image_name',
                                                             'pred_class_id',
                                                             'pred_confidence',
                                                             'pred_x_center',
                                                             'pred_y_center',
                                                             'pred_width',
                                                             'pred_height'
                                                         ]].copy().rename(columns=lambda x: x.removeprefix('pred_'))

    merged_df = pd.concat([predictions.copy(), true_positives_pred])
    false_positives = merged_df.drop_duplicates(keep=False)

    return false_positives


def get_false_negatives(ground_truth: pd.DataFrame, true_positives_combined: pd.DataFrame):
    true_positives_gt = true_positives_combined.loc[:, [
                                                           'image_name',
                                                           'gt_class_id',
                                                           'gt_x_center',
                                                           'gt_y_center',
                                                           'gt_width',
                                                           'gt_height'
                                                       ]].copy().rename(columns=lambda x: x.removeprefix('gt_'))

    merged_df = pd.concat([ground_truth, true_positives_gt.copy()])
    false_negatives = merged_df.drop_duplicates(keep=False)

    return false_negatives


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


def compute_metrics(name, true_positives, false_positives, false_negatives) -> dict:
    predicted_positives = true_positives.shape[0] + false_positives.shape[0]
    ground_truth_positives = true_positives.shape[0] + false_negatives.shape[0]

    assert predicted_positives > 0 and ground_truth_positives > 0

    precision = true_positives.shape[0] / predicted_positives
    recall = true_positives.shape[0] / ground_truth_positives
    f1 = 0.0 if (precision + recall) == 0 else (2 * precision * recall) / (precision + recall)

    return {
        "name": name,
        "precision": precision,
        "recall": recall,
        "f1": f1,
        "center_error_avg": true_positives['distance'].mean(),
        "iou_avg": true_positives['iou'].mean(),
        "confidence_avg": true_positives['pred_confidence'].mean(),
    }


def evaluate(
        predictions_df,
        ground_truth_df,
        confidence_threshold_percentage=0.25,
        iou_threshold_percentage=0.50):

    predictions_df = predictions_df[predictions_df['class_id'] > -1]

    # Separate true positive, false positives and false negatives
    tp = get_true_positives(
        predictions_df,
        ground_truth_df,
        confidence_threshold=confidence_threshold_percentage,
        iou_threshold=iou_threshold_percentage
    )

    fp = get_false_positives(predictions_df, tp)
    fn = get_false_negatives(ground_truth_df, tp)

    # Filtering
    tp = append_sheet_data(tp)
    fp = append_sheet_data(fp)
    fn = append_sheet_data(fn)

    tp_class_contrail = tp[tp['gt_class_id'] == 0]
    tp_class_aircraft = tp[tp['gt_class_id'] == 1]
    fp_class_contrail = fp[fp['class_id'] == 0]
    fp_class_aircraft = fp[fp['class_id'] == 1]
    fn_class_contrail = fn[fn['class_id'] == 0]
    fn_class_aircraft = fn[fn['class_id'] == 1]

    tp_weather_clear = tp[tp['weather'] == "clear_sky"]
    tp_weather_clouds = tp[tp['weather'] == "clouds"]
    tp_weather_overcast = tp[tp['weather'] == "overcast"]
    fp_weather_clear = fp[fp['weather'] == "clear_sky"]
    fp_weather_clouds = fp[fp['weather'] == "clouds"]
    fp_weather_overcast = fp[fp['weather'] == "overcast"]
    fn_weather_clear = fn[fn['weather'] == "clear_sky"]
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
    fn_no_sunset = fn[fn['sunset'] == False]

    # Evaluation
    eval = compute_metrics("all", tp, fp, fn)

    eval_class_contrail = compute_metrics("class_contrail", tp_class_contrail, fp_class_contrail, fn_class_contrail)
    eval_class_aircraft = compute_metrics("class_aircraft", tp_class_aircraft, fp_class_aircraft, fn_class_aircraft)

    eval_weather_clear = compute_metrics("weather_clear", tp_weather_clear, fp_weather_clear, fn_weather_clear)
    eval_weather_clouds = compute_metrics("weather_clouds", tp_weather_clouds, fp_weather_clouds, fn_weather_clouds)
    eval_weather_overcast = compute_metrics("weather_overcast", tp_weather_overcast, fp_weather_overcast, fn_weather_overcast)

    eval_bird = compute_metrics("bird", tp_bird, fp_bird, fn_bird)
    eval_no_bird = compute_metrics("no_bird", tp_no_bird, fp_no_bird, fn_no_bird)

    eval_contrail = compute_metrics("contrail", tp_contrail, fp_contrail, fn_contrail)
    eval_no_contrail = compute_metrics("no_contrail", tp_no_contrail, fp_no_contrail, fn_no_contrail)

    eval_window = compute_metrics("window", tp_window, fp_window, fn_window)
    eval_no_window = compute_metrics("no_window", tp_no_window, fp_no_window, fn_no_window)

    eval_sunset = compute_metrics("sunset", tp_sunset, fp_sunset, fn_sunset)
    eval_no_sunset = compute_metrics("no_sunset", tp_no_sunset, fp_no_sunset, fn_no_sunset)

    result_df = pd.DataFrame([
        eval,
        eval_class_contrail,
        eval_class_aircraft,
        eval_weather_clear,
        eval_weather_clouds,
        eval_weather_overcast,
        eval_bird,
        eval_no_bird,
        eval_contrail,
        eval_no_contrail,
        eval_window,
        eval_no_window,
        eval_sunset,
        eval_no_sunset,
    ])

    # print(f"Recall: {eval['recall']}")
    # print(f"Precision: {eval['precision']}")
    # print(f"F1 Score: {eval['f1']}")
    # print(f"Center Error Avg: {eval['center_error_avg']}")
    # print(f"IoU Avg: {eval['iou_avg']}")
    # print(f"Confidence Avg: {eval['confidence_avg']}")

    return result_df


def main():

    # # Read files
    # predictions_df = pd.read_csv(synthetic_predictions_path)
    # ground_truth_df = pd.read_csv(synthetic_ground_truth_path)
    #
    # # Perform evaluation
    # evaluation_df = evaluate(predictions_df, ground_truth_df)

    for folder in os.listdir("results"):
        if folder.startswith('.'):
            continue

        print(f"Evaluating {folder}")

        prediction_path = os.path.join("results", folder, "predictions.csv")
        ground_truth_path = os.path.join("results", folder, "ground_truth.csv")

        # Read files
        predictions_df = pd.read_csv(prediction_path)
        ground_truth_df = pd.read_csv(ground_truth_path)

        # Perform evaluation
        evaluation_df = evaluate(predictions_df, ground_truth_df)

        evaluation_df.to_csv(os.path.join("results", folder, "evaluation.csv"), index=False)


if __name__ == "__main__":
    main()
