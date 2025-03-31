import 'package:app/domain/model/detected_aircraft.dart';
import 'package:app/port/out/detection_model_port.dart';
import 'package:camera/src/camera_image.dart';

class TfLiteModelAdapter extends DetectionModelPort {

  TfLiteModelAdapter() {
    _config();
  }

  @override
  Future<List<DetectedAircraft>?> detectAircrafts(CameraImage image) async {
    
    await Future.delayed(Duration(seconds: 1));
    return Future.value(List.empty());
  }


  void _config() async {

  }
}
