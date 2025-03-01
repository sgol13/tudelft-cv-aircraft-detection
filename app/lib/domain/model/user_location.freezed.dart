// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_location.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$UserLocation {
  double get latitude => throw _privateConstructorUsedError; // [-90, 90]
  double get longitude => throw _privateConstructorUsedError; // (-180, 180]
  double get altitude => throw _privateConstructorUsedError; // metres
  DateTime get timestamp => throw _privateConstructorUsedError;

  /// Create a copy of UserLocation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserLocationCopyWith<UserLocation> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserLocationCopyWith<$Res> {
  factory $UserLocationCopyWith(
    UserLocation value,
    $Res Function(UserLocation) then,
  ) = _$UserLocationCopyWithImpl<$Res, UserLocation>;
  @useResult
  $Res call({
    double latitude,
    double longitude,
    double altitude,
    DateTime timestamp,
  });
}

/// @nodoc
class _$UserLocationCopyWithImpl<$Res, $Val extends UserLocation>
    implements $UserLocationCopyWith<$Res> {
  _$UserLocationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserLocation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? latitude = null,
    Object? longitude = null,
    Object? altitude = null,
    Object? timestamp = null,
  }) {
    return _then(
      _value.copyWith(
            latitude:
                null == latitude
                    ? _value.latitude
                    : latitude // ignore: cast_nullable_to_non_nullable
                        as double,
            longitude:
                null == longitude
                    ? _value.longitude
                    : longitude // ignore: cast_nullable_to_non_nullable
                        as double,
            altitude:
                null == altitude
                    ? _value.altitude
                    : altitude // ignore: cast_nullable_to_non_nullable
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
abstract class _$$UserLocationImplCopyWith<$Res>
    implements $UserLocationCopyWith<$Res> {
  factory _$$UserLocationImplCopyWith(
    _$UserLocationImpl value,
    $Res Function(_$UserLocationImpl) then,
  ) = __$$UserLocationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    double latitude,
    double longitude,
    double altitude,
    DateTime timestamp,
  });
}

/// @nodoc
class __$$UserLocationImplCopyWithImpl<$Res>
    extends _$UserLocationCopyWithImpl<$Res, _$UserLocationImpl>
    implements _$$UserLocationImplCopyWith<$Res> {
  __$$UserLocationImplCopyWithImpl(
    _$UserLocationImpl _value,
    $Res Function(_$UserLocationImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of UserLocation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? latitude = null,
    Object? longitude = null,
    Object? altitude = null,
    Object? timestamp = null,
  }) {
    return _then(
      _$UserLocationImpl(
        latitude:
            null == latitude
                ? _value.latitude
                : latitude // ignore: cast_nullable_to_non_nullable
                    as double,
        longitude:
            null == longitude
                ? _value.longitude
                : longitude // ignore: cast_nullable_to_non_nullable
                    as double,
        altitude:
            null == altitude
                ? _value.altitude
                : altitude // ignore: cast_nullable_to_non_nullable
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

class _$UserLocationImpl extends _UserLocation {
  const _$UserLocationImpl({
    required this.latitude,
    required this.longitude,
    required this.altitude,
    required this.timestamp,
  }) : super._();

  @override
  final double latitude;
  // [-90, 90]
  @override
  final double longitude;
  // (-180, 180]
  @override
  final double altitude;
  // metres
  @override
  final DateTime timestamp;

  @override
  String toString() {
    return 'UserLocation(latitude: $latitude, longitude: $longitude, altitude: $altitude, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserLocationImpl &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            (identical(other.altitude, altitude) ||
                other.altitude == altitude) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, latitude, longitude, altitude, timestamp);

  /// Create a copy of UserLocation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserLocationImplCopyWith<_$UserLocationImpl> get copyWith =>
      __$$UserLocationImplCopyWithImpl<_$UserLocationImpl>(this, _$identity);
}

abstract class _UserLocation extends UserLocation {
  const factory _UserLocation({
    required final double latitude,
    required final double longitude,
    required final double altitude,
    required final DateTime timestamp,
  }) = _$UserLocationImpl;
  const _UserLocation._() : super._();

  @override
  double get latitude; // [-90, 90]
  @override
  double get longitude; // (-180, 180]
  @override
  double get altitude; // metres
  @override
  DateTime get timestamp;

  /// Create a copy of UserLocation
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserLocationImplCopyWith<_$UserLocationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
