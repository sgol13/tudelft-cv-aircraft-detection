import 'package:app/domain/model/detected_aircraft.dart';
import 'package:app/domain/model/real_time_event.dart';

class DetectedAircraftsEvent extends RealTimeEvent {
  final List<DetectedAircraft> aircrafts;

  DetectedAircraftsEvent({
    required this.aircrafts,
    required super.timestamp,
  });

  String get preview =>
      '[${aircrafts.length}]';
}
