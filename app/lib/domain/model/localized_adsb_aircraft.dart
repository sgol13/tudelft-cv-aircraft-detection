import 'package:app/domain/model/adsb_aircraft.dart';

class LocalizedAdsbAircraft {
  final AdsbAircraft adsb;

  final double x;
  final double y;
  final double z;

  LocalizedAdsbAircraft({
    required this.adsb,
    required this.x,
    required this.y,
    required this.z,
  });
}
