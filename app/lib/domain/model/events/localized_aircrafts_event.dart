import 'package:app/domain/model/events/real_time_event.dart';

import '../aircraft_3d.dart';

class LocalizedAircraftsEvent extends RealTimeEvent {
  final List<Aircraft3d> aircrafts;

  LocalizedAircraftsEvent({required this.aircrafts, required super.timestamp});
}