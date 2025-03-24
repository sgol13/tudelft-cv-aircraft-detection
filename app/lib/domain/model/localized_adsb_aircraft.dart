import 'package:app/domain/model/adsb_aircraft.dart';
import 'package:flutter_rotation_sensor/flutter_rotation_sensor.dart';

class LocalizedAdsbAircraft {
  final AdsbAircraft adsb;

  final Vector3 relativeLocation;

  LocalizedAdsbAircraft({required this.adsb, required this.relativeLocation});
}
