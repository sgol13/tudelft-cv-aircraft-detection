import 'package:app/domain/model/events/real_time_event.dart';

import '../aircrafts/aircraft_3d.dart';


class LocalizedAircraftsEvent extends RealTimeEvent {
  final List<Aircraft3d> aircrafts;

  LocalizedAircraftsEvent({required this.aircrafts, required super.timestamp});

  String get preview => '\n${aircrafts.map((aircraft) => aircraft.preview).join('\n')}';
}