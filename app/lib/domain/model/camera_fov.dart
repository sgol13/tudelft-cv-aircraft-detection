class CameraFoV {
  final double horizontal;
  final double vertical;

  CameraFoV({required this.horizontal, required this.vertical}) {
    assert(vertical >= horizontal);
  }
}
