// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'aircrafts_in_fov.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$AircraftsInFov {
  List<AircraftInFov> get aircrafts => throw _privateConstructorUsedError;
  DateTime get timestamp => throw _privateConstructorUsedError;

  /// Create a copy of AircraftsInFov
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AircraftsInFovCopyWith<AircraftsInFov> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AircraftsInFovCopyWith<$Res> {
  factory $AircraftsInFovCopyWith(
    AircraftsInFov value,
    $Res Function(AircraftsInFov) then,
  ) = _$AircraftsInFovCopyWithImpl<$Res, AircraftsInFov>;
  @useResult
  $Res call({List<AircraftInFov> aircrafts, DateTime timestamp});
}

/// @nodoc
class _$AircraftsInFovCopyWithImpl<$Res, $Val extends AircraftsInFov>
    implements $AircraftsInFovCopyWith<$Res> {
  _$AircraftsInFovCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AircraftsInFov
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
                        as List<AircraftInFov>,
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
abstract class _$$AircraftsInFovImplCopyWith<$Res>
    implements $AircraftsInFovCopyWith<$Res> {
  factory _$$AircraftsInFovImplCopyWith(
    _$AircraftsInFovImpl value,
    $Res Function(_$AircraftsInFovImpl) then,
  ) = __$$AircraftsInFovImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<AircraftInFov> aircrafts, DateTime timestamp});
}

/// @nodoc
class __$$AircraftsInFovImplCopyWithImpl<$Res>
    extends _$AircraftsInFovCopyWithImpl<$Res, _$AircraftsInFovImpl>
    implements _$$AircraftsInFovImplCopyWith<$Res> {
  __$$AircraftsInFovImplCopyWithImpl(
    _$AircraftsInFovImpl _value,
    $Res Function(_$AircraftsInFovImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AircraftsInFov
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? aircrafts = null, Object? timestamp = null}) {
    return _then(
      _$AircraftsInFovImpl(
        aircrafts:
            null == aircrafts
                ? _value._aircrafts
                : aircrafts // ignore: cast_nullable_to_non_nullable
                    as List<AircraftInFov>,
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

class _$AircraftsInFovImpl implements _AircraftsInFov {
  const _$AircraftsInFovImpl({
    required final List<AircraftInFov> aircrafts,
    required this.timestamp,
  }) : _aircrafts = aircrafts;

  final List<AircraftInFov> _aircrafts;
  @override
  List<AircraftInFov> get aircrafts {
    if (_aircrafts is EqualUnmodifiableListView) return _aircrafts;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_aircrafts);
  }

  @override
  final DateTime timestamp;

  @override
  String toString() {
    return 'AircraftsInFov(aircrafts: $aircrafts, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AircraftsInFovImpl &&
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

  /// Create a copy of AircraftsInFov
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AircraftsInFovImplCopyWith<_$AircraftsInFovImpl> get copyWith =>
      __$$AircraftsInFovImplCopyWithImpl<_$AircraftsInFovImpl>(
        this,
        _$identity,
      );
}

abstract class _AircraftsInFov implements AircraftsInFov {
  const factory _AircraftsInFov({
    required final List<AircraftInFov> aircrafts,
    required final DateTime timestamp,
  }) = _$AircraftsInFovImpl;

  @override
  List<AircraftInFov> get aircrafts;
  @override
  DateTime get timestamp;

  /// Create a copy of AircraftsInFov
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AircraftsInFovImplCopyWith<_$AircraftsInFovImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
