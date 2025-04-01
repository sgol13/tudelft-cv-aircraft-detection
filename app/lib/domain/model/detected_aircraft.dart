import 'package:vector_math/vector_math.dart';

class DetectedAircraft {
  final Vector2 position;

  final double width;
  final double height;

  final int classIndex;
  final String? className;

  final double score;

  DetectedAircraft({
    required this.position,
    required this.width,
    required this.height,
    required this.classIndex,
    this.className,
    required this.score,
  });
}
