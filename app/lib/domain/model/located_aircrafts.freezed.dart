// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'located_aircrafts.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$LocatedAircrafts {
  List<LocatedAircraft> get aircrafts => throw _privateConstructorUsedError;
  DateTime get timestamp => throw _privateConstructorUsedError;

  /// Create a copy of LocatedAircrafts
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LocatedAircraftsCopyWith<LocatedAircrafts> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LocatedAircraftsCopyWith<$Res> {
  factory $LocatedAircraftsCopyWith(
    LocatedAircrafts value,
    $Res Function(LocatedAircrafts) then,
  ) = _$LocatedAircraftsCopyWithImpl<$Res, LocatedAircrafts>;
  @useResult
  $Res call({List<LocatedAircraft> aircrafts, DateTime timestamp});
}

/// @nodoc
class _$LocatedAircraftsCopyWithImpl<$Res, $Val extends LocatedAircrafts>
    implements $LocatedAircraftsCopyWith<$Res> {
  _$LocatedAircraftsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LocatedAircrafts
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
abstract class _$$LocatedAircraftsImplCopyWith<$Res>
    implements $LocatedAircraftsCopyWith<$Res> {
  factory _$$LocatedAircraftsImplCopyWith(
    _$LocatedAircraftsImpl value,
    $Res Function(_$LocatedAircraftsImpl) then,
  ) = __$$LocatedAircraftsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<LocatedAircraft> aircrafts, DateTime timestamp});
}

/// @nodoc
class __$$LocatedAircraftsImplCopyWithImpl<$Res>
    extends _$LocatedAircraftsCopyWithImpl<$Res, _$LocatedAircraftsImpl>
    implements _$$LocatedAircraftsImplCopyWith<$Res> {
  __$$LocatedAircraftsImplCopyWithImpl(
    _$LocatedAircraftsImpl _value,
    $Res Function(_$LocatedAircraftsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of LocatedAircrafts
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? aircrafts = null, Object? timestamp = null}) {
    return _then(
      _$LocatedAircraftsImpl(
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

class _$LocatedAircraftsImpl implements _LocatedAircrafts {
  const _$LocatedAircraftsImpl({
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
    return 'LocatedAircrafts(aircrafts: $aircrafts, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LocatedAircraftsImpl &&
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

  /// Create a copy of LocatedAircrafts
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LocatedAircraftsImplCopyWith<_$LocatedAircraftsImpl> get copyWith =>
      __$$LocatedAircraftsImplCopyWithImpl<_$LocatedAircraftsImpl>(
        this,
        _$identity,
      );
}

abstract class _LocatedAircrafts implements LocatedAircrafts {
  const factory _LocatedAircrafts({
    required final List<LocatedAircraft> aircrafts,
    required final DateTime timestamp,
  }) = _$LocatedAircraftsImpl;

  @override
  List<LocatedAircraft> get aircrafts;
  @override
  DateTime get timestamp;

  /// Create a copy of LocatedAircrafts
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LocatedAircraftsImplCopyWith<_$LocatedAircraftsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
