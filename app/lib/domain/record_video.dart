import 'package:app/domain/estimate_aircraft_2d_positions.dart';
import 'package:app/port/out/camera_port.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:path_provider/path_provider.dart';

part 'record_video.g.dart';

class RecordVideo {
  final CameraPort _cameraPort;
  final EstimateAircraft2dPositions _estimateAircraft2dPositions;

  RecordVideo(this._cameraPort, this._estimateAircraft2dPositions);

  Future<void> startRecording() async => await _cameraPort.startRecording();

  Future<void> stopRecording() async {
    final directory = await getExternalStorageDirectory();
    final name = '${DateTime.now().millisecondsSinceEpoch}';
    final path = '${directory!.path}/$name.mp4';

    await _cameraPort.stopRecording(path);
  }
}

@riverpod
RecordVideo recordVideo(Ref ref) {
  final cameraPort = ref.watch(cameraPortProvider);
  final estimateAircraft2dPositions = ref.watch(estimateAircraft2dPositionsProvider);
  return RecordVideo(cameraPort, estimateAircraft2dPositions);
}
