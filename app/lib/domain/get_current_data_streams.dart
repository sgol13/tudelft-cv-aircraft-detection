import 'package:app/domain/get_real_data_streams.dart';
import 'package:app/domain/model/events/adsb_event.dart';
import 'package:app/domain/model/events/device_location_event.dart';
import 'package:app/domain/model/events/device_orientation_event.dart';
import 'package:app/domain/model/events/video_frame_event.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'get_data_streams.dart';

part 'get_current_data_streams.g.dart';

class GetCurrentDataStreams extends GetDataStreams {
  final GetRealDataStreams _getRealDataStreams;

  GetCurrentDataStreams(this._getRealDataStreams);

  @override
  Stream<DeviceOrientationEvent> get deviceOrientationStream =>
      _getRealDataStreams.deviceOrientationStream;

  @override
  Stream<DeviceLocationEvent> get deviceLocationStream =>
      _getRealDataStreams.deviceLocationStream;

  @override
  Stream<VideoFrameEvent> get cameraStream => _getRealDataStreams.cameraStream;

  @override
  Stream<AdsbEvent> get adsbStream => _getRealDataStreams.adsbStream;
}

@riverpod
GetCurrentDataStreams getCurrentDataStreams(Ref ref) {
  final getRealDataStreams = ref.watch(getRealDataStreamsProvider);

  return GetCurrentDataStreams(getRealDataStreams);
}
