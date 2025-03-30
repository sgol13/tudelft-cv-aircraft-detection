import 'package:app/adapter/mock/mock_detection_model_adapter.dart';
import 'package:app/adapter/onnx_model_adapter.dart';
import 'package:app/adapter/pytorch_lite_lib_model_adapter.dart';
import 'package:app/domain/model/detected_aircraft.dart';
import 'package:camera/camera.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'detection_model_port.g.dart';

abstract class DetectionModelPort {

  Future<List<DetectedAircraft>?> detectAircrafts(CameraImage image);
}

@riverpod
DetectionModelPort detectionModelPort(Ref ref) => OnnxModelAdapter();
