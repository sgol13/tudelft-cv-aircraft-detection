import 'package:app/domain/model/aircrafts/detected_aircraft.dart';
import 'package:app/port/out/detection_model_port.dart';
import 'package:camera/camera.dart';
import 'package:camera/src/camera_image.dart';
import 'package:pytorch_lite/pytorch_lite.dart';
import 'package:vector_math/vector_math.dart';

class PytorchLiteLibModelAdapter extends DetectionModelPort {
  static final String _modelPath = "assets/yolov8n_960.torchscript";
  static final String _labelPath = "assets/yolov8n_960_labels.txt";

  ModelObjectDetection? _model;

  PytorchLiteLibModelAdapter() {
    _initializeModel();
  }

  @override
  Future<List<DetectedAircraft>?> detectAircrafts(CameraImage image) async {
    if (_model == null) return null;

    return (await _model!.getCameraImagePredictionList(
      image,
      rotation: 0,
      minimumScore: 0.0,
      boxesLimit: 10,
    )).map(_toDetectedAircraft).toList();
  }

  DetectedAircraft _toDetectedAircraft(ResultObjectDetection result) {
    final double x = (result.rect.left + result.rect.right) / 2;
    final double y = (result.rect.top + result.rect.bottom) / 2;

    return DetectedAircraft(
      pos: Vector2(x, y  ),
      width: result.rect.width,
      height: result.rect.height,
      classIndex: result.classIndex,
      className: result.className,
      score: result.score,
    );
  }

  _initializeModel() async {
    _model = await PytorchLite.loadObjectDetectionModel(
      _modelPath,
      80,
      960,
      960,
      labelPath: _labelPath,
      objectDetectionModelType: ObjectDetectionModelType.yolov8,
    );
  }
}
