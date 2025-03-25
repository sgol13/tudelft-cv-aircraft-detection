import 'package:app/domain/model/aircraft_2d.dart';
import 'package:app/domain/model/events/real_time_event.dart';

class AircraftsOnPlaneEvent extends RealTimeEvent {
  final List<Aircraft2d> aircrafts;

  AircraftsOnPlaneEvent({required this.aircrafts, required super.timestamp});

  String get preview => '[${aircrafts.length}]';
}
