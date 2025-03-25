import 'package:app/domain/model/adsb_aircraft.dart';
import 'package:vector_math/vector_math.dart';

class LocalizedAdsbAircraft {
  final AdsbAircraft adsb;

  final Vector3 relativeLocation;

  LocalizedAdsbAircraft({required this.adsb, required this.relativeLocation});
}
