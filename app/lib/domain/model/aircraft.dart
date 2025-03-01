import 'package:freezed_annotation/freezed_annotation.dart';

part 'aircraft.freezed.dart';

@freezed
class Aircraft with _$Aircraft {
  const factory Aircraft({
    required double latitude,
    required double longitude,
    String? flight,
  }) = _Aircraft;
}