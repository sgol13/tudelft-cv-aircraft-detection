// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'located_aircraft.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$LocatedAircraft {
  AdsbAircraft get aircraft => throw _privateConstructorUsedError;
  double get azimuth => throw _privateConstructorUsedError;
  double get distance => throw _privateConstructorUsedError;

  /// Create a copy of LocatedAircraft
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LocatedAircraftCopyWith<LocatedAircraft> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LocatedAircraftCopyWith<$Res> {
  factory $LocatedAircraftCopyWith(
    LocatedAircraft value,
    $Res Function(LocatedAircraft) then,
  ) = _$LocatedAircraftCopyWithImpl<$Res, LocatedAircraft>;
  @useResult
  $Res call({AdsbAircraft aircraft, double azimuth, double distance});

  $AdsbAircraftCopyWith<$Res> get aircraft;
}

/// @nodoc
class _$LocatedAircraftCopyWithImpl<$Res, $Val extends LocatedAircraft>
    implements $LocatedAircraftCopyWith<$Res> {
  _$LocatedAircraftCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LocatedAircraft
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? aircraft = null,
    Object? azimuth = null,
    Object? distance = null,
  }) {
    return _then(
      _value.copyWith(
            aircraft:
                null == aircraft
                    ? _value.aircraft
                    : aircraft // ignore: cast_nullable_to_non_nullable
                        as AdsbAircraft,
            azimuth:
                null == azimuth
                    ? _value.azimuth
                    : azimuth // ignore: cast_nullable_to_non_nullable
                        as double,
            distance:
                null == distance
                    ? _value.distance
                    : distance // ignore: cast_nullable_to_non_nullable
                        as double,
          )
          as $Val,
    );
  }

  /// Create a copy of LocatedAircraft
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $AdsbAircraftCopyWith<$Res> get aircraft {
    return $AdsbAircraftCopyWith<$Res>(_value.aircraft, (value) {
      return _then(_value.copyWith(aircraft: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$LocatedAircraftImplCopyWith<$Res>
    implements $LocatedAircraftCopyWith<$Res> {
  factory _$$LocatedAircraftImplCopyWith(
    _$LocatedAircraftImpl value,
    $Res Function(_$LocatedAircraftImpl) then,
  ) = __$$LocatedAircraftImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({AdsbAircraft aircraft, double azimuth, double distance});

  @override
  $AdsbAircraftCopyWith<$Res> get aircraft;
}

/// @nodoc
class __$$LocatedAircraftImplCopyWithImpl<$Res>
    extends _$LocatedAircraftCopyWithImpl<$Res, _$LocatedAircraftImpl>
    implements _$$LocatedAircraftImplCopyWith<$Res> {
  __$$LocatedAircraftImplCopyWithImpl(
    _$LocatedAircraftImpl _value,
    $Res Function(_$LocatedAircraftImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of LocatedAircraft
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? aircraft = null,
    Object? azimuth = null,
    Object? distance = null,
  }) {
    return _then(
      _$LocatedAircraftImpl(
        aircraft:
            null == aircraft
                ? _value.aircraft
                : aircraft // ignore: cast_nullable_to_non_nullable
                    as AdsbAircraft,
        azimuth:
            null == azimuth
                ? _value.azimuth
                : azimuth // ignore: cast_nullable_to_non_nullable
                    as double,
        distance:
            null == distance
                ? _value.distance
                : distance // ignore: cast_nullable_to_non_nullable
                    as double,
      ),
    );
  }
}

/// @nodoc

class _$LocatedAircraftImpl implements _LocatedAircraft {
  const _$LocatedAircraftImpl({
    required this.aircraft,
    required this.azimuth,
    required this.distance,
  });

  @override
  final AdsbAircraft aircraft;
  @override
  final double azimuth;
  @override
  final double distance;

  @override
  String toString() {
    return 'LocatedAircraft(aircraft: $aircraft, azimuth: $azimuth, distance: $distance)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LocatedAircraftImpl &&
            (identical(other.aircraft, aircraft) ||
                other.aircraft == aircraft) &&
            (identical(other.azimuth, azimuth) || other.azimuth == azimuth) &&
            (identical(other.distance, distance) ||
                other.distance == distance));
  }

  @override
  int get hashCode => Object.hash(runtimeType, aircraft, azimuth, distance);

  /// Create a copy of LocatedAircraft
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LocatedAircraftImplCopyWith<_$LocatedAircraftImpl> get copyWith =>
      __$$LocatedAircraftImplCopyWithImpl<_$LocatedAircraftImpl>(
        this,
        _$identity,
      );
}

abstract class _LocatedAircraft implements LocatedAircraft {
  const factory _LocatedAircraft({
    required final AdsbAircraft aircraft,
    required final double azimuth,
    required final double distance,
  }) = _$LocatedAircraftImpl;

  @override
  AdsbAircraft get aircraft;
  @override
  double get azimuth;
  @override
  double get distance;

  /// Create a copy of LocatedAircraft
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LocatedAircraftImplCopyWith<_$LocatedAircraftImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
