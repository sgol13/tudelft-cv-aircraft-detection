import 'package:app/domain/model/detected_aircraft.dart';
import 'package:app/port/out/detection_model_port.dart';
import 'package:camera/camera.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

class TfLiteModelAdapter extends DetectionModelPort {
  static final String _modelPath = "assets/yolov8n_float16.tflite";

  late final Interpreter _interpreter;

  TfLiteModelAdapter() {
    _config();
  }

  @override
  Future<List<DetectedAircraft>?> detectAircrafts(CameraImage image) async {


    await Future.delayed(Duration(seconds: 1));
    return Future.value(List.empty());
  }

  void _config() async {
    final interpreterOptions = InterpreterOptions()..threads = 4;

    _interpreter = await Interpreter.fromAsset(_modelPath, options: interpreterOptions);
    _interpreter.allocateTensors();
  }
}
