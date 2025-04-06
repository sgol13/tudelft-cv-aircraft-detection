import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app/port/in/app_settings_port.dart';

class RecordButton extends ConsumerStatefulWidget {
  const RecordButton({super.key});

  @override
  _RecordButtonState createState() => _RecordButtonState();
}

class _RecordButtonState extends ConsumerState<RecordButton> {
  bool _isRecording = false;

  @override
  Widget build(BuildContext context) {
    final appSettingsPort = ref.watch(appSettingsPortProvider);

    return FloatingActionButton(
      onPressed: () async {
        if (_isRecording) {
          await appSettingsPort.stopRecording();
        } else {
          await appSettingsPort.startRecording();
        }
        setState(() {
          _isRecording = !_isRecording;
        });
      },
      child: Icon(_isRecording ? Icons.stop : Icons.videocam),
    );
  }
}