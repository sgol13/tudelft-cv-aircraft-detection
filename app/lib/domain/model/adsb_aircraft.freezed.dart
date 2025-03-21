// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'adsb_aircraft.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$AdsbAircraft {
  double get latitude => throw _privateConstructorUsedError;
  double get longitude => throw _privateConstructorUsedError;
  String? get flight => throw _privateConstructorUsedError;

  /// Create a copy of AdsbAircraft
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AdsbAircraftCopyWith<AdsbAircraft> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AdsbAircraftCopyWith<$Res> {
  factory $AdsbAircraftCopyWith(
    AdsbAircraft value,
    $Res Function(AdsbAircraft) then,
  ) = _$AdsbAircraftCopyWithImpl<$Res, AdsbAircraft>;
  @useResult
  $Res call({double latitude, double longitude, String? flight});
}

/// @nodoc
class _$AdsbAircraftCopyWithImpl<$Res, $Val extends AdsbAircraft>
    implements $AdsbAircraftCopyWith<$Res> {
  _$AdsbAircraftCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AdsbAircraft
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
abstract class _$$AdsbAircraftImplCopyWith<$Res>
    implements $AdsbAircraftCopyWith<$Res> {
  factory _$$AdsbAircraftImplCopyWith(
    _$AdsbAircraftImpl value,
    $Res Function(_$AdsbAircraftImpl) then,
  ) = __$$AdsbAircraftImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({double latitude, double longitude, String? flight});
}

/// @nodoc
class __$$AdsbAircraftImplCopyWithImpl<$Res>
    extends _$AdsbAircraftCopyWithImpl<$Res, _$AdsbAircraftImpl>
    implements _$$AdsbAircraftImplCopyWith<$Res> {
  __$$AdsbAircraftImplCopyWithImpl(
    _$AdsbAircraftImpl _value,
    $Res Function(_$AdsbAircraftImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AdsbAircraft
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? latitude = null,
    Object? longitude = null,
    Object? flight = freezed,
  }) {
    return _then(
      _$AdsbAircraftImpl(
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

class _$AdsbAircraftImpl implements _AdsbAircraft {
  const _$AdsbAircraftImpl({
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
    return 'AdsbAircraft(latitude: $latitude, longitude: $longitude, flight: $flight)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AdsbAircraftImpl &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            (identical(other.flight, flight) || other.flight == flight));
  }

  @override
  int get hashCode => Object.hash(runtimeType, latitude, longitude, flight);

  /// Create a copy of AdsbAircraft
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AdsbAircraftImplCopyWith<_$AdsbAircraftImpl> get copyWith =>
      __$$AdsbAircraftImplCopyWithImpl<_$AdsbAircraftImpl>(this, _$identity);
}

abstract class _AdsbAircraft implements AdsbAircraft {
  const factory _AdsbAircraft({
    required final double latitude,
    required final double longitude,
    final String? flight,
  }) = _$AdsbAircraftImpl;

  @override
  double get latitude;
  @override
  double get longitude;
  @override
  String? get flight;

  /// Create a copy of AdsbAircraft
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AdsbAircraftImplCopyWith<_$AdsbAircraftImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
