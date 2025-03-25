import 'package:app/common.dart';
import 'package:app/domain/compute_coordinates.dart';
import 'package:app/domain/compute_coordinates_ltp.dart';
import 'package:app/domain/get_current_data_streams.dart';
import 'package:app/domain/model/adsb_aircraft.dart';
import 'package:app/domain/model/events/adsb_event.dart';
import 'package:app/domain/model/events/device_location_event.dart';
import 'package:app/domain/model/geo_location.dart';
import 'package:app/domain/model/aircraft_3d.dart';
import 'package:app/domain/model/events/localized_aircrafts_event.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rxdart/rxdart.dart';

part 'localize_adsb_aircrafts.g.dart';

class LocalizeAdsbAircrafts {
  final GetCurrentDataStreams _getCurrentDataStreams;

  final ComputeCoordinates _computeCoordinates;

  LocalizeAdsbAircrafts(this._getCurrentDataStreams, this._computeCoordinates);

  Stream<LocalizedAircraftsEvent> get stream => Rx.combineLatest2(
    _getCurrentDataStreams.adsbStream,
    _getCurrentDataStreams.deviceLocationStream,
    _localizeAircrafts,
  );

  LocalizedAircraftsEvent _localizeAircrafts(
    AdsbEvent adsbEvent,
    DeviceLocationEvent locationEvent,
  ) {
    final aircrafts =
        adsbEvent.aircrafts
            .map(
              (adsb) => localizeAdsbAircraft(adsb, locationEvent.geoLocation),
            )
            .toList();

    return LocalizedAircraftsEvent(
      aircrafts: aircrafts,
      timestamp: maxTimestamp([adsbEvent.timestamp, locationEvent.timestamp]),
    );
  }

  Aircraft3d localizeAdsbAircraft(
    AdsbAircraft aircraft,
    GeoLocation deviceLocation,
  ) {
    final relativeLocation = _computeCoordinates.compute(
      aircraft.geoLocation,
      deviceLocation,
    );

    return Aircraft3d(
      adsb: aircraft,
      position: relativeLocation,
    );
  }
}

@riverpod
LocalizeAdsbAircrafts localizeAdsbAircrafts(Ref ref) {
  final getCurrentDataStreams = ref.watch(getCurrentDataStreamsProvider);
  final computeCoordinates = ComputeCoordinatesLTP();

  return LocalizeAdsbAircrafts(getCurrentDataStreams, computeCoordinates);
}
