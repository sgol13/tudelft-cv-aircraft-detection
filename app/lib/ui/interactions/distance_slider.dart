// lib/ui/interactions/distance_slider.dart
import 'package:app/port/in/app_settings_port.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DistanceSlider extends ConsumerStatefulWidget {
  const DistanceSlider({super.key});

  @override
  _DistanceSliderState createState() => _DistanceSliderState();
}

class _DistanceSliderState extends ConsumerState<DistanceSlider> {
  double _sliderValue = 50.0;

  @override
  Widget build(BuildContext context) {
    final appSettingsPort = ref.watch(appSettingsPortProvider);

    return Padding(
      padding: const EdgeInsets.only(left: 16.0), // Add padding to the left
      child: Row(
        children: [
          Text(
            'Distance ${_sliderValue.round().toString().padLeft(3)} km',
            style: const TextStyle(color: Colors.white, fontFamily: 'Monaco'), // Set text color to white
          ),
          Expanded(
            child: Slider(
              value: _sliderValue,
              min: 5,
              max: 100,
              divisions: 19,
              onChanged: (value) {
                setState(() {
                  _sliderValue = value;
                  appSettingsPort.setMaxDistance(value * 1000);
                });
                // myRiverpodObject.someMethod(_sliderValue);
              },
            ),
          ),
        ],
      ),
    );
  }
}