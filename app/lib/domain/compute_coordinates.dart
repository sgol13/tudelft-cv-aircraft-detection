import 'package:app/domain/model/geo_location.dart';
import 'package:flutter_rotation_sensor/flutter_rotation_sensor.dart';

abstract class ComputeCoordinates {
  Vector3 compute(GeoLocation object, GeoLocation origin);
}
