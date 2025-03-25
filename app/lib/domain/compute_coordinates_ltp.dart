import 'dart:math';

import 'package:app/domain/compute_coordinates.dart';
import 'package:app/domain/model/geo_location.dart';
import 'package:vector_math/vector_math.dart';

class ComputeCoordinatesLTP extends ComputeCoordinates {
  static const double _earthRadius = 6_371_000;

  @override
  Vector3 compute(GeoLocation object, GeoLocation origin) {
    final x =
        (object.longitudeRad - origin.longitudeRad) *
        cos(origin.latitudeRad) *
        _earthRadius;

    final y = (object.latitudeRad - origin.latitudeRad) * _earthRadius;

    final z = object.altitude - origin.altitude;

    return Vector3(x, y, z);
  }
}
