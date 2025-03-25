import 'package:app/domain/model/adsb_aircraft_on_screen.dart';
import 'package:app/domain/model/events/real_time_event.dart';

class AircraftsOnScreenEvent extends RealTimeEvent {
  final List<AdsbAircraftOnScreen> aircrafts;

  AircraftsOnScreenEvent({required this.aircrafts, required super.timestamp});

  String get preview => '[${aircrafts.length}]';
}
