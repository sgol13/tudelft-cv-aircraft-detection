import 'package:freezed_annotation/freezed_annotation.dart';

part 'position.freezed.dart';

@freezed
class Position with _$Position {
  const factory Position({
    required double x,
    required double y,
    required DateTime timestamp,
  }) = _Position;

  const Position._();

  String get preview =>
      '[${formatValue(x)}, ${formatValue(y)}}]';

  static String formatValue(double value) =>
      value.toStringAsFixed(3).padLeft(8);
}