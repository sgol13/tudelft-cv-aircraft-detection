import 'package:app/domain/model/geo_location.dart';

class AdsbAircraft {
  GeoLocation geoLocation;
  final String? flight;

  AdsbAircraft({
    required this.geoLocation,
    required this.flight,
  });
}
