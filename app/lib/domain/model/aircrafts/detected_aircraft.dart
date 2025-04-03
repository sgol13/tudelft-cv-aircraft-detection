import 'package:app/domain/model/aircrafts/aircraft_2d.dart';

class DetectedAircraft extends Aircraft2d {
  final double width;
  final double height;

  final int classIndex;
  final String? className;

  final double score;

  DetectedAircraft({
    required super.pos,
    required this.width,
    required this.height,
    required this.classIndex,
    this.className,
    required this.score,
  });
}
