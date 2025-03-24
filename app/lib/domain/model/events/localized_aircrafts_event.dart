import 'package:app/domain/model/events/real_time_event.dart';

import '../localized_adsb_aircraft.dart';

class LocalizedAircraftsEvent extends RealTimeEvent {
  final List<LocalizedAdsbAircraft> aircrafts;

  LocalizedAircraftsEvent({required this.aircrafts, required super.timestamp});
}