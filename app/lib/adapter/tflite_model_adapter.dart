import 'package:app/domain/model/aircrafts/detected_aircraft.dart';
import 'package:app/port/out/detection_model_port.dart';
import 'package:camera/src/camera_image.dart';
import 'package:tflite/tflite.dart';

class TfLiteModelAdapter extends DetectionModelPort {
  static final String _modelPath = "assets/yolov8n_640.tflite";
  static final String _labelPath = "assets/yolov8n_640_labels.txt";

  TfLiteModelAdapter() {
    _config();
  }

  @override
  Future<List<DetectedAircraft>?> detectAircrafts(CameraImage image) async {
    final input =
        image.planes.map((plane) {
          return plane.bytes;
        }).toList();

    final predictions = await Tflite.runModelOnFrame(
      bytesList: input,
      imageHeight: image.height,
      imageWidth: image.width,
      rotation: 90,
      numResults: 2,
      threshold: 0.1,
      asynch: true,
    );

    return Future.value(List.empty());
  }

  void _config() async {
    await Tflite.loadModel(
      model: _modelPath,
      labels: _labelPath,
      numThreads: 1,
      isAsset: true,
      useGpuDelegate: false,
    );
  }
}
