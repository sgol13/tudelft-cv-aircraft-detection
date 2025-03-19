// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'aircrafts_in_proximity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$AircraftsInProximity {
  List<LocatedAircraft> get aircrafts => throw _privateConstructorUsedError;
  DateTime get timestamp => throw _privateConstructorUsedError;

  /// Create a copy of AircraftsInProximity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AircraftsInProximityCopyWith<AircraftsInProximity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AircraftsInProximityCopyWith<$Res> {
  factory $AircraftsInProximityCopyWith(
    AircraftsInProximity value,
    $Res Function(AircraftsInProximity) then,
  ) = _$AircraftsInProximityCopyWithImpl<$Res, AircraftsInProximity>;
  @useResult
  $Res call({List<LocatedAircraft> aircrafts, DateTime timestamp});
}

/// @nodoc
class _$AircraftsInProximityCopyWithImpl<
  $Res,
  $Val extends AircraftsInProximity
>
    implements $AircraftsInProximityCopyWith<$Res> {
  _$AircraftsInProximityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AircraftsInProximity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? aircrafts = null, Object? timestamp = null}) {
    return _then(
      _value.copyWith(
            aircrafts:
                null == aircrafts
                    ? _value.aircrafts
                    : aircrafts // ignore: cast_nullable_to_non_nullable
                        as List<LocatedAircraft>,
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
abstract class _$$AircraftsInProximityImplCopyWith<$Res>
    implements $AircraftsInProximityCopyWith<$Res> {
  factory _$$AircraftsInProximityImplCopyWith(
    _$AircraftsInProximityImpl value,
    $Res Function(_$AircraftsInProximityImpl) then,
  ) = __$$AircraftsInProximityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<LocatedAircraft> aircrafts, DateTime timestamp});
}

/// @nodoc
class __$$AircraftsInProximityImplCopyWithImpl<$Res>
    extends _$AircraftsInProximityCopyWithImpl<$Res, _$AircraftsInProximityImpl>
    implements _$$AircraftsInProximityImplCopyWith<$Res> {
  __$$AircraftsInProximityImplCopyWithImpl(
    _$AircraftsInProximityImpl _value,
    $Res Function(_$AircraftsInProximityImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AircraftsInProximity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? aircrafts = null, Object? timestamp = null}) {
    return _then(
      _$AircraftsInProximityImpl(
        aircrafts:
            null == aircrafts
                ? _value._aircrafts
                : aircrafts // ignore: cast_nullable_to_non_nullable
                    as List<LocatedAircraft>,
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

class _$AircraftsInProximityImpl implements _AircraftsInProximity {
  const _$AircraftsInProximityImpl({
    required final List<LocatedAircraft> aircrafts,
    required this.timestamp,
  }) : _aircrafts = aircrafts;

  final List<LocatedAircraft> _aircrafts;
  @override
  List<LocatedAircraft> get aircrafts {
    if (_aircrafts is EqualUnmodifiableListView) return _aircrafts;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_aircrafts);
  }

  @override
  final DateTime timestamp;

  @override
  String toString() {
    return 'AircraftsInProximity(aircrafts: $aircrafts, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AircraftsInProximityImpl &&
            const DeepCollectionEquality().equals(
              other._aircrafts,
              _aircrafts,
            ) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_aircrafts),
    timestamp,
  );

  /// Create a copy of AircraftsInProximity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AircraftsInProximityImplCopyWith<_$AircraftsInProximityImpl>
  get copyWith =>
      __$$AircraftsInProximityImplCopyWithImpl<_$AircraftsInProximityImpl>(
        this,
        _$identity,
      );
}

abstract class _AircraftsInProximity implements AircraftsInProximity {
  const factory _AircraftsInProximity({
    required final List<LocatedAircraft> aircrafts,
    required final DateTime timestamp,
  }) = _$AircraftsInProximityImpl;

  @override
  List<LocatedAircraft> get aircrafts;
  @override
  DateTime get timestamp;

  /// Create a copy of AircraftsInProximity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AircraftsInProximityImplCopyWith<_$AircraftsInProximityImpl>
  get copyWith => throw _privateConstructorUsedError;
}
