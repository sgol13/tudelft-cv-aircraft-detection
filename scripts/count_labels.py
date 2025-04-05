import os
import xml.etree.ElementTree as ET
import argparse
from collections import Counter

def create_class_mapping():
    """Create a mapping of class names to YOLO class indices with fused classes"""
    # Original mapping
    original_mapping = {
        'contrail': 0,
        'high_airliner': 1,
        'low_airliner': 2,
        'light_airplane': 3,
        'helicopter': 4,
        'other': 5,
        'high_airliner_contrail': 6,
        'faint_contrail': 7
    }
    
    # Fused mapping - contrail and faint_contrail become 'contrail' (class 0)
    # All other classes become 'aircraft' (class 1)
    fused_mapping = {
        'contrail': 0,       # Keep as contrail (class 0)
        'high_airliner': 1,  # Map to aircraft (class 1)
        'low_airliner': 1,   # Map to aircraft (class 1)
        'light_airplane': 1, # Map to aircraft (class 1)
        'helicopter': 1,     # Map to aircraft (class 1)
        'other': 1,          # Map to aircraft (class 1)
        'high_airliner_contrail': 1,  # Map to aircraft (class 1)
        'faint_contrail': 0  # Map to contrail (class 0)
    }
    
    return fused_mapping

def check_classes_in_file(xml_file_path, class_mapping=None):
    """
    Check if a CVAT XML file contains annotations for each class.
    
    Args:
        xml_file_path (str): Path to the CVAT XML file
        class_mapping (dict, optional): Dictionary mapping label names to class numbers
        
    Returns:
        set: Set of class IDs present in the file
    """
    try:
        # Parse the XML file
        tree = ET.parse(xml_file_path)
        root = tree.getroot()
        
        # Initialize set to track which classes are present
        present_classes = set()
        
        # Apply the class mapping if provided
        if class_mapping is None:
            class_mapping = create_class_mapping()
        
        # Check annotations in tracks (for video annotations)
        for track in root.findall('.//track'):
            label = track.get('label')
            if label and track.findall('.//box') and label in class_mapping:
                # Add the mapped class to present classes
                class_id = class_mapping[label]
                present_classes.add(str(class_id))
        
        # Check annotations in images (for image annotations)
        for image in root.findall('.//image'):
            for box in image.findall('.//box'):
                label = box.get('label')
                if label and label in class_mapping:
                    class_id = class_mapping[label]
                    present_classes.add(str(class_id))
        
        return present_classes
        
    except Exception as e:
        print(f"Error processing {xml_file_path}: {str(e)}")
        return set()

def count_videos_with_classes(folder_path, class_mapping=None):
    """
    Count how many videos (XML files) contain at least one annotation of each class.
    
    Args:
        folder_path (str): Path to the folder containing CVAT XML files
        class_mapping (dict, optional): Dictionary mapping label names to class numbers
        
    Returns:
        tuple: (class_counts, total_videos)
    """
    # Counter for files containing each class
    class_counts = Counter()
    
    # Get all XML files in the folder
    if os.path.isfile(folder_path) and folder_path.endswith('.xml'):
        xml_files = [folder_path]
    else:
        xml_files = [os.path.join(folder_path, f) for f in os.listdir(folder_path) if f.endswith('.xml')]
    
    total_videos = len(xml_files)
    
    if total_videos == 0:
        print(f"No XML files found in {folder_path}")
        return class_counts, 0
    
    # Process each XML file
    for xml_file in xml_files:
        present_classes = check_classes_in_file(xml_file, class_mapping)
        
        # Increment counters for each class present in this file
        for class_id in present_classes:
            class_counts[class_id] += 1
    
    return class_counts, total_videos

def main():
    parser = argparse.ArgumentParser(description='Count videos containing each class of annotation')
    parser.add_argument('input', help='Path to the XML file or folder containing CVAT XML files')
    parser.add_argument('--original', action='store_true', help='Use original class mapping instead of binary classes')
    parser.add_argument('--detailed', action='store_true', help='Show detailed label counts (not just classes)')
    
    args = parser.parse_args()
    
    # Create class mapping based on command-line arguments
    if args.original:
        class_mapping = {
            'contrail': 0,
            'high_airliner': 1,
            'low_airliner': 2,
            'light_airplane': 3,
            'helicopter': 4,
            'other': 5,
            'high_airliner_contrail': 6,
            'faint_contrail': 7
        }
        class_names = {
            '0': 'contrail',
            '1': 'high_airliner',
            '2': 'low_airliner',
            '3': 'light_airplane',
            '4': 'helicopter',
            '5': 'other',
            '6': 'high_airliner_contrail',
            '7': 'faint_contrail'
        }
    else:
        class_mapping = create_class_mapping()
        class_names = {
            '0': 'contrail',
            '1': 'aircraft'
        }
    
    # Count videos
    class_counts, total_videos = count_videos_with_classes(args.input, class_mapping)
    
    # Print results
    print(f"\nTotal videos analyzed: {total_videos}")
    print("Videos containing at least one instance of:")
    
    if args.original:
        # Print for original 8-class mapping
        for i in range(8):
            class_id = str(i)
            count = class_counts.get(class_id, 0)
            percent = (count / total_videos) * 100 if total_videos > 0 else 0
            name = class_names.get(class_id, f"Class {class_id}")
            print(f"- {name}: {count} videos ({percent:.1f}%)")
    else:
        # Print for binary class mapping
        # Class 0 (contrail)
        contrail_count = class_counts.get('0', 0)
        contrail_percent = (contrail_count / total_videos) * 100 if total_videos > 0 else 0
        print(f"- Contrail (Class 0): {contrail_count} videos ({contrail_percent:.1f}%)")
        
        # Class 1 (aircraft)
        aircraft_count = class_counts.get('1', 0)
        aircraft_percent = (aircraft_count / total_videos) * 100 if total_videos > 0 else 0
        print(f"- Aircraft (Class 1): {aircraft_count} videos ({aircraft_percent:.1f}%)")
        
        # Videos with both classes
        videos_with_both = sum(1 for xml_file in (
            [args.input] if os.path.isfile(args.input) and args.input.endswith('.xml') 
            else [os.path.join(args.input, f) for f in os.listdir(args.input) if f.endswith('.xml')]
        ) if '0' in check_classes_in_file(xml_file, class_mapping) and '1' in check_classes_in_file(xml_file, class_mapping))
        
        both_percent = (videos_with_both / total_videos) * 100 if total_videos > 0 else 0
        print(f"- Both contrail and aircraft: {videos_with_both} videos ({both_percent:.1f}%)")

if __name__ == "__main__":
    main()