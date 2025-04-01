import argparse
import tensorflow.lite as tflite

def analyze_model(model_path: str):
    # Load the TFLite model
    interpreter = tflite.Interpreter(model_path=model_path)
    interpreter.allocate_tensors()

    # Get input details
    input_details = interpreter.get_input_details()
    print("Input Tensors:")
    for i, detail in enumerate(input_details):
        print(f"  Input {i}: shape = {detail['shape']}, type = {detail['dtype']}")

    # Get outpu
    output_details = interpreter.get_output_details()
    print("\nOutput Tensors:")
    for i, detail in enumerate(output_details):
        print(f"  Output {i}: shape = {detail['shape']}, type = {detail['dtype']}")

def main():
    parser = argparse.ArgumentParser(description='Analyze a TFLite model')
    parser.add_argument('model_path', type=str, help='Path to the TFLite model')

    args = parser.parse_args()
    analyze_model(args.model_path)

if __name__ == "__main__":
    main()