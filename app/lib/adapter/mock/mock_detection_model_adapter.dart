import 'package:app/domain/model/aircrafts/detected_aircraft.dart';
import 'package:camera/camera.dart';

import '../../port/out/detection_model_port.dart';

class MockDetectionModelAdapter extends DetectionModelPort {
  @override
  Future<List<DetectedAircraft>?> detectAircrafts(CameraImage image) async {
    // await Future.delayed(Duration(milliseconds: 500));
    return Future.value(List.empty());
  }
}
