import 'dart:io';

import 'package:app/domain/model/aircrafts/detected_aircraft.dart';
import 'package:app/port/out/detection_model_port.dart';
import 'package:camera/src/camera_image.dart';
import 'package:ultralytics_yolo/predict/detect/detect.dart';
import 'package:image/image.dart' as image_lib;
import 'package:ultralytics_yolo/yolo_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:vector_math/vector_math.dart';

import 'inner/image_utils.dart';

class UltralyticsJpgModelAdapter extends DetectionModelPort {
  static final String _modelPath = "assets/yolov8n_640.tflite";
  static final String _metadataPath = "assets/yolov8n_640_metadata.yaml";

  String? _jpgPath;
  late final ObjectDetector _detector;

  UltralyticsJpgModelAdapter() {
    _config();
  }

  @override
  Future<List<DetectedAircraft>?> detectAircrafts(CameraImage image) async {
    if (_jpgPath == null) {
      return Future.value(null);
    }

    final inputImage = await convertCameraImageToImage(image);
    await saveImage(inputImage!, _jpgPath!);

    await saveImage(inputImage!, '/storage/emulated/0/Download/frame.jpg');
    final predictions = await _detector.detect(imagePath: _jpgPath!);

    final aircrafts = predictions!.nonNulls.map(_predictionToAircraft).toList();

    return Future.value(aircrafts);
  }

  void _config() async {
    final jpgDirectory = (await getApplicationDocumentsDirectory()).path;
    _jpgPath = '$jpgDirectory/frame.jpg';

    final model = LocalYoloModel(
      id: 'yolov8n',
      task: Task.detect,
      format: Format.tflite,
      modelPath: _modelPath,
      metadataPath: _metadataPath,
    );

    _detector = ObjectDetector(model: model);
    _detector.loadModel(useGpu: true);
  }

  DetectedAircraft _predictionToAircraft(DetectedObject prediction) {
    final position = Vector2(prediction.boundingBox.center.dx, prediction.boundingBox.center.dy);

    return DetectedAircraft(
      position: position,
      width: prediction.boundingBox.width,
      height: prediction.boundingBox.height,
      classIndex: prediction.index,
      className: prediction.label,
      score: prediction.confidence,
    );
  }
}
