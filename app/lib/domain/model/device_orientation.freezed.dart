// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'device_orientation.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$DeviceOrientation {
  double get heading => throw _privateConstructorUsedError;
  DateTime get timestamp => throw _privateConstructorUsedError;

  /// Create a copy of DeviceOrientation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DeviceOrientationCopyWith<DeviceOrientation> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DeviceOrientationCopyWith<$Res> {
  factory $DeviceOrientationCopyWith(
    DeviceOrientation value,
    $Res Function(DeviceOrientation) then,
  ) = _$DeviceOrientationCopyWithImpl<$Res, DeviceOrientation>;
  @useResult
  $Res call({double heading, DateTime timestamp});
}

/// @nodoc
class _$DeviceOrientationCopyWithImpl<$Res, $Val extends DeviceOrientation>
    implements $DeviceOrientationCopyWith<$Res> {
  _$DeviceOrientationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DeviceOrientation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? heading = null, Object? timestamp = null}) {
    return _then(
      _value.copyWith(
            heading:
                null == heading
                    ? _value.heading
                    : heading // ignore: cast_nullable_to_non_nullable
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
abstract class _$$DeviceOrientationImplCopyWith<$Res>
    implements $DeviceOrientationCopyWith<$Res> {
  factory _$$DeviceOrientationImplCopyWith(
    _$DeviceOrientationImpl value,
    $Res Function(_$DeviceOrientationImpl) then,
  ) = __$$DeviceOrientationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({double heading, DateTime timestamp});
}

/// @nodoc
class __$$DeviceOrientationImplCopyWithImpl<$Res>
    extends _$DeviceOrientationCopyWithImpl<$Res, _$DeviceOrientationImpl>
    implements _$$DeviceOrientationImplCopyWith<$Res> {
  __$$DeviceOrientationImplCopyWithImpl(
    _$DeviceOrientationImpl _value,
    $Res Function(_$DeviceOrientationImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DeviceOrientation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? heading = null, Object? timestamp = null}) {
    return _then(
      _$DeviceOrientationImpl(
        heading:
            null == heading
                ? _value.heading
                : heading // ignore: cast_nullable_to_non_nullable
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

class _$DeviceOrientationImpl extends _DeviceOrientation {
  const _$DeviceOrientationImpl({
    required this.heading,
    required this.timestamp,
  }) : super._();

  @override
  final double heading;
  @override
  final DateTime timestamp;

  @override
  String toString() {
    return 'DeviceOrientation(heading: $heading, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DeviceOrientationImpl &&
            (identical(other.heading, heading) || other.heading == heading) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp));
  }

  @override
  int get hashCode => Object.hash(runtimeType, heading, timestamp);

  /// Create a copy of DeviceOrientation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DeviceOrientationImplCopyWith<_$DeviceOrientationImpl> get copyWith =>
      __$$DeviceOrientationImplCopyWithImpl<_$DeviceOrientationImpl>(
        this,
        _$identity,
      );
}

abstract class _DeviceOrientation extends DeviceOrientation {
  const factory _DeviceOrientation({
    required final double heading,
    required final DateTime timestamp,
  }) = _$DeviceOrientationImpl;
  const _DeviceOrientation._() : super._();

  @override
  double get heading;
  @override
  DateTime get timestamp;

  /// Create a copy of DeviceOrientation
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DeviceOrientationImplCopyWith<_$DeviceOrientationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
