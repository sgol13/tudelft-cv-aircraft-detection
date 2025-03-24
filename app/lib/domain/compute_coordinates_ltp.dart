import 'package:app/domain/compute_coordinates.dart';
import 'package:app/domain/model/geo_location.dart';
import 'package:flutter_rotation_sensor/src/math/vector3.dart';

class ComputeCoordinatesLTP extends ComputeCoordinates {

  @override
  Vector3 compute(GeoLocation object, GeoLocation origin) {


    return Vector3(1, 2, 3);
  }

}