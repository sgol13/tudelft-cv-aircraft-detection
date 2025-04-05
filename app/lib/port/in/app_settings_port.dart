import 'package:app/domain/filter_adsb_aircrafts.dart';
import 'package:app/domain/record_video.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_settings_port.g.dart';

class AppSettingsPort {
  final FilterAdsbAircrafts _filterAdsbAircrafts;
  final RecordVideo _recordVideo;

  AppSettingsPort(this._filterAdsbAircrafts, this._recordVideo);

  void setMaxDistance(double value) => _filterAdsbAircrafts.maxDistance = value;

  void setGroundFilter(bool value) => _filterAdsbAircrafts.groundFilter = value;

  Future<void> startRecording() async => await _recordVideo.startRecording();

  Future<void> stopRecording() async => await _recordVideo.stopRecording();
}

@riverpod
AppSettingsPort appSettingsPort(Ref ref) {
  final filterAdsbAircrafts = ref.watch(filterAdsbAircraftsProvider);
  final recordVideo = ref.watch(recordVideoProvider);

  return AppSettingsPort(filterAdsbAircrafts, recordVideo);
}
