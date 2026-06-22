// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'config_option.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ConfigOption _$ConfigOptionFromJson(Map<String, dynamic> json) {
  switch (json['runtimeType']) {
    case 'select':
      return SelectOption.fromJson(json);
    case 'boolean':
      return BooleanOption.fromJson(json);
    case 'unknown':
      return UnknownOption.fromJson(json);

    default:
      throw CheckedFromJsonException(
        json,
        'runtimeType',
        'ConfigOption',
        'Invalid union type "${json['runtimeType']}"!',
      );
  }
}

/// @nodoc
mixin _$ConfigOption {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
      String id,
      String name,
      String? description,
      String category,
      String? currentValue,
      List<ConfigChoice> choices,
      List<ConfigChoiceGroup> groups,
    )
    select,
    required TResult Function(
      String id,
      String name,
      String? description,
      String category,
      bool currentValue,
    )
    boolean,
    required TResult Function(
      String id,
      String name,
      String? description,
      String? kind,
    )
    unknown,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
      String id,
      String name,
      String? description,
      String category,
      String? currentValue,
      List<ConfigChoice> choices,
      List<ConfigChoiceGroup> groups,
    )?
    select,
    TResult? Function(
      String id,
      String name,
      String? description,
      String category,
      bool currentValue,
    )?
    boolean,
    TResult? Function(
      String id,
      String name,
      String? description,
      String? kind,
    )?
    unknown,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
      String id,
      String name,
      String? description,
      String category,
      String? currentValue,
      List<ConfigChoice> choices,
      List<ConfigChoiceGroup> groups,
    )?
    select,
    TResult Function(
      String id,
      String name,
      String? description,
      String category,
      bool currentValue,
    )?
    boolean,
    TResult Function(String id, String name, String? description, String? kind)?
    unknown,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(SelectOption value) select,
    required TResult Function(BooleanOption value) boolean,
    required TResult Function(UnknownOption value) unknown,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(SelectOption value)? select,
    TResult? Function(BooleanOption value)? boolean,
    TResult? Function(UnknownOption value)? unknown,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(SelectOption value)? select,
    TResult Function(BooleanOption value)? boolean,
    TResult Function(UnknownOption value)? unknown,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;

  /// Serializes this ConfigOption to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ConfigOption
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ConfigOptionCopyWith<ConfigOption> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ConfigOptionCopyWith<$Res> {
  factory $ConfigOptionCopyWith(
    ConfigOption value,
    $Res Function(ConfigOption) then,
  ) = _$ConfigOptionCopyWithImpl<$Res, ConfigOption>;
  @useResult
  $Res call({String id, String name, String? description});
}

/// @nodoc
class _$ConfigOptionCopyWithImpl<$Res, $Val extends ConfigOption>
    implements $ConfigOptionCopyWith<$Res> {
  _$ConfigOptionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ConfigOption
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SelectOptionImplCopyWith<$Res>
    implements $ConfigOptionCopyWith<$Res> {
  factory _$$SelectOptionImplCopyWith(
    _$SelectOptionImpl value,
    $Res Function(_$SelectOptionImpl) then,
  ) = __$$SelectOptionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    String? description,
    String category,
    String? currentValue,
    List<ConfigChoice> choices,
    List<ConfigChoiceGroup> groups,
  });
}

