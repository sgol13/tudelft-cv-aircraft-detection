import 'package:app/domain/model/aircraft_2d.dart';
import 'package:app/domain/model/events/real_time_event.dart';

class AircraftsOnScreenEvent extends RealTimeEvent {
  final List<Aircraft2d> aircrafts;

  AircraftsOnScreenEvent({required this.aircrafts, required super.timestamp});

  String get preview => '\n${aircrafts.map((aircraft) => aircraft.preview).join('\n')}';
}
