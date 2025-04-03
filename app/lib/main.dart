import 'package:app/ui/camera_view.dart';
import 'package:app/ui/debug_view.dart';
import 'package:app/ui/interactions/distance_slider.dart';
import 'package:app/ui/interactions/ground_filter_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.black,
        body: Column(
          children: [
            Stack(children: [CameraView(), DebugView()]),
            DistanceSlider(),
            GroundFilterButton()
          ],
        ),
      ),
    );
  }
}
