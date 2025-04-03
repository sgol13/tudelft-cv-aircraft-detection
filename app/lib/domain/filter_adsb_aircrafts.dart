import 'package:app/domain/localize_adsb_aircrafts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vector_math/vector_math.dart';

import 'model/aircrafts/aircraft_3d.dart';
import 'model/events/localized_aircrafts_event.dart';

part 'filter_adsb_aircrafts.g.dart';

class FilterAdsbAircrafts {
  final LocalizeAdsbAircrafts _localizeAdsbAircrafts;

  double _maxDistance = 1000;
  bool _isGroundFilterOn = false;

  FilterAdsbAircrafts(this._localizeAdsbAircrafts);

  Stream<LocalizedAircraftsEvent> get stream => _localizeAdsbAircrafts.stream.map((event) {
    final aircrafts = event.aircrafts.where(_filterDistance).where(_filterGround).toList();

    return LocalizedAircraftsEvent(aircrafts: aircrafts, timestamp: event.timestamp);
  });

  bool _filterDistance(Aircraft3d aircraft) => aircraft.distance <= _maxDistance;

  bool _filterGround(Aircraft3d aircraft) =>
      // todo: works only in the Netherlands (asssumes only aircraft < 300 m are on the ground)
      !_isGroundFilterOn || aircraft.adsb.geoLocation.alt >= 300;

  set maxDistance(double value) {
    _maxDistance = value;
  }

  set groundFilter(bool value) {
    _isGroundFilterOn = value;
  }
}

@riverpod
FilterAdsbAircrafts filterAdsbAircrafts(Ref ref) {
  final localizeAdsbAircrafts = ref.watch(localizeAdsbAircraftsProvider);
  return FilterAdsbAircrafts(localizeAdsbAircrafts);
}
