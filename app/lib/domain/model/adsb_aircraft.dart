import 'package:app/domain/model/geo_location.dart';

class AdsbAircraft {
  final GeoLocation geoLocation;
  final String? flight;

  const AdsbAircraft({
    required this.geoLocation,
    required this.flight,
  });
}