/// @nodoc
class __$$SelectOptionImplCopyWithImpl<$Res>
    extends _$ConfigOptionCopyWithImpl<$Res, _$SelectOptionImpl>
    implements _$$SelectOptionImplCopyWith<$Res> {
  __$$SelectOptionImplCopyWithImpl(
    _$SelectOptionImpl _value,
    $Res Function(_$SelectOptionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ConfigOption
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = freezed,
    Object? category = null,
    Object? currentValue = freezed,
    Object? choices = null,
    Object? groups = null,
  }) {
    return _then(
      _$SelectOptionImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        category: null == category
            ? _value.category
            : category // ignore: cast_nullable_to_non_nullable
                  as String,
        currentValue: freezed == currentValue
            ? _value.currentValue
            : currentValue // ignore: cast_nullable_to_non_nullable
                  as String?,
        choices: null == choices
            ? _value._choices
            : choices // ignore: cast_nullable_to_non_nullable
                  as List<ConfigChoice>,
        groups: null == groups
            ? _value._groups
            : groups // ignore: cast_nullable_to_non_nullable
                  as List<ConfigChoiceGroup>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SelectOptionImpl implements SelectOption {
  const _$SelectOptionImpl({
    required this.id,
    required this.name,
    this.description,
    this.category = '',
    this.currentValue,
    final List<ConfigChoice> choices = const <ConfigChoice>[],
    final List<ConfigChoiceGroup> groups = const <ConfigChoiceGroup>[],
    final String? $type,
  }) : _choices = choices,
       _groups = groups,
       $type = $type ?? 'select';

  factory _$SelectOptionImpl.fromJson(Map<String, dynamic> json) =>
      _$$SelectOptionImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String? description;
  @override
  @JsonKey()
  final String category;
  @override
  final String? currentValue;
  final List<ConfigChoice> _choices;
  @override
  @JsonKey()
  List<ConfigChoice> get choices {
    if (_choices is EqualUnmodifiableListView) return _choices;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_choices);
  }

  final List<ConfigChoiceGroup> _groups;
  @override
  @JsonKey()
  List<ConfigChoiceGroup> get groups {
    if (_groups is EqualUnmodifiableListView) return _groups;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_groups);
  }

  @JsonKey(name: 'runtimeType')
  final String $type;

  @override
  String toString() {
    return 'ConfigOption.select(id: $id, name: $name, description: $description, category: $category, currentValue: $currentValue, choices: $choices, groups: $groups)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SelectOptionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.currentValue, currentValue) ||
                other.currentValue == currentValue) &&
            const DeepCollectionEquality().equals(other._choices, _choices) &&
            const DeepCollectionEquality().equals(other._groups, _groups));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    description,
    category,
    currentValue,
    const DeepCollectionEquality().hash(_choices),
    const DeepCollectionEquality().hash(_groups),
  );

  /// Create a copy of ConfigOption
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SelectOptionImplCopyWith<_$SelectOptionImpl> get copyWith =>
      __$$SelectOptionImplCopyWithImpl<_$SelectOptionImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
      String id,
      String name,
      String? description,
      String category,
      String? currentValue,
      List<ConfigChoice> choices,
      List<ConfigChoiceGroup> groups,
    )
    select,
    required TResult Function(
      String id,
      String name,
      String? description,
      String category,
      bool currentValue,
    )
    boolean,
    required TResult Function(
      String id,
      String name,
      String? description,
      String? kind,
    )
    unknown,
  }) {
    return select(
      id,
      name,
      description,
      category,
      currentValue,
      choices,
      groups,
    );
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
      String id,
      String name,
      String? description,
      String category,
      String? currentValue,
      List<ConfigChoice> choices,
      List<ConfigChoiceGroup> groups,
    )?
    select,
    TResult? Function(
      String id,
      String name,
      String? description,
      String category,
      bool currentValue,
    )?
    boolean,
    TResult? Function(
      String id,
      String name,
      String? description,
      String? kind,
    )?
    unknown,
  }) {
    return select?.call(
      id,
      name,
      description,
      category,
      currentValue,
      choices,
      groups,
    );
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
      String id,
      String name,
      String? description,
      String category,
      String? currentValue,
      List<ConfigChoice> choices,
      List<ConfigChoiceGroup> groups,
    )?
    select,
    TResult Function(
      String id,
      String name,
      String? description,
      String category,
      bool currentValue,
    )?
    boolean,
    TResult Function(String id, String name, String? description, String? kind)?
    unknown,
    required TResult orElse(),
  }) {
    if (select != null) {
      return select(
        id,
        name,
        description,
        category,
        currentValue,
        choices,
        groups,
      );
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(SelectOption value) select,
    required TResult Function(BooleanOption value) boolean,
    required TResult Function(UnknownOption value) unknown,
  }) {
    return select(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(SelectOption value)? select,
    TResult? Function(BooleanOption value)? boolean,
    TResult? Function(UnknownOption value)? unknown,
  }) {
    return select?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(SelectOption value)? select,
    TResult Function(BooleanOption value)? boolean,
    TResult Function(UnknownOption value)? unknown,
    required TResult orElse(),
  }) {
    if (select != null) {
      return select(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$SelectOptionImplToJson(this);
  }
}

abstract class SelectOption implements ConfigOption {
  const factory SelectOption({
    required final String id,
    required final String name,
    final String? description,
    final String category,
    final String? currentValue,
    final List<ConfigChoice> choices,
    final List<ConfigChoiceGroup> groups,
  }) = _$SelectOptionImpl;

  factory SelectOption.fromJson(Map<String, dynamic> json) =
      _$SelectOptionImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String? get description;
  String get category;
  String? get currentValue;
  List<ConfigChoice> get choices;
  List<ConfigChoiceGroup> get groups;

  /// Create a copy of ConfigOption
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SelectOptionImplCopyWith<_$SelectOptionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$BooleanOptionImplCopyWith<$Res>
    implements $ConfigOptionCopyWith<$Res> {
  factory _$$BooleanOptionImplCopyWith(
    _$BooleanOptionImpl value,
    $Res Function(_$BooleanOptionImpl) then,
  ) = __$$BooleanOptionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    String? description,
    String category,
    bool currentValue,
  });
}

