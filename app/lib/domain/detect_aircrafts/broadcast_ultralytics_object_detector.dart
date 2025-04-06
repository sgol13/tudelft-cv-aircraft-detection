import 'package:ultralytics_yolo/predict/detect/detect.dart';

class BroadcastUltralyticsObjectDetector extends ObjectDetector {
  BroadcastUltralyticsObjectDetector({required super.model});

  @override
  Stream<List<DetectedObject?>?> get detectionResultStream =>
      super.detectionResultStream.asBroadcastStream();
}
