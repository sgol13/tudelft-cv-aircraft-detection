import 'package:app/domain/get_current_data_streams.dart';
import 'package:app/domain/model/localized_adsb_aircraft.dart';
import 'package:app/domain/model/events/localized_aircrafts_event.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

class LocalizeAdsbAircrafts {
  final GetCurrentDataStreams _getCurrentDataStreams;

  LocalizeAdsbAircrafts(this._getCurrentDataStreams);

  Stream<LocalizedAircraftsEvent> get stream {
    return Stream.empty();
  }
}

@riverpod
LocalizeAdsbAircrafts localizeAdsbAircrafts(Ref ref) {
  final getCurrentDataStreams = ref.watch(getCurrentDataStreamsProvider);

  return LocalizeAdsbAircrafts(getCurrentDataStreams);
}
