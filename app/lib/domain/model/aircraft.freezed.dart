// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'aircraft.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$Aircraft {
  double get latitude => throw _privateConstructorUsedError;
  double get longitude => throw _privateConstructorUsedError;
  String? get flight => throw _privateConstructorUsedError;

  /// Create a copy of Aircraft
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AircraftCopyWith<Aircraft> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AircraftCopyWith<$Res> {
  factory $AircraftCopyWith(Aircraft value, $Res Function(Aircraft) then) =
      _$AircraftCopyWithImpl<$Res, Aircraft>;
  @useResult
  $Res call({double latitude, double longitude, String? flight});
}

/// @nodoc
class _$AircraftCopyWithImpl<$Res, $Val extends Aircraft>
    implements $AircraftCopyWith<$Res> {
  _$AircraftCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Aircraft
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? latitude = null,
    Object? longitude = null,
    Object? flight = freezed,
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
            flight:
                freezed == flight
                    ? _value.flight
                    : flight // ignore: cast_nullable_to_non_nullable
                        as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AircraftImplCopyWith<$Res>
    implements $AircraftCopyWith<$Res> {
  factory _$$AircraftImplCopyWith(
    _$AircraftImpl value,
    $Res Function(_$AircraftImpl) then,
  ) = __$$AircraftImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({double latitude, double longitude, String? flight});
}

/// @nodoc
class __$$AircraftImplCopyWithImpl<$Res>
    extends _$AircraftCopyWithImpl<$Res, _$AircraftImpl>
    implements _$$AircraftImplCopyWith<$Res> {
  __$$AircraftImplCopyWithImpl(
    _$AircraftImpl _value,
    $Res Function(_$AircraftImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Aircraft
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? latitude = null,
    Object? longitude = null,
    Object? flight = freezed,
  }) {
    return _then(
      _$AircraftImpl(
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
        flight:
            freezed == flight
                ? _value.flight
                : flight // ignore: cast_nullable_to_non_nullable
                    as String?,
      ),
    );
  }
}

/// @nodoc

class _$AircraftImpl implements _Aircraft {
  const _$AircraftImpl({
    required this.latitude,
    required this.longitude,
    this.flight,
  });

  @override
  final double latitude;
  @override
  final double longitude;
  @override
  final String? flight;

  @override
  String toString() {
    return 'Aircraft(latitude: $latitude, longitude: $longitude, flight: $flight)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AircraftImpl &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            (identical(other.flight, flight) || other.flight == flight));
  }

  @override
  int get hashCode => Object.hash(runtimeType, latitude, longitude, flight);

  /// Create a copy of Aircraft
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AircraftImplCopyWith<_$AircraftImpl> get copyWith =>
      __$$AircraftImplCopyWithImpl<_$AircraftImpl>(this, _$identity);
}

abstract class _Aircraft implements Aircraft {
  const factory _Aircraft({
    required final double latitude,
    required final double longitude,
    final String? flight,
  }) = _$AircraftImpl;

  @override
  double get latitude;
  @override
  double get longitude;
  @override
  String? get flight;

  /// Create a copy of Aircraft
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AircraftImplCopyWith<_$AircraftImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
