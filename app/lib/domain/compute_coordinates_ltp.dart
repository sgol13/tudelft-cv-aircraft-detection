import 'dart:math';

import 'package:app/domain/compute_coordinates.dart';
import 'package:app/domain/model/geo_location.dart';
import 'package:vector_math/vector_math.dart';

class ComputeCoordinatesLTP extends ComputeCoordinates {
  // Local Tangent Plane (LTP) coordinates in ENU variant.
  // WGS84 ellipsoid is used for geodetic coordinates.

  // Sources:
  // https://en.wikipedia.org/wiki/Geographic_coordinate_conversion
  // https://en.wikipedia.org/wiki/Local_tangent_plane_coordinates
  // https://en.wikipedia.org/wiki/World_Geodetic_System

  // WGS84 ellipsoid parameters
  static const double _a = 6378137.0; // Semi-major axis [m]
  static const double _b = 6356752.31424518; // Semi-minor axis [m]

  // First ellipsoid eccentricity ^2
  static const double _e2 = 1 - (_b * _b) / (_a * _a);

  @override
  Vector3 compute(GeoLocation object, GeoLocation origin) {
    final objectEcef = _geoToEcef(object.latRad, object.lonRad, object.alt);
    final originEcef = _geoToEcef(origin.latRad, origin.lonRad, origin.alt);

    final x = objectEcef.x - originEcef.x;
    final y = objectEcef.y - originEcef.y;
    final z = objectEcef.z - originEcef.z;

    return _ecefToEnu(x, y, z, origin.latRad, origin.lonRad);
  }

  Vector3 _geoToEcef(double lat, double lon, double alt) {
    final N = _a / sqrt(1 - _e2 / pow(sin(lat), 2));

    final x = (N + alt) * cos(lat) * cos(lon);
    final y = (N + alt) * cos(lat) * sin(lon);
    final z = ((1 - _e2) * N + alt) * sin(lat);

    return Vector3(x, y, z);
  }

  Vector3 _ecefToEnu(double x, double y, double z, double lat0, double lon0) {
    final t = cos(lon0) * x + sin(lon0) * y;

    final east = -sin(lon0) * x + cos(lon0) * y;
    final up = cos(lat0) * t + sin(lat0) * z;
    final north = -sin(lat0) * t + cos(lat0) * z;

    return Vector3(east, north, up);
  }
}
