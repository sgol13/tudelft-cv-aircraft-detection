import 'package:app/domain/model/geo_location.dart';

class AdsbAircraft {
  final GeoLocation geoLocation;
  final String? flight;
  final String? icaoType;
  final double? heading;
  final double? speed;

  const AdsbAircraft({
    required this.geoLocation,
    required this.flight,
    required this.icaoType,
    required this.heading,
    required this.speed,
  });
}
