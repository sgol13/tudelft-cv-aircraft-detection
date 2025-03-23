import 'package:app/domain/model/detected_aircraft.dart';
import 'package:app/port/out/detection_model_port.dart';
import 'package:camera/src/camera_image.dart';

class PytorchLiteLibModelAdapter extends DetectionModelPort {
  @override
  List<DetectedAircraft> detectAircrafts(CameraImage image) {
    // TODO: implement detectAircrafts
    throw UnimplementedError();
  }

}
