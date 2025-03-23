class DetectedAircraft {
  final double x;
  final double y;

  final double width;
  final double height;

  final int classIndex;

  final double score;

  DetectedAircraft({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.classIndex,
    required this.score,
  });
}
