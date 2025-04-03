import 'package:app/domain/model/aircrafts/estimated_aircraft.dart';
import 'package:app/domain/model/events/real_time_event.dart';

class AircraftsOnScreenEvent extends RealTimeEvent {
  final List<EstimatedAircraft> aircrafts;

  AircraftsOnScreenEvent({required this.aircrafts, required super.timestamp});

  // String get preview => '\n${aircrafts.map((aircraft) => aircraft.preview).join('\n')}';

  String get preview => '${aircrafts.length}';
}