/// @nodoc
class __$$BooleanOptionImplCopyWithImpl<$Res>
    extends _$ConfigOptionCopyWithImpl<$Res, _$BooleanOptionImpl>
    implements _$$BooleanOptionImplCopyWith<$Res> {
  __$$BooleanOptionImplCopyWithImpl(
    _$BooleanOptionImpl _value,
    $Res Function(_$BooleanOptionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ConfigOption
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = freezed,
    Object? category = null,
    Object? currentValue = null,
  }) {
    return _then(
      _$BooleanOptionImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        category: null == category
            ? _value.category
            : category // ignore: cast_nullable_to_non_nullable
                  as String,
        currentValue: null == currentValue
            ? _value.currentValue
            : currentValue // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$BooleanOptionImpl implements BooleanOption {
  const _$BooleanOptionImpl({
    required this.id,
    required this.name,
    this.description,
    this.category = '',
    this.currentValue = false,
    final String? $type,
  }) : $type = $type ?? 'boolean';

  factory _$BooleanOptionImpl.fromJson(Map<String, dynamic> json) =>
      _$$BooleanOptionImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String? description;
  @override
  @JsonKey()
  final String category;
  @override
  @JsonKey()
  final bool currentValue;

  @JsonKey(name: 'runtimeType')
  final String $type;

  @override
  String toString() {
    return 'ConfigOption.boolean(id: $id, name: $name, description: $description, category: $category, currentValue: $currentValue)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BooleanOptionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.currentValue, currentValue) ||
                other.currentValue == currentValue));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, name, description, category, currentValue);

  /// Create a copy of ConfigOption
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BooleanOptionImplCopyWith<_$BooleanOptionImpl> get copyWith =>
      __$$BooleanOptionImplCopyWithImpl<_$BooleanOptionImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
      String id,
      String name,
      String? description,
      String category,
      String? currentValue,
      List<ConfigChoice> choices,
      List<ConfigChoiceGroup> groups,
    )
    select,
    required TResult Function(
      String id,
      String name,
      String? description,
      String category,
      bool currentValue,
    )
    boolean,
    required TResult Function(
      String id,
      String name,
      String? description,
      String? kind,
    )
    unknown,
  }) {
    return boolean(id, name, description, category, currentValue);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
      String id,
      String name,
      String? description,
      String category,
      String? currentValue,
      List<ConfigChoice> choices,
      List<ConfigChoiceGroup> groups,
    )?
    select,
    TResult? Function(
      String id,
      String name,
      String? description,
      String category,
      bool currentValue,
    )?
    boolean,
    TResult? Function(
      String id,
      String name,
      String? description,
      String? kind,
    )?
    unknown,
  }) {
    return boolean?.call(id, name, description, category, currentValue);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
      String id,
      String name,
      String? description,
      String category,
      String? currentValue,
      List<ConfigChoice> choices,
      List<ConfigChoiceGroup> groups,
    )?
    select,
    TResult Function(
      String id,
      String name,
      String? description,
      String category,
      bool currentValue,
    )?
    boolean,
    TResult Function(String id, String name, String? description, String? kind)?
    unknown,
    required TResult orElse(),
  }) {
    if (boolean != null) {
      return boolean(id, name, description, category, currentValue);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(SelectOption value) select,
    required TResult Function(BooleanOption value) boolean,
    required TResult Function(UnknownOption value) unknown,
  }) {
    return boolean(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(SelectOption value)? select,
    TResult? Function(BooleanOption value)? boolean,
    TResult? Function(UnknownOption value)? unknown,
  }) {
    return boolean?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(SelectOption value)? select,
    TResult Function(BooleanOption value)? boolean,
    TResult Function(UnknownOption value)? unknown,
    required TResult orElse(),
  }) {
    if (boolean != null) {
      return boolean(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$BooleanOptionImplToJson(this);
  }
}

abstract class BooleanOption implements ConfigOption {
  const factory BooleanOption({
    required final String id,
    required final String name,
    final String? description,
    final String category,
    final bool currentValue,
  }) = _$BooleanOptionImpl;

  factory BooleanOption.fromJson(Map<String, dynamic> json) =
      _$BooleanOptionImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String? get description;
  String get category;
  bool get currentValue;

  /// Create a copy of ConfigOption
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BooleanOptionImplCopyWith<_$BooleanOptionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$UnknownOptionImplCopyWith<$Res>
    implements $ConfigOptionCopyWith<$Res> {
  factory _$$UnknownOptionImplCopyWith(
    _$UnknownOptionImpl value,
    $Res Function(_$UnknownOptionImpl) then,
  ) = __$$UnknownOptionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String name, String? description, String? kind});
}

