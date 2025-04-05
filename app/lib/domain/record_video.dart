import 'package:app/port/out/camera_port.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:path_provider/path_provider.dart';

part 'record_video.g.dart';

class RecordVideo {
  final CameraPort _cameraPort;

  RecordVideo(this._cameraPort);

  Future<void> startRecording() async => await _cameraPort.startRecording();

  Future<void> stopRecording() async {
    final directory = await getExternalStorageDirectory();
    final filename = '${DateTime.now().millisecondsSinceEpoch}.mp4';
    final path = '${directory!.path}/$filename';

    await _cameraPort.stopRecording(path);
  }
}

@riverpod
RecordVideo recordVideo(Ref ref) {
  final cameraPort = ref.watch(cameraPortProvider);
  return RecordVideo(cameraPort);
}
