// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sensor_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$SensorData {
  double get x => throw _privateConstructorUsedError;
  double get y => throw _privateConstructorUsedError;
  double get z => throw _privateConstructorUsedError;
  DateTime get timestamp => throw _privateConstructorUsedError;

  /// Create a copy of SensorData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SensorDataCopyWith<SensorData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SensorDataCopyWith<$Res> {
  factory $SensorDataCopyWith(
    SensorData value,
    $Res Function(SensorData) then,
  ) = _$SensorDataCopyWithImpl<$Res, SensorData>;
  @useResult
  $Res call({double x, double y, double z, DateTime timestamp});
}

/// @nodoc
class _$SensorDataCopyWithImpl<$Res, $Val extends SensorData>
    implements $SensorDataCopyWith<$Res> {
  _$SensorDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SensorData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? x = null,
    Object? y = null,
    Object? z = null,
    Object? timestamp = null,
  }) {
    return _then(
      _value.copyWith(
            x:
                null == x
                    ? _value.x
                    : x // ignore: cast_nullable_to_non_nullable
                        as double,
            y:
                null == y
                    ? _value.y
                    : y // ignore: cast_nullable_to_non_nullable
                        as double,
            z:
                null == z
                    ? _value.z
                    : z // ignore: cast_nullable_to_non_nullable
                        as double,
            timestamp:
                null == timestamp
                    ? _value.timestamp
                    : timestamp // ignore: cast_nullable_to_non_nullable
                        as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SensorDataImplCopyWith<$Res>
    implements $SensorDataCopyWith<$Res> {
  factory _$$SensorDataImplCopyWith(
    _$SensorDataImpl value,
    $Res Function(_$SensorDataImpl) then,
  ) = __$$SensorDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({double x, double y, double z, DateTime timestamp});
}

/// @nodoc
class __$$SensorDataImplCopyWithImpl<$Res>
    extends _$SensorDataCopyWithImpl<$Res, _$SensorDataImpl>
    implements _$$SensorDataImplCopyWith<$Res> {
  __$$SensorDataImplCopyWithImpl(
    _$SensorDataImpl _value,
    $Res Function(_$SensorDataImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SensorData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? x = null,
    Object? y = null,
    Object? z = null,
    Object? timestamp = null,
  }) {
    return _then(
      _$SensorDataImpl(
        x:
            null == x
                ? _value.x
                : x // ignore: cast_nullable_to_non_nullable
                    as double,
        y:
            null == y
                ? _value.y
                : y // ignore: cast_nullable_to_non_nullable
                    as double,
        z:
            null == z
                ? _value.z
                : z // ignore: cast_nullable_to_non_nullable
                    as double,
        timestamp:
            null == timestamp
                ? _value.timestamp
                : timestamp // ignore: cast_nullable_to_non_nullable
                    as DateTime,
      ),
    );
  }
}

/// @nodoc

class _$SensorDataImpl implements _SensorData {
  const _$SensorDataImpl({
    required this.x,
    required this.y,
    required this.z,
    required this.timestamp,
  });

  @override
  final double x;
  @override
  final double y;
  @override
  final double z;
  @override
  final DateTime timestamp;

  @override
  String toString() {
    return 'SensorData(x: $x, y: $y, z: $z, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SensorDataImpl &&
            (identical(other.x, x) || other.x == x) &&
            (identical(other.y, y) || other.y == y) &&
            (identical(other.z, z) || other.z == z) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp));
  }

  @override
  int get hashCode => Object.hash(runtimeType, x, y, z, timestamp);

  /// Create a copy of SensorData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SensorDataImplCopyWith<_$SensorDataImpl> get copyWith =>
      __$$SensorDataImplCopyWithImpl<_$SensorDataImpl>(this, _$identity);
}

abstract class _SensorData implements SensorData {
  const factory _SensorData({
    required final double x,
    required final double y,
    required final double z,
    required final DateTime timestamp,
  }) = _$SensorDataImpl;

  @override
  double get x;
  @override
  double get y;
  @override
  double get z;
  @override
  DateTime get timestamp;

  /// Create a copy of SensorData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SensorDataImplCopyWith<_$SensorDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
