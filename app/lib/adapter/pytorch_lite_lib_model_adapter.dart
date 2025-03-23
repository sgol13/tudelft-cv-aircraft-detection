import 'package:app/domain/model/detected_aircraft.dart';
import 'package:app/port/out/detection_model_port.dart';
import 'package:camera/camera.dart';
import 'package:camera/src/camera_image.dart';
import 'package:pytorch_lite/pytorch_lite.dart';

class PytorchLiteLibModelAdapter extends DetectionModelPort {
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
      minimumScore: 0.1,
      boxesLimit: 10,
    )).map(_toDetectedAircraft).toList();
  }

  DetectedAircraft _toDetectedAircraft(ResultObjectDetection result) {
    final double x = (result.rect.left + result.rect.right) / 2;
    final double y = (result.rect.top + result.rect.bottom) / 2;

    return DetectedAircraft(
      x: x,
      y: y,
      width: result.rect.width,
      height: result.rect.height,
      classIndex: result.classIndex,
      score: result.score,
    );
  }

  _initializeModel() async {
    _model = await PytorchLite.loadObjectDetectionModel(
      "assets/model_v1.torchscript",
      8,
      1280,
      1280,
      labelPath: "assets/model_v1_labels.txt",
      objectDetectionModelType: ObjectDetectionModelType.yolov8,
    );
  }
}
