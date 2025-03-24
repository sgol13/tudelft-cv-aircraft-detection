import '../../common.dart';

class GeoLocation {
  final double latitude; // degrees, [-90, 90]
  final double longitude; // degrees, [-180, 180]
  final double altitude; // meters

  double get latitudeRad => degToRad(latitude);

  double get longitudeRad => degToRad(longitude);

  GeoLocation({
    required this.latitude,
    required this.longitude,
    required this.altitude,
  });
}
