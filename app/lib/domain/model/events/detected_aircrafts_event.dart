import 'package:app/domain/model/aircrafts/detected_aircraft.dart';
import 'package:app/domain/model/events/real_time_event.dart';

class DetectedAircraftsEvent extends RealTimeEvent {
  final List<DetectedAircraft> aircrafts;

  DetectedAircraftsEvent({
    required this.aircrafts,
    required super.timestamp,
  });

  String get preview => '\n${aircrafts.map((aircraft) => aircraft.preview).join('\n')}';
}
