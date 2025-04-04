import 'package:app/port/in/app_settings_port.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GroundFilterButton extends ConsumerStatefulWidget {
  const GroundFilterButton({super.key});

  @override
  _GroundFilterButtonState createState() => _GroundFilterButtonState();
}

class _GroundFilterButtonState extends ConsumerState<GroundFilterButton> {
  bool _isGroundFilterOn = false;

  @override
  Widget build(BuildContext context) {
    final appSettingsPort = ref.watch(appSettingsPortProvider);

    return Padding(
      padding: const EdgeInsets.all(0.0),
      child: SizedBox(
        width: 130, // Set the desired width
        height: 40, // Set the desired height
        child: ElevatedButton(
          onPressed: () {
            setState(() {
              _isGroundFilterOn = !_isGroundFilterOn;
              appSettingsPort.setGroundFilter(_isGroundFilterOn);
            });
          },
          child: Text(_isGroundFilterOn ? 'Ground: NO ' : 'Ground: YES'),
        ),
      ),
    );
  }
}
