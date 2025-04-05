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

def count_unique_objects(xml_file_path, class_mapping=None):
    """
    Count unique objects in a CVAT XML file.
    
    Args:
        xml_file_path (str): Path to the CVAT XML file
        class_mapping (dict, optional): Dictionary mapping label names to class numbers
        
    Returns:
        tuple: (class_counts, label_counts) - Counters for classes and labels
    """
    try:
        # Parse the XML file
        tree = ET.parse(xml_file_path)
        root = tree.getroot()
        
        # Initialize counters
        class_counts = Counter()
        label_counts = Counter()
        
        # Apply the class mapping if provided
        if class_mapping is None:
            class_mapping = create_class_mapping()
        
        # Count unique objects in tracks (video annotations)
        # Each track represents a unique object across multiple frames
        for track in root.findall('.//track'):
            label = track.get('label')
            if label:
                # Only count if there's at least one box in this track
                boxes = track.findall('.//box')
                if boxes:
                    # Count this as one unique object of this label
                    label_counts[label] += 1
                    
                    # Map to class and count
                    if label in class_mapping:
                        class_id = class_mapping[label]
                        class_counts[str(class_id)] += 1
        
        return class_counts, label_counts
        
    except Exception as e:
        print(f"Error processing {xml_file_path}: {str(e)}")
        return Counter(), Counter()

def count_objects_in_folder(folder_path, class_mapping=None):
    """
    Count unique objects in all XML files in a folder.
    
    Args:
        folder_path (str): Path to the folder containing CVAT XML files
        class_mapping (dict, optional): Dictionary mapping label names to class numbers
        
    Returns:
        tuple: (total_class_counts, total_label_counts, total_files)
    """
    total_class_counts = Counter()
    total_label_counts = Counter()
    
    # Process files from a list or from a folder
    if os.path.isfile(folder_path) and folder_path.endswith('.xml'):
        xml_files = [folder_path]
    else:
        # Get all XML files in the folder
        xml_files = [os.path.join(folder_path, f) for f in os.listdir(folder_path) if f.endswith('.xml')]
    
    total_files = len(xml_files)
    
    if total_files == 0:
        print(f"No XML files found in {folder_path}")
        return total_class_counts, total_label_counts, 0
    
    # Process each XML file
    for xml_file in xml_files:
        class_counts, label_counts = count_unique_objects(xml_file, class_mapping)
        
        # Update total counts
        total_class_counts.update(class_counts)
        total_label_counts.update(label_counts)
    
    return total_class_counts, total_label_counts, total_files

def main():
    parser = argparse.ArgumentParser(description='Count unique objects in CVAT annotations')
    parser.add_argument('input', help='Path to the XML file or folder containing CVAT XML files')
    parser.add_argument('--original', action='store_true', help='Use original class mapping instead of binary classes')
    
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
    
    # Count objects
    total_class_counts, total_label_counts, total_files = count_objects_in_folder(args.input, class_mapping)
    
    # Print summary
    print(f"\nTotal files analyzed: {total_files}")
    
    if args.original:
        # For original mapping (8 classes), print total unique objects by class
        total_objects = 0
        print("\nTotal unique objects by class:")
        for i in range(8):
            class_id = str(i)
            count = total_class_counts.get(class_id, 0)
            name = class_names.get(class_id, f"Class {class_id}")
            print(f"{name} (Class {i}): {count}")
            total_objects += count
        print(f"Total objects: {total_objects}")
    else:
        # For binary mapping, print total unique contrails and aircraft
        contrail_count = total_class_counts.get('0', 0)
        aircraft_count = total_class_counts.get('1', 0)
        total_objects = contrail_count + aircraft_count
        
        print("\nTotal unique objects:")
        print(f"Contrails (Class 0): {contrail_count}")
        print(f"Aircraft (Class 1): {aircraft_count}")
        print(f"Total objects: {total_objects}")
    
    # If requested, show details by label (uncomment these lines to enable)
    # print("\nTotal unique objects by label:")
    # if total_label_counts:
    #     for label, count in sorted(total_label_counts.items(), key=lambda x: x[1], reverse=True):
    #         class_id = class_mapping.get(label, "unknown")
    #         print(f"{label} (Class {class_id}): {count}")

if __name__ == "__main__":
    main()
    