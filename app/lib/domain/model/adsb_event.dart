import 'package:app/domain/model/adsb_aircraft.dart';
import 'package:app/domain/model/real_time_event.dart';

class AdsbEvent extends RealTimeEvent {
  final List<AdsbAircraft> aircrafts;

  AdsbEvent({required this.aircrafts, required super.timestamp});
}