/// @nodoc
class __$$UnknownOptionImplCopyWithImpl<$Res>
    extends _$ConfigOptionCopyWithImpl<$Res, _$UnknownOptionImpl>
    implements _$$UnknownOptionImplCopyWith<$Res> {
  __$$UnknownOptionImplCopyWithImpl(
    _$UnknownOptionImpl _value,
    $Res Function(_$UnknownOptionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ConfigOption
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = freezed,
    Object? kind = freezed,
  }) {
    return _then(
      _$UnknownOptionImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        kind: freezed == kind
            ? _value.kind
            : kind // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$UnknownOptionImpl implements UnknownOption {
  const _$UnknownOptionImpl({
    required this.id,
    required this.name,
    this.description,
    this.kind,
    final String? $type,
  }) : $type = $type ?? 'unknown';

  factory _$UnknownOptionImpl.fromJson(Map<String, dynamic> json) =>
      _$$UnknownOptionImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String? description;
  @override
  final String? kind;

  @JsonKey(name: 'runtimeType')
  final String $type;

  @override
  String toString() {
    return 'ConfigOption.unknown(id: $id, name: $name, description: $description, kind: $kind)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UnknownOptionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.kind, kind) || other.kind == kind));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, description, kind);

  /// Create a copy of ConfigOption
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UnknownOptionImplCopyWith<_$UnknownOptionImpl> get copyWith =>
      __$$UnknownOptionImplCopyWithImpl<_$UnknownOptionImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
      String id,
      String name,
      String? description,
      String category,
      String? currentValue,
      List<ConfigChoice> choices,
      List<ConfigChoiceGroup> groups,
    )
    select,
    required TResult Function(
      String id,
      String name,
      String? description,
      String category,
      bool currentValue,
    )
    boolean,
    required TResult Function(
      String id,
      String name,
      String? description,
      String? kind,
    )
    unknown,
  }) {
    return unknown(id, name, description, kind);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
      String id,
      String name,
      String? description,
      String category,
      String? currentValue,
      List<ConfigChoice> choices,
      List<ConfigChoiceGroup> groups,
    )?
    select,
    TResult? Function(
      String id,
      String name,
      String? description,
      String category,
      bool currentValue,
    )?
    boolean,
    TResult? Function(
      String id,
      String name,
      String? description,
      String? kind,
    )?
    unknown,
  }) {
    return unknown?.call(id, name, description, kind);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
      String id,
      String name,
      String? description,
      String category,
      String? currentValue,
      List<ConfigChoice> choices,
      List<ConfigChoiceGroup> groups,
    )?
    select,
    TResult Function(
      String id,
      String name,
      String? description,
      String category,
      bool currentValue,
    )?
    boolean,
    TResult Function(String id, String name, String? description, String? kind)?
    unknown,
    required TResult orElse(),
  }) {
    if (unknown != null) {
      return unknown(id, name, description, kind);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(SelectOption value) select,
    required TResult Function(BooleanOption value) boolean,
    required TResult Function(UnknownOption value) unknown,
  }) {
    return unknown(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(SelectOption value)? select,
    TResult? Function(BooleanOption value)? boolean,
    TResult? Function(UnknownOption value)? unknown,
  }) {
    return unknown?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(SelectOption value)? select,
    TResult Function(BooleanOption value)? boolean,
    TResult Function(UnknownOption value)? unknown,
    required TResult orElse(),
  }) {
    if (unknown != null) {
      return unknown(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$UnknownOptionImplToJson(this);
  }
}

abstract class UnknownOption implements ConfigOption {
  const factory UnknownOption({
    required final String id,
    required final String name,
    final String? description,
    final String? kind,
  }) = _$UnknownOptionImpl;

  factory UnknownOption.fromJson(Map<String, dynamic> json) =
      _$UnknownOptionImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String? get description;
  String? get kind;

  /// Create a copy of ConfigOption
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UnknownOptionImplCopyWith<_$UnknownOptionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ConfigChoice _$ConfigChoiceFromJson(Map<String, dynamic> json) {
  return _ConfigChoice.fromJson(json);
}

/// @nodoc
mixin _$ConfigChoice {
  String get id => throw _privateConstructorUsedError;
  String get label => throw _privateConstructorUsedError;
  String get value => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;

  /// Serializes this ConfigChoice to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ConfigChoice
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ConfigChoiceCopyWith<ConfigChoice> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ConfigChoiceCopyWith<$Res> {
  factory $ConfigChoiceCopyWith(
    ConfigChoice value,
    $Res Function(ConfigChoice) then,
  ) = _$ConfigChoiceCopyWithImpl<$Res, ConfigChoice>;
  @useResult
  $Res call({String id, String label, String value, String? description});
}

/// @nodoc
class _$ConfigChoiceCopyWithImpl<$Res, $Val extends ConfigChoice>
    implements $ConfigChoiceCopyWith<$Res> {
  _$ConfigChoiceCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ConfigChoice
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? label = null,
    Object? value = null,
    Object? description = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            label: null == label
                ? _value.label
                : label // ignore: cast_nullable_to_non_nullable
                      as String,
            value: null == value
                ? _value.value
                : value // ignore: cast_nullable_to_non_nullable
                      as String,
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ConfigChoiceImplCopyWith<$Res>
    implements $ConfigChoiceCopyWith<$Res> {
  factory _$$ConfigChoiceImplCopyWith(
    _$ConfigChoiceImpl value,
    $Res Function(_$ConfigChoiceImpl) then,
  ) = __$$ConfigChoiceImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String label, String value, String? description});
}

/// @nodoc
class __$$ConfigChoiceImplCopyWithImpl<$Res>
    extends _$ConfigChoiceCopyWithImpl<$Res, _$ConfigChoiceImpl>
    implements _$$ConfigChoiceImplCopyWith<$Res> {
  __$$ConfigChoiceImplCopyWithImpl(
    _$ConfigChoiceImpl _value,
    $Res Function(_$ConfigChoiceImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ConfigChoice
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? label = null,
    Object? value = null,
    Object? description = freezed,
  }) {
    return _then(
      _$ConfigChoiceImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        label: null == label
            ? _value.label
            : label // ignore: cast_nullable_to_non_nullable
                  as String,
        value: null == value
            ? _value.value
            : value // ignore: cast_nullable_to_non_nullable
                  as String,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ConfigChoiceImpl implements _ConfigChoice {
  const _$ConfigChoiceImpl({
    required this.id,
    required this.label,
    required this.value,
    this.description,
  });

  factory _$ConfigChoiceImpl.fromJson(Map<String, dynamic> json) =>
      _$$ConfigChoiceImplFromJson(json);

  @override
  final String id;
  @override
  final String label;
  @override
  final String value;
  @override
  final String? description;

  @override
  String toString() {
    return 'ConfigChoice(id: $id, label: $label, value: $value, description: $description)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ConfigChoiceImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.label, label) || other.label == label) &&
            (identical(other.value, value) || other.value == value) &&
            (identical(other.description, description) ||
                other.description == description));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, label, value, description);

  /// Create a copy of ConfigChoice
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ConfigChoiceImplCopyWith<_$ConfigChoiceImpl> get copyWith =>
      __$$ConfigChoiceImplCopyWithImpl<_$ConfigChoiceImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ConfigChoiceImplToJson(this);
  }
}

abstract class _ConfigChoice implements ConfigChoice {
  const factory _ConfigChoice({
    required final String id,
    required final String label,
    required final String value,
    final String? description,
  }) = _$ConfigChoiceImpl;

  factory _ConfigChoice.fromJson(Map<String, dynamic> json) =
      _$ConfigChoiceImpl.fromJson;

  @override
  String get id;
  @override
  String get label;
  @override
  String get value;
  @override
  String? get description;

  /// Create a copy of ConfigChoice
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ConfigChoiceImplCopyWith<_$ConfigChoiceImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ConfigChoiceGroup _$ConfigChoiceGroupFromJson(Map<String, dynamic> json) {
  return _ConfigChoiceGroup.fromJson(json);
}

/// @nodoc
mixin _$ConfigChoiceGroup {
  String get id => throw _privateConstructorUsedError;
  String? get label => throw _privateConstructorUsedError;
  List<ConfigChoice> get choices => throw _privateConstructorUsedError;

  /// Serializes this ConfigChoiceGroup to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ConfigChoiceGroup
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ConfigChoiceGroupCopyWith<ConfigChoiceGroup> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ConfigChoiceGroupCopyWith<$Res> {
  factory $ConfigChoiceGroupCopyWith(
    ConfigChoiceGroup value,
    $Res Function(ConfigChoiceGroup) then,
  ) = _$ConfigChoiceGroupCopyWithImpl<$Res, ConfigChoiceGroup>;
  @useResult
  $Res call({String id, String? label, List<ConfigChoice> choices});
}

/// @nodoc
class _$ConfigChoiceGroupCopyWithImpl<$Res, $Val extends ConfigChoiceGroup>
    implements $ConfigChoiceGroupCopyWith<$Res> {
  _$ConfigChoiceGroupCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ConfigChoiceGroup
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? label = freezed,
    Object? choices = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            label: freezed == label
                ? _value.label
                : label // ignore: cast_nullable_to_non_nullable
                      as String?,
            choices: null == choices
                ? _value.choices
                : choices // ignore: cast_nullable_to_non_nullable
                      as List<ConfigChoice>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ConfigChoiceGroupImplCopyWith<$Res>
    implements $ConfigChoiceGroupCopyWith<$Res> {
  factory _$$ConfigChoiceGroupImplCopyWith(
    _$ConfigChoiceGroupImpl value,
    $Res Function(_$ConfigChoiceGroupImpl) then,
  ) = __$$ConfigChoiceGroupImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String? label, List<ConfigChoice> choices});
}

/// @nodoc
class __$$ConfigChoiceGroupImplCopyWithImpl<$Res>
    extends _$ConfigChoiceGroupCopyWithImpl<$Res, _$ConfigChoiceGroupImpl>
    implements _$$ConfigChoiceGroupImplCopyWith<$Res> {
  __$$ConfigChoiceGroupImplCopyWithImpl(
    _$ConfigChoiceGroupImpl _value,
    $Res Function(_$ConfigChoiceGroupImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ConfigChoiceGroup
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? label = freezed,
    Object? choices = null,
  }) {
    return _then(
      _$ConfigChoiceGroupImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        label: freezed == label
            ? _value.label
            : label // ignore: cast_nullable_to_non_nullable
                  as String?,
        choices: null == choices
            ? _value._choices
            : choices // ignore: cast_nullable_to_non_nullable
                  as List<ConfigChoice>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ConfigChoiceGroupImpl implements _ConfigChoiceGroup {
  const _$ConfigChoiceGroupImpl({
    required this.id,
    this.label,
    final List<ConfigChoice> choices = const <ConfigChoice>[],
  }) : _choices = choices;

  factory _$ConfigChoiceGroupImpl.fromJson(Map<String, dynamic> json) =>
      _$$ConfigChoiceGroupImplFromJson(json);

  @override
  final String id;
  @override
  final String? label;
  final List<ConfigChoice> _choices;
  @override
  @JsonKey()
  List<ConfigChoice> get choices {
    if (_choices is EqualUnmodifiableListView) return _choices;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_choices);
  }

  @override
  String toString() {
    return 'ConfigChoiceGroup(id: $id, label: $label, choices: $choices)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ConfigChoiceGroupImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.label, label) || other.label == label) &&
            const DeepCollectionEquality().equals(other._choices, _choices));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    label,
    const DeepCollectionEquality().hash(_choices),
  );

  /// Create a copy of ConfigChoiceGroup
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ConfigChoiceGroupImplCopyWith<_$ConfigChoiceGroupImpl> get copyWith =>
      __$$ConfigChoiceGroupImplCopyWithImpl<_$ConfigChoiceGroupImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ConfigChoiceGroupImplToJson(this);
  }
}

abstract class _ConfigChoiceGroup implements ConfigChoiceGroup {
  const factory _ConfigChoiceGroup({
    required final String id,
    final String? label,
    final List<ConfigChoice> choices,
  }) = _$ConfigChoiceGroupImpl;

  factory _ConfigChoiceGroup.fromJson(Map<String, dynamic> json) =
      _$ConfigChoiceGroupImpl.fromJson;

  @override
  String get id;
  @override
  String? get label;
  @override
  List<ConfigChoice> get choices;

  /// Create a copy of ConfigChoiceGroup
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ConfigChoiceGroupImplCopyWith<_$ConfigChoiceGroupImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
