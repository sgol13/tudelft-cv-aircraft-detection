import 'package:app/domain/get_current_data_streams.dart';
import 'package:app/domain/model/device_orientation.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rxdart/rxdart.dart';

part 'estimate_orientation.g.dart';

class EstimateOrientation {
  final GetCurrentDataStreams _currentDataStreams;

  EstimateOrientation(this._currentDataStreams);

  Stream<DeviceOrientation> get stream => FlutterCompass.events!
      .map((compassEvent) => compassEvent.heading)
      .whereNotNull()
      .map(
        (heading) =>
            DeviceOrientation(heading: heading, timestamp: DateTime.now()),
      );
}

@riverpod
EstimateOrientation estimateOrientation(Ref ref) {
  final getCurrentDataStreams = ref.watch(getCurrentDataStreamsProvider);

  return EstimateOrientation(getCurrentDataStreams);
}
