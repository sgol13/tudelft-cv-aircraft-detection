import 'package:app/domain/filter_adsb_aircrafts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_settings_port.g.dart';

class AppSettingsPort {
  final FilterAdsbAircrafts _filterAdsbAircrafts;

  AppSettingsPort(this._filterAdsbAircrafts);

  void setMaxDistance(double value) {
    _filterAdsbAircrafts.maxDistance = value;
  }

  void setGroundFilter(bool value) {
    _filterAdsbAircrafts.groundFilter = value;
  }
}

@riverpod
AppSettingsPort appSettingsPort(Ref ref) {
  final filterAdsbAircrafts = ref.watch(filterAdsbAircraftsProvider);
  return AppSettingsPort(filterAdsbAircrafts);
}
