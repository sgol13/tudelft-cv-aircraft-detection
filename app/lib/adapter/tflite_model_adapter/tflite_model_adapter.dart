import 'package:app/adapter/tflite_model_adapter/inner/detector.dart';
import 'package:app/domain/model/detected_aircraft.dart';
import 'package:app/port/out/detection_model_port.dart';
import 'package:camera/camera.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

class TfLiteModelAdapter extends DetectionModelPort {
  static final String _modelPath = "assets/yolov8n_float16.tflite";
  static final String _labelPath = "assets/yolov8n_labels.txt";

  Detector? _detector;

  TfLiteModelAdapter() {
    _config();
  }

  @override
  Future<List<DetectedAircraft>?> detectAircrafts(CameraImage image) async {
    if (_detector == null) {
      return Future.value(null);
    }

    _detector?.processFrame(image);

    final prediction = await _detector!.resultsStream.stream.first;

    return Future.value(List.empty());
  }

  void _config() async {
    Detector.start(_modelPath, _labelPath).then((instance) => _detector = instance);
  }
}
