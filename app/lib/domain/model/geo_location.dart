import '../../common.dart';

class GeoLocation {
  final double lat; // degrees, [-90, 90]
  final double lon; // degrees, [-180, 180]
  final double alt; // meters

  double get latRad => degToRad(lat);

  double get lonRad => degToRad(lon);

  const GeoLocation({
    required this.lat,
    required this.lon,
    required this.alt,
  });
}
