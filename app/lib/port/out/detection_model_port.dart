import 'package:app/adapter/tflite_model_adapter/tflite_model_adapter.dart';
import 'package:app/adapter/ultralytics_model_adapter/ultralytics_jpg_model_adapter.dart';
import 'package:app/domain/model/detected_aircraft.dart';
import 'package:camera/camera.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'detection_model_port.g.dart';

abstract class DetectionModelPort {

  Future<List<DetectedAircraft>?> detectAircrafts(CameraImage image);
}

@riverpod
DetectionModelPort detectionModelPort(Ref ref) => UltralyticsJpgModelAdapter();
