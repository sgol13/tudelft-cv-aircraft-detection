// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'adsb_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$AdsbData {
  List<AdsbAircraft> get aircrafts => throw _privateConstructorUsedError;
  DateTime get timestamp => throw _privateConstructorUsedError;

  /// Create a copy of AdsbData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AdsbDataCopyWith<AdsbData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AdsbDataCopyWith<$Res> {
  factory $AdsbDataCopyWith(AdsbData value, $Res Function(AdsbData) then) =
      _$AdsbDataCopyWithImpl<$Res, AdsbData>;
  @useResult
  $Res call({List<AdsbAircraft> aircrafts, DateTime timestamp});
}

/// @nodoc
class _$AdsbDataCopyWithImpl<$Res, $Val extends AdsbData>
    implements $AdsbDataCopyWith<$Res> {
  _$AdsbDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AdsbData
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
                        as List<AdsbAircraft>,
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
abstract class _$$AdsbDataImplCopyWith<$Res>
    implements $AdsbDataCopyWith<$Res> {
  factory _$$AdsbDataImplCopyWith(
    _$AdsbDataImpl value,
    $Res Function(_$AdsbDataImpl) then,
  ) = __$$AdsbDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<AdsbAircraft> aircrafts, DateTime timestamp});
}

/// @nodoc
class __$$AdsbDataImplCopyWithImpl<$Res>
    extends _$AdsbDataCopyWithImpl<$Res, _$AdsbDataImpl>
    implements _$$AdsbDataImplCopyWith<$Res> {
  __$$AdsbDataImplCopyWithImpl(
    _$AdsbDataImpl _value,
    $Res Function(_$AdsbDataImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AdsbData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? aircrafts = null, Object? timestamp = null}) {
    return _then(
      _$AdsbDataImpl(
        aircrafts:
            null == aircrafts
                ? _value._aircrafts
                : aircrafts // ignore: cast_nullable_to_non_nullable
                    as List<AdsbAircraft>,
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

class _$AdsbDataImpl implements _AdsbData {
  const _$AdsbDataImpl({
    required final List<AdsbAircraft> aircrafts,
    required this.timestamp,
  }) : _aircrafts = aircrafts;

  final List<AdsbAircraft> _aircrafts;
  @override
  List<AdsbAircraft> get aircrafts {
    if (_aircrafts is EqualUnmodifiableListView) return _aircrafts;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_aircrafts);
  }

  @override
  final DateTime timestamp;

  @override
  String toString() {
    return 'AdsbData(aircrafts: $aircrafts, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AdsbDataImpl &&
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

  /// Create a copy of AdsbData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AdsbDataImplCopyWith<_$AdsbDataImpl> get copyWith =>
      __$$AdsbDataImplCopyWithImpl<_$AdsbDataImpl>(this, _$identity);
}

abstract class _AdsbData implements AdsbData {
  const factory _AdsbData({
    required final List<AdsbAircraft> aircrafts,
    required final DateTime timestamp,
  }) = _$AdsbDataImpl;

  @override
  List<AdsbAircraft> get aircrafts;
  @override
  DateTime get timestamp;

  /// Create a copy of AdsbData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AdsbDataImplCopyWith<_$AdsbDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
