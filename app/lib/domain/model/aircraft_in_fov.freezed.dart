// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'aircraft_in_fov.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$AircraftInFov {
  AdsbAircraft get aircraft => throw _privateConstructorUsedError;
  double get relativeX => throw _privateConstructorUsedError;

  /// Create a copy of AircraftInFov
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AircraftInFovCopyWith<AircraftInFov> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AircraftInFovCopyWith<$Res> {
  factory $AircraftInFovCopyWith(
    AircraftInFov value,
    $Res Function(AircraftInFov) then,
  ) = _$AircraftInFovCopyWithImpl<$Res, AircraftInFov>;
  @useResult
  $Res call({AdsbAircraft aircraft, double relativeX});

  $AdsbAircraftCopyWith<$Res> get aircraft;
}

/// @nodoc
class _$AircraftInFovCopyWithImpl<$Res, $Val extends AircraftInFov>
    implements $AircraftInFovCopyWith<$Res> {
  _$AircraftInFovCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AircraftInFov
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? aircraft = null, Object? relativeX = null}) {
    return _then(
      _value.copyWith(
            aircraft:
                null == aircraft
                    ? _value.aircraft
                    : aircraft // ignore: cast_nullable_to_non_nullable
                        as AdsbAircraft,
            relativeX:
                null == relativeX
                    ? _value.relativeX
                    : relativeX // ignore: cast_nullable_to_non_nullable
                        as double,
          )
          as $Val,
    );
  }

  /// Create a copy of AircraftInFov
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
abstract class _$$AircraftInFovImplCopyWith<$Res>
    implements $AircraftInFovCopyWith<$Res> {
  factory _$$AircraftInFovImplCopyWith(
    _$AircraftInFovImpl value,
    $Res Function(_$AircraftInFovImpl) then,
  ) = __$$AircraftInFovImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({AdsbAircraft aircraft, double relativeX});

  @override
  $AdsbAircraftCopyWith<$Res> get aircraft;
}

/// @nodoc
class __$$AircraftInFovImplCopyWithImpl<$Res>
    extends _$AircraftInFovCopyWithImpl<$Res, _$AircraftInFovImpl>
    implements _$$AircraftInFovImplCopyWith<$Res> {
  __$$AircraftInFovImplCopyWithImpl(
    _$AircraftInFovImpl _value,
    $Res Function(_$AircraftInFovImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AircraftInFov
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? aircraft = null, Object? relativeX = null}) {
    return _then(
      _$AircraftInFovImpl(
        aircraft:
            null == aircraft
                ? _value.aircraft
                : aircraft // ignore: cast_nullable_to_non_nullable
                    as AdsbAircraft,
        relativeX:
            null == relativeX
                ? _value.relativeX
                : relativeX // ignore: cast_nullable_to_non_nullable
                    as double,
      ),
    );
  }
}

/// @nodoc

class _$AircraftInFovImpl implements _AircraftInFov {
  const _$AircraftInFovImpl({required this.aircraft, required this.relativeX});

  @override
  final AdsbAircraft aircraft;
  @override
  final double relativeX;

  @override
  String toString() {
    return 'AircraftInFov(aircraft: $aircraft, relativeX: $relativeX)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AircraftInFovImpl &&
            (identical(other.aircraft, aircraft) ||
                other.aircraft == aircraft) &&
            (identical(other.relativeX, relativeX) ||
                other.relativeX == relativeX));
  }

  @override
  int get hashCode => Object.hash(runtimeType, aircraft, relativeX);

  /// Create a copy of AircraftInFov
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AircraftInFovImplCopyWith<_$AircraftInFovImpl> get copyWith =>
      __$$AircraftInFovImplCopyWithImpl<_$AircraftInFovImpl>(this, _$identity);
}

abstract class _AircraftInFov implements AircraftInFov {
  const factory _AircraftInFov({
    required final AdsbAircraft aircraft,
    required final double relativeX,
  }) = _$AircraftInFovImpl;

  @override
  AdsbAircraft get aircraft;
  @override
  double get relativeX;

  /// Create a copy of AircraftInFov
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AircraftInFovImplCopyWith<_$AircraftInFovImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
