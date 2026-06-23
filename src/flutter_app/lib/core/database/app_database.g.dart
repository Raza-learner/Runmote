// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $PairedDevicesTable extends PairedDevices
    with TableInfo<$PairedDevicesTable, PairedDevice> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PairedDevicesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
    'code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deviceNameMeta = const VerificationMeta(
    'deviceName',
  );
  @override
  late final GeneratedColumn<String> deviceName = GeneratedColumn<String>(
    'device_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pairedAtMeta = const VerificationMeta(
    'pairedAt',
  );
  @override
  late final GeneratedColumn<double> pairedAt = GeneratedColumn<double>(
    'paired_at',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastConnectedAtMeta = const VerificationMeta(
    'lastConnectedAt',
  );
  @override
  late final GeneratedColumn<double> lastConnectedAt = GeneratedColumn<double>(
    'last_connected_at',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    code,
    deviceName,
    pairedAt,
    lastConnectedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'paired_devices';
  @override
  VerificationContext validateIntegrity(
    Insertable<PairedDevice> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('code')) {
      context.handle(
        _codeMeta,
        code.isAcceptableOrUnknown(data['code']!, _codeMeta),
      );
    } else if (isInserting) {
      context.missing(_codeMeta);
    }
    if (data.containsKey('device_name')) {
      context.handle(
        _deviceNameMeta,
        deviceName.isAcceptableOrUnknown(data['device_name']!, _deviceNameMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceNameMeta);
    }
    if (data.containsKey('paired_at')) {
      context.handle(
        _pairedAtMeta,
        pairedAt.isAcceptableOrUnknown(data['paired_at']!, _pairedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_pairedAtMeta);
    }
    if (data.containsKey('last_connected_at')) {
      context.handle(
        _lastConnectedAtMeta,
        lastConnectedAt.isAcceptableOrUnknown(
          data['last_connected_at']!,
          _lastConnectedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastConnectedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {code};
  @override
  PairedDevice map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PairedDevice(
      code: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}code'],
      )!,
      deviceName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_name'],
      )!,
      pairedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}paired_at'],
      )!,
      lastConnectedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}last_connected_at'],
      )!,
    );
  }

  @override
  $PairedDevicesTable createAlias(String alias) {
    return $PairedDevicesTable(attachedDatabase, alias);
  }
}

class PairedDevice extends DataClass implements Insertable<PairedDevice> {
  final String code;
  final String deviceName;
  final double pairedAt;
  final double lastConnectedAt;
  const PairedDevice({
    required this.code,
    required this.deviceName,
    required this.pairedAt,
    required this.lastConnectedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['code'] = Variable<String>(code);
    map['device_name'] = Variable<String>(deviceName);
    map['paired_at'] = Variable<double>(pairedAt);
    map['last_connected_at'] = Variable<double>(lastConnectedAt);
    return map;
  }

  PairedDevicesCompanion toCompanion(bool nullToAbsent) {
    return PairedDevicesCompanion(
      code: Value(code),
      deviceName: Value(deviceName),
      pairedAt: Value(pairedAt),
      lastConnectedAt: Value(lastConnectedAt),
    );
  }

  factory PairedDevice.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PairedDevice(
      code: serializer.fromJson<String>(json['code']),
      deviceName: serializer.fromJson<String>(json['deviceName']),
      pairedAt: serializer.fromJson<double>(json['pairedAt']),
      lastConnectedAt: serializer.fromJson<double>(json['lastConnectedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'code': serializer.toJson<String>(code),
      'deviceName': serializer.toJson<String>(deviceName),
      'pairedAt': serializer.toJson<double>(pairedAt),
      'lastConnectedAt': serializer.toJson<double>(lastConnectedAt),
    };
  }

  PairedDevice copyWith({
    String? code,
    String? deviceName,
    double? pairedAt,
    double? lastConnectedAt,
  }) => PairedDevice(
    code: code ?? this.code,
    deviceName: deviceName ?? this.deviceName,
    pairedAt: pairedAt ?? this.pairedAt,
    lastConnectedAt: lastConnectedAt ?? this.lastConnectedAt,
  );
  PairedDevice copyWithCompanion(PairedDevicesCompanion data) {
    return PairedDevice(
      code: data.code.present ? data.code.value : this.code,
      deviceName: data.deviceName.present
          ? data.deviceName.value
          : this.deviceName,
      pairedAt: data.pairedAt.present ? data.pairedAt.value : this.pairedAt,
      lastConnectedAt: data.lastConnectedAt.present
          ? data.lastConnectedAt.value
          : this.lastConnectedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PairedDevice(')
          ..write('code: $code, ')
          ..write('deviceName: $deviceName, ')
          ..write('pairedAt: $pairedAt, ')
          ..write('lastConnectedAt: $lastConnectedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(code, deviceName, pairedAt, lastConnectedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PairedDevice &&
          other.code == this.code &&
          other.deviceName == this.deviceName &&
          other.pairedAt == this.pairedAt &&
          other.lastConnectedAt == this.lastConnectedAt);
}

class PairedDevicesCompanion extends UpdateCompanion<PairedDevice> {
  final Value<String> code;
  final Value<String> deviceName;
  final Value<double> pairedAt;
  final Value<double> lastConnectedAt;
  final Value<int> rowid;
  const PairedDevicesCompanion({
    this.code = const Value.absent(),
    this.deviceName = const Value.absent(),
    this.pairedAt = const Value.absent(),
    this.lastConnectedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PairedDevicesCompanion.insert({
    required String code,
    required String deviceName,
    required double pairedAt,
    required double lastConnectedAt,
    this.rowid = const Value.absent(),
  }) : code = Value(code),
       deviceName = Value(deviceName),
       pairedAt = Value(pairedAt),
       lastConnectedAt = Value(lastConnectedAt);
  static Insertable<PairedDevice> custom({
    Expression<String>? code,
    Expression<String>? deviceName,
    Expression<double>? pairedAt,
    Expression<double>? lastConnectedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (code != null) 'code': code,
      if (deviceName != null) 'device_name': deviceName,
      if (pairedAt != null) 'paired_at': pairedAt,
      if (lastConnectedAt != null) 'last_connected_at': lastConnectedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PairedDevicesCompanion copyWith({
    Value<String>? code,
    Value<String>? deviceName,
    Value<double>? pairedAt,
    Value<double>? lastConnectedAt,
    Value<int>? rowid,
  }) {
    return PairedDevicesCompanion(
      code: code ?? this.code,
      deviceName: deviceName ?? this.deviceName,
      pairedAt: pairedAt ?? this.pairedAt,
      lastConnectedAt: lastConnectedAt ?? this.lastConnectedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (deviceName.present) {
      map['device_name'] = Variable<String>(deviceName.value);
    }
    if (pairedAt.present) {
      map['paired_at'] = Variable<double>(pairedAt.value);
    }
    if (lastConnectedAt.present) {
      map['last_connected_at'] = Variable<double>(lastConnectedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PairedDevicesCompanion(')
          ..write('code: $code, ')
          ..write('deviceName: $deviceName, ')
          ..write('pairedAt: $pairedAt, ')
          ..write('lastConnectedAt: $lastConnectedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SessionCacheTable extends SessionCache
    with TableInfo<$SessionCacheTable, SessionCacheData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SessionCacheTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deviceCodeMeta = const VerificationMeta(
    'deviceCode',
  );
  @override
  late final GeneratedColumn<String> deviceCode = GeneratedColumn<String>(
    'device_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cwdMeta = const VerificationMeta('cwd');
  @override
  late final GeneratedColumn<String> cwd = GeneratedColumn<String>(
    'cwd',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<double> updatedAt = GeneratedColumn<double>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, deviceCode, title, cwd, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'session_cache';
  @override
  VerificationContext validateIntegrity(
    Insertable<SessionCacheData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('device_code')) {
      context.handle(
        _deviceCodeMeta,
        deviceCode.isAcceptableOrUnknown(data['device_code']!, _deviceCodeMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceCodeMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    }
    if (data.containsKey('cwd')) {
      context.handle(
        _cwdMeta,
        cwd.isAcceptableOrUnknown(data['cwd']!, _cwdMeta),
      );
    } else if (isInserting) {
      context.missing(_cwdMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SessionCacheData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SessionCacheData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      deviceCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_code'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      ),
      cwd: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cwd'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $SessionCacheTable createAlias(String alias) {
    return $SessionCacheTable(attachedDatabase, alias);
  }
}

class SessionCacheData extends DataClass
    implements Insertable<SessionCacheData> {
  final String id;
  final String deviceCode;
  final String? title;
  final String cwd;
  final double updatedAt;
  const SessionCacheData({
    required this.id,
    required this.deviceCode,
    this.title,
    required this.cwd,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['device_code'] = Variable<String>(deviceCode);
    if (!nullToAbsent || title != null) {
      map['title'] = Variable<String>(title);
    }
    map['cwd'] = Variable<String>(cwd);
    map['updated_at'] = Variable<double>(updatedAt);
    return map;
  }

  SessionCacheCompanion toCompanion(bool nullToAbsent) {
    return SessionCacheCompanion(
      id: Value(id),
      deviceCode: Value(deviceCode),
      title: title == null && nullToAbsent
          ? const Value.absent()
          : Value(title),
      cwd: Value(cwd),
      updatedAt: Value(updatedAt),
    );
  }

  factory SessionCacheData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SessionCacheData(
      id: serializer.fromJson<String>(json['id']),
      deviceCode: serializer.fromJson<String>(json['deviceCode']),
      title: serializer.fromJson<String?>(json['title']),
      cwd: serializer.fromJson<String>(json['cwd']),
      updatedAt: serializer.fromJson<double>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'deviceCode': serializer.toJson<String>(deviceCode),
      'title': serializer.toJson<String?>(title),
      'cwd': serializer.toJson<String>(cwd),
      'updatedAt': serializer.toJson<double>(updatedAt),
    };
  }

  SessionCacheData copyWith({
    String? id,
    String? deviceCode,
    Value<String?> title = const Value.absent(),
    String? cwd,
    double? updatedAt,
  }) => SessionCacheData(
    id: id ?? this.id,
    deviceCode: deviceCode ?? this.deviceCode,
    title: title.present ? title.value : this.title,
    cwd: cwd ?? this.cwd,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  SessionCacheData copyWithCompanion(SessionCacheCompanion data) {
    return SessionCacheData(
      id: data.id.present ? data.id.value : this.id,
      deviceCode: data.deviceCode.present
          ? data.deviceCode.value
          : this.deviceCode,
      title: data.title.present ? data.title.value : this.title,
      cwd: data.cwd.present ? data.cwd.value : this.cwd,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SessionCacheData(')
          ..write('id: $id, ')
          ..write('deviceCode: $deviceCode, ')
          ..write('title: $title, ')
          ..write('cwd: $cwd, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, deviceCode, title, cwd, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SessionCacheData &&
          other.id == this.id &&
          other.deviceCode == this.deviceCode &&
          other.title == this.title &&
          other.cwd == this.cwd &&
          other.updatedAt == this.updatedAt);
}

class SessionCacheCompanion extends UpdateCompanion<SessionCacheData> {
  final Value<String> id;
  final Value<String> deviceCode;
  final Value<String?> title;
  final Value<String> cwd;
  final Value<double> updatedAt;
  final Value<int> rowid;
  const SessionCacheCompanion({
    this.id = const Value.absent(),
    this.deviceCode = const Value.absent(),
    this.title = const Value.absent(),
    this.cwd = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SessionCacheCompanion.insert({
    required String id,
    required String deviceCode,
    this.title = const Value.absent(),
    required String cwd,
    required double updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       deviceCode = Value(deviceCode),
       cwd = Value(cwd),
       updatedAt = Value(updatedAt);
  static Insertable<SessionCacheData> custom({
    Expression<String>? id,
    Expression<String>? deviceCode,
    Expression<String>? title,
    Expression<String>? cwd,
    Expression<double>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (deviceCode != null) 'device_code': deviceCode,
      if (title != null) 'title': title,
      if (cwd != null) 'cwd': cwd,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SessionCacheCompanion copyWith({
    Value<String>? id,
    Value<String>? deviceCode,
    Value<String?>? title,
    Value<String>? cwd,
    Value<double>? updatedAt,
    Value<int>? rowid,
  }) {
    return SessionCacheCompanion(
      id: id ?? this.id,
      deviceCode: deviceCode ?? this.deviceCode,
      title: title ?? this.title,
      cwd: cwd ?? this.cwd,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (deviceCode.present) {
      map['device_code'] = Variable<String>(deviceCode.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (cwd.present) {
      map['cwd'] = Variable<String>(cwd.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<double>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SessionCacheCompanion(')
          ..write('id: $id, ')
          ..write('deviceCode: $deviceCode, ')
          ..write('title: $title, ')
          ..write('cwd: $cwd, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ChatMessagesTable extends ChatMessages
    with TableInfo<$ChatMessagesTable, ChatMessage> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChatMessagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _segmentsJsonMeta = const VerificationMeta(
    'segmentsJson',
  );
  @override
  late final GeneratedColumn<String> segmentsJson = GeneratedColumn<String>(
    'segments_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isStreamingMeta = const VerificationMeta(
    'isStreaming',
  );
  @override
  late final GeneratedColumn<int> isStreaming = GeneratedColumn<int>(
    'is_streaming',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<double> createdAt = GeneratedColumn<double>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sessionId,
    role,
    content,
    segmentsJson,
    isStreaming,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'chat_messages';
  @override
  VerificationContext validateIntegrity(
    Insertable<ChatMessage> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    } else if (isInserting) {
      context.missing(_roleMeta);
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('segments_json')) {
      context.handle(
        _segmentsJsonMeta,
        segmentsJson.isAcceptableOrUnknown(
          data['segments_json']!,
          _segmentsJsonMeta,
        ),
      );
    }
    if (data.containsKey('is_streaming')) {
      context.handle(
        _isStreamingMeta,
        isStreaming.isAcceptableOrUnknown(
          data['is_streaming']!,
          _isStreamingMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_isStreamingMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ChatMessage map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChatMessage(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_id'],
      )!,
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role'],
      )!,
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      )!,
      segmentsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}segments_json'],
      ),
      isStreaming: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}is_streaming'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $ChatMessagesTable createAlias(String alias) {
    return $ChatMessagesTable(attachedDatabase, alias);
  }
}

class ChatMessage extends DataClass implements Insertable<ChatMessage> {
  final String id;
  final String sessionId;
  final String role;
  final String content;
  final String? segmentsJson;
  final int isStreaming;
  final double createdAt;
  const ChatMessage({
    required this.id,
    required this.sessionId,
    required this.role,
    required this.content,
    this.segmentsJson,
    required this.isStreaming,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['session_id'] = Variable<String>(sessionId);
    map['role'] = Variable<String>(role);
    map['content'] = Variable<String>(content);
    if (!nullToAbsent || segmentsJson != null) {
      map['segments_json'] = Variable<String>(segmentsJson);
    }
    map['is_streaming'] = Variable<int>(isStreaming);
    map['created_at'] = Variable<double>(createdAt);
    return map;
  }

  ChatMessagesCompanion toCompanion(bool nullToAbsent) {
    return ChatMessagesCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      role: Value(role),
      content: Value(content),
      segmentsJson: segmentsJson == null && nullToAbsent
          ? const Value.absent()
          : Value(segmentsJson),
      isStreaming: Value(isStreaming),
      createdAt: Value(createdAt),
    );
  }

  factory ChatMessage.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChatMessage(
      id: serializer.fromJson<String>(json['id']),
      sessionId: serializer.fromJson<String>(json['sessionId']),
      role: serializer.fromJson<String>(json['role']),
      content: serializer.fromJson<String>(json['content']),
      segmentsJson: serializer.fromJson<String?>(json['segmentsJson']),
      isStreaming: serializer.fromJson<int>(json['isStreaming']),
      createdAt: serializer.fromJson<double>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'sessionId': serializer.toJson<String>(sessionId),
      'role': serializer.toJson<String>(role),
      'content': serializer.toJson<String>(content),
      'segmentsJson': serializer.toJson<String?>(segmentsJson),
      'isStreaming': serializer.toJson<int>(isStreaming),
      'createdAt': serializer.toJson<double>(createdAt),
    };
  }

  ChatMessage copyWith({
    String? id,
    String? sessionId,
    String? role,
    String? content,
    Value<String?> segmentsJson = const Value.absent(),
    int? isStreaming,
    double? createdAt,
  }) => ChatMessage(
    id: id ?? this.id,
    sessionId: sessionId ?? this.sessionId,
    role: role ?? this.role,
    content: content ?? this.content,
    segmentsJson: segmentsJson.present ? segmentsJson.value : this.segmentsJson,
    isStreaming: isStreaming ?? this.isStreaming,
    createdAt: createdAt ?? this.createdAt,
  );
  ChatMessage copyWithCompanion(ChatMessagesCompanion data) {
    return ChatMessage(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      role: data.role.present ? data.role.value : this.role,
      content: data.content.present ? data.content.value : this.content,
      segmentsJson: data.segmentsJson.present
          ? data.segmentsJson.value
          : this.segmentsJson,
      isStreaming: data.isStreaming.present
          ? data.isStreaming.value
          : this.isStreaming,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChatMessage(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('role: $role, ')
          ..write('content: $content, ')
          ..write('segmentsJson: $segmentsJson, ')
          ..write('isStreaming: $isStreaming, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    sessionId,
    role,
    content,
    segmentsJson,
    isStreaming,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChatMessage &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.role == this.role &&
          other.content == this.content &&
          other.segmentsJson == this.segmentsJson &&
          other.isStreaming == this.isStreaming &&
          other.createdAt == this.createdAt);
}

class ChatMessagesCompanion extends UpdateCompanion<ChatMessage> {
  final Value<String> id;
  final Value<String> sessionId;
  final Value<String> role;
  final Value<String> content;
  final Value<String?> segmentsJson;
  final Value<int> isStreaming;
  final Value<double> createdAt;
  final Value<int> rowid;
  const ChatMessagesCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.role = const Value.absent(),
    this.content = const Value.absent(),
    this.segmentsJson = const Value.absent(),
    this.isStreaming = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ChatMessagesCompanion.insert({
    required String id,
    required String sessionId,
    required String role,
    required String content,
    this.segmentsJson = const Value.absent(),
    required int isStreaming,
    required double createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       sessionId = Value(sessionId),
       role = Value(role),
       content = Value(content),
       isStreaming = Value(isStreaming),
       createdAt = Value(createdAt);
  static Insertable<ChatMessage> custom({
    Expression<String>? id,
    Expression<String>? sessionId,
    Expression<String>? role,
    Expression<String>? content,
    Expression<String>? segmentsJson,
    Expression<int>? isStreaming,
    Expression<double>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (role != null) 'role': role,
      if (content != null) 'content': content,
      if (segmentsJson != null) 'segments_json': segmentsJson,
      if (isStreaming != null) 'is_streaming': isStreaming,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ChatMessagesCompanion copyWith({
    Value<String>? id,
    Value<String>? sessionId,
    Value<String>? role,
    Value<String>? content,
    Value<String?>? segmentsJson,
    Value<int>? isStreaming,
    Value<double>? createdAt,
    Value<int>? rowid,
  }) {
    return ChatMessagesCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      role: role ?? this.role,
      content: content ?? this.content,
      segmentsJson: segmentsJson ?? this.segmentsJson,
      isStreaming: isStreaming ?? this.isStreaming,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (segmentsJson.present) {
      map['segments_json'] = Variable<String>(segmentsJson.value);
    }
    if (isStreaming.present) {
      map['is_streaming'] = Variable<int>(isStreaming.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<double>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChatMessagesCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('role: $role, ')
          ..write('content: $content, ')
          ..write('segmentsJson: $segmentsJson, ')
          ..write('isStreaming: $isStreaming, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SessionSettingsTable extends SessionSettings
    with TableInfo<$SessionSettingsTable, SessionSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SessionSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _targetIdMeta = const VerificationMeta(
    'targetId',
  );
  @override
  late final GeneratedColumn<String> targetId = GeneratedColumn<String>(
    'target_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cwdMeta = const VerificationMeta('cwd');
  @override
  late final GeneratedColumn<String> cwd = GeneratedColumn<String>(
    'cwd',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [targetId, cwd];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'session_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<SessionSetting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('target_id')) {
      context.handle(
        _targetIdMeta,
        targetId.isAcceptableOrUnknown(data['target_id']!, _targetIdMeta),
      );
    } else if (isInserting) {
      context.missing(_targetIdMeta);
    }
    if (data.containsKey('cwd')) {
      context.handle(
        _cwdMeta,
        cwd.isAcceptableOrUnknown(data['cwd']!, _cwdMeta),
      );
    } else if (isInserting) {
      context.missing(_cwdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {targetId};
  @override
  SessionSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SessionSetting(
      targetId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}target_id'],
      )!,
      cwd: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cwd'],
      )!,
    );
  }

  @override
  $SessionSettingsTable createAlias(String alias) {
    return $SessionSettingsTable(attachedDatabase, alias);
  }
}

class SessionSetting extends DataClass implements Insertable<SessionSetting> {
  final String targetId;
  final String cwd;
  const SessionSetting({required this.targetId, required this.cwd});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['target_id'] = Variable<String>(targetId);
    map['cwd'] = Variable<String>(cwd);
    return map;
  }

  SessionSettingsCompanion toCompanion(bool nullToAbsent) {
    return SessionSettingsCompanion(targetId: Value(targetId), cwd: Value(cwd));
  }

  factory SessionSetting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SessionSetting(
      targetId: serializer.fromJson<String>(json['targetId']),
      cwd: serializer.fromJson<String>(json['cwd']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'targetId': serializer.toJson<String>(targetId),
      'cwd': serializer.toJson<String>(cwd),
    };
  }

  SessionSetting copyWith({String? targetId, String? cwd}) =>
      SessionSetting(targetId: targetId ?? this.targetId, cwd: cwd ?? this.cwd);
  SessionSetting copyWithCompanion(SessionSettingsCompanion data) {
    return SessionSetting(
      targetId: data.targetId.present ? data.targetId.value : this.targetId,
      cwd: data.cwd.present ? data.cwd.value : this.cwd,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SessionSetting(')
          ..write('targetId: $targetId, ')
          ..write('cwd: $cwd')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(targetId, cwd);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SessionSetting &&
          other.targetId == this.targetId &&
          other.cwd == this.cwd);
}

class SessionSettingsCompanion extends UpdateCompanion<SessionSetting> {
  final Value<String> targetId;
  final Value<String> cwd;
  final Value<int> rowid;
  const SessionSettingsCompanion({
    this.targetId = const Value.absent(),
    this.cwd = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SessionSettingsCompanion.insert({
    required String targetId,
    required String cwd,
    this.rowid = const Value.absent(),
  }) : targetId = Value(targetId),
       cwd = Value(cwd);
  static Insertable<SessionSetting> custom({
    Expression<String>? targetId,
    Expression<String>? cwd,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (targetId != null) 'target_id': targetId,
      if (cwd != null) 'cwd': cwd,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SessionSettingsCompanion copyWith({
    Value<String>? targetId,
    Value<String>? cwd,
    Value<int>? rowid,
  }) {
    return SessionSettingsCompanion(
      targetId: targetId ?? this.targetId,
      cwd: cwd ?? this.cwd,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (targetId.present) {
      map['target_id'] = Variable<String>(targetId.value);
    }
    if (cwd.present) {
      map['cwd'] = Variable<String>(cwd.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SessionSettingsCompanion(')
          ..write('targetId: $targetId, ')
          ..write('cwd: $cwd, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $PairedDevicesTable pairedDevices = $PairedDevicesTable(this);
  late final $SessionCacheTable sessionCache = $SessionCacheTable(this);
  late final $ChatMessagesTable chatMessages = $ChatMessagesTable(this);
  late final $SessionSettingsTable sessionSettings = $SessionSettingsTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    pairedDevices,
    sessionCache,
    chatMessages,
    sessionSettings,
  ];
}

typedef $$PairedDevicesTableCreateCompanionBuilder =
    PairedDevicesCompanion Function({
      required String code,
      required String deviceName,
      required double pairedAt,
      required double lastConnectedAt,
      Value<int> rowid,
    });
typedef $$PairedDevicesTableUpdateCompanionBuilder =
    PairedDevicesCompanion Function({
      Value<String> code,
      Value<String> deviceName,
      Value<double> pairedAt,
      Value<double> lastConnectedAt,
      Value<int> rowid,
    });

class $$PairedDevicesTableFilterComposer
    extends Composer<_$AppDatabase, $PairedDevicesTable> {
  $$PairedDevicesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceName => $composableBuilder(
    column: $table.deviceName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get pairedAt => $composableBuilder(
    column: $table.pairedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get lastConnectedAt => $composableBuilder(
    column: $table.lastConnectedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PairedDevicesTableOrderingComposer
    extends Composer<_$AppDatabase, $PairedDevicesTable> {
  $$PairedDevicesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceName => $composableBuilder(
    column: $table.deviceName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get pairedAt => $composableBuilder(
    column: $table.pairedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get lastConnectedAt => $composableBuilder(
    column: $table.lastConnectedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PairedDevicesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PairedDevicesTable> {
  $$PairedDevicesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<String> get deviceName => $composableBuilder(
    column: $table.deviceName,
    builder: (column) => column,
  );

  GeneratedColumn<double> get pairedAt =>
      $composableBuilder(column: $table.pairedAt, builder: (column) => column);

  GeneratedColumn<double> get lastConnectedAt => $composableBuilder(
    column: $table.lastConnectedAt,
    builder: (column) => column,
  );
}

class $$PairedDevicesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PairedDevicesTable,
          PairedDevice,
          $$PairedDevicesTableFilterComposer,
          $$PairedDevicesTableOrderingComposer,
          $$PairedDevicesTableAnnotationComposer,
          $$PairedDevicesTableCreateCompanionBuilder,
          $$PairedDevicesTableUpdateCompanionBuilder,
          (
            PairedDevice,
            BaseReferences<_$AppDatabase, $PairedDevicesTable, PairedDevice>,
          ),
          PairedDevice,
          PrefetchHooks Function()
        > {
  $$PairedDevicesTableTableManager(_$AppDatabase db, $PairedDevicesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PairedDevicesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PairedDevicesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PairedDevicesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> code = const Value.absent(),
                Value<String> deviceName = const Value.absent(),
                Value<double> pairedAt = const Value.absent(),
                Value<double> lastConnectedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PairedDevicesCompanion(
                code: code,
                deviceName: deviceName,
                pairedAt: pairedAt,
                lastConnectedAt: lastConnectedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String code,
                required String deviceName,
                required double pairedAt,
                required double lastConnectedAt,
                Value<int> rowid = const Value.absent(),
              }) => PairedDevicesCompanion.insert(
                code: code,
                deviceName: deviceName,
                pairedAt: pairedAt,
                lastConnectedAt: lastConnectedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PairedDevicesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PairedDevicesTable,
      PairedDevice,
      $$PairedDevicesTableFilterComposer,
      $$PairedDevicesTableOrderingComposer,
      $$PairedDevicesTableAnnotationComposer,
      $$PairedDevicesTableCreateCompanionBuilder,
      $$PairedDevicesTableUpdateCompanionBuilder,
      (
        PairedDevice,
        BaseReferences<_$AppDatabase, $PairedDevicesTable, PairedDevice>,
      ),
      PairedDevice,
      PrefetchHooks Function()
    >;
typedef $$SessionCacheTableCreateCompanionBuilder =
    SessionCacheCompanion Function({
      required String id,
      required String deviceCode,
      Value<String?> title,
      required String cwd,
      required double updatedAt,
      Value<int> rowid,
    });
typedef $$SessionCacheTableUpdateCompanionBuilder =
    SessionCacheCompanion Function({
      Value<String> id,
      Value<String> deviceCode,
      Value<String?> title,
      Value<String> cwd,
      Value<double> updatedAt,
      Value<int> rowid,
    });

class $$SessionCacheTableFilterComposer
    extends Composer<_$AppDatabase, $SessionCacheTable> {
  $$SessionCacheTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceCode => $composableBuilder(
    column: $table.deviceCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cwd => $composableBuilder(
    column: $table.cwd,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SessionCacheTableOrderingComposer
    extends Composer<_$AppDatabase, $SessionCacheTable> {
  $$SessionCacheTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceCode => $composableBuilder(
    column: $table.deviceCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cwd => $composableBuilder(
    column: $table.cwd,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SessionCacheTableAnnotationComposer
    extends Composer<_$AppDatabase, $SessionCacheTable> {
  $$SessionCacheTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get deviceCode => $composableBuilder(
    column: $table.deviceCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get cwd =>
      $composableBuilder(column: $table.cwd, builder: (column) => column);

  GeneratedColumn<double> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$SessionCacheTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SessionCacheTable,
          SessionCacheData,
          $$SessionCacheTableFilterComposer,
          $$SessionCacheTableOrderingComposer,
          $$SessionCacheTableAnnotationComposer,
          $$SessionCacheTableCreateCompanionBuilder,
          $$SessionCacheTableUpdateCompanionBuilder,
          (
            SessionCacheData,
            BaseReferences<_$AppDatabase, $SessionCacheTable, SessionCacheData>,
          ),
          SessionCacheData,
          PrefetchHooks Function()
        > {
  $$SessionCacheTableTableManager(_$AppDatabase db, $SessionCacheTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SessionCacheTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SessionCacheTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SessionCacheTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> deviceCode = const Value.absent(),
                Value<String?> title = const Value.absent(),
                Value<String> cwd = const Value.absent(),
                Value<double> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SessionCacheCompanion(
                id: id,
                deviceCode: deviceCode,
                title: title,
                cwd: cwd,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String deviceCode,
                Value<String?> title = const Value.absent(),
                required String cwd,
                required double updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => SessionCacheCompanion.insert(
                id: id,
                deviceCode: deviceCode,
                title: title,
                cwd: cwd,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SessionCacheTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SessionCacheTable,
      SessionCacheData,
      $$SessionCacheTableFilterComposer,
      $$SessionCacheTableOrderingComposer,
      $$SessionCacheTableAnnotationComposer,
      $$SessionCacheTableCreateCompanionBuilder,
      $$SessionCacheTableUpdateCompanionBuilder,
      (
        SessionCacheData,
        BaseReferences<_$AppDatabase, $SessionCacheTable, SessionCacheData>,
      ),
      SessionCacheData,
      PrefetchHooks Function()
    >;
typedef $$ChatMessagesTableCreateCompanionBuilder =
    ChatMessagesCompanion Function({
      required String id,
      required String sessionId,
      required String role,
      required String content,
      Value<String?> segmentsJson,
      required int isStreaming,
      required double createdAt,
      Value<int> rowid,
    });
typedef $$ChatMessagesTableUpdateCompanionBuilder =
    ChatMessagesCompanion Function({
      Value<String> id,
      Value<String> sessionId,
      Value<String> role,
      Value<String> content,
      Value<String?> segmentsJson,
      Value<int> isStreaming,
      Value<double> createdAt,
      Value<int> rowid,
    });

class $$ChatMessagesTableFilterComposer
    extends Composer<_$AppDatabase, $ChatMessagesTable> {
  $$ChatMessagesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sessionId => $composableBuilder(
    column: $table.sessionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get segmentsJson => $composableBuilder(
    column: $table.segmentsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get isStreaming => $composableBuilder(
    column: $table.isStreaming,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ChatMessagesTableOrderingComposer
    extends Composer<_$AppDatabase, $ChatMessagesTable> {
  $$ChatMessagesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sessionId => $composableBuilder(
    column: $table.sessionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get segmentsJson => $composableBuilder(
    column: $table.segmentsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get isStreaming => $composableBuilder(
    column: $table.isStreaming,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ChatMessagesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ChatMessagesTable> {
  $$ChatMessagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get sessionId =>
      $composableBuilder(column: $table.sessionId, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<String> get segmentsJson => $composableBuilder(
    column: $table.segmentsJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get isStreaming => $composableBuilder(
    column: $table.isStreaming,
    builder: (column) => column,
  );

  GeneratedColumn<double> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$ChatMessagesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ChatMessagesTable,
          ChatMessage,
          $$ChatMessagesTableFilterComposer,
          $$ChatMessagesTableOrderingComposer,
          $$ChatMessagesTableAnnotationComposer,
          $$ChatMessagesTableCreateCompanionBuilder,
          $$ChatMessagesTableUpdateCompanionBuilder,
          (
            ChatMessage,
            BaseReferences<_$AppDatabase, $ChatMessagesTable, ChatMessage>,
          ),
          ChatMessage,
          PrefetchHooks Function()
        > {
  $$ChatMessagesTableTableManager(_$AppDatabase db, $ChatMessagesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChatMessagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ChatMessagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ChatMessagesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> sessionId = const Value.absent(),
                Value<String> role = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<String?> segmentsJson = const Value.absent(),
                Value<int> isStreaming = const Value.absent(),
                Value<double> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ChatMessagesCompanion(
                id: id,
                sessionId: sessionId,
                role: role,
                content: content,
                segmentsJson: segmentsJson,
                isStreaming: isStreaming,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String sessionId,
                required String role,
                required String content,
                Value<String?> segmentsJson = const Value.absent(),
                required int isStreaming,
                required double createdAt,
                Value<int> rowid = const Value.absent(),
              }) => ChatMessagesCompanion.insert(
                id: id,
                sessionId: sessionId,
                role: role,
                content: content,
                segmentsJson: segmentsJson,
                isStreaming: isStreaming,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ChatMessagesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ChatMessagesTable,
      ChatMessage,
      $$ChatMessagesTableFilterComposer,
      $$ChatMessagesTableOrderingComposer,
      $$ChatMessagesTableAnnotationComposer,
      $$ChatMessagesTableCreateCompanionBuilder,
      $$ChatMessagesTableUpdateCompanionBuilder,
      (
        ChatMessage,
        BaseReferences<_$AppDatabase, $ChatMessagesTable, ChatMessage>,
      ),
      ChatMessage,
      PrefetchHooks Function()
    >;
typedef $$SessionSettingsTableCreateCompanionBuilder =
    SessionSettingsCompanion Function({
      required String targetId,
      required String cwd,
      Value<int> rowid,
    });
typedef $$SessionSettingsTableUpdateCompanionBuilder =
    SessionSettingsCompanion Function({
      Value<String> targetId,
      Value<String> cwd,
      Value<int> rowid,
    });

class $$SessionSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $SessionSettingsTable> {
  $$SessionSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get targetId => $composableBuilder(
    column: $table.targetId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cwd => $composableBuilder(
    column: $table.cwd,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SessionSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $SessionSettingsTable> {
  $$SessionSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get targetId => $composableBuilder(
    column: $table.targetId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cwd => $composableBuilder(
    column: $table.cwd,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SessionSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SessionSettingsTable> {
  $$SessionSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get targetId =>
      $composableBuilder(column: $table.targetId, builder: (column) => column);

  GeneratedColumn<String> get cwd =>
      $composableBuilder(column: $table.cwd, builder: (column) => column);
}

class $$SessionSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SessionSettingsTable,
          SessionSetting,
          $$SessionSettingsTableFilterComposer,
          $$SessionSettingsTableOrderingComposer,
          $$SessionSettingsTableAnnotationComposer,
          $$SessionSettingsTableCreateCompanionBuilder,
          $$SessionSettingsTableUpdateCompanionBuilder,
          (
            SessionSetting,
            BaseReferences<
              _$AppDatabase,
              $SessionSettingsTable,
              SessionSetting
            >,
          ),
          SessionSetting,
          PrefetchHooks Function()
        > {
  $$SessionSettingsTableTableManager(
    _$AppDatabase db,
    $SessionSettingsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SessionSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SessionSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SessionSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> targetId = const Value.absent(),
                Value<String> cwd = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SessionSettingsCompanion(
                targetId: targetId,
                cwd: cwd,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String targetId,
                required String cwd,
                Value<int> rowid = const Value.absent(),
              }) => SessionSettingsCompanion.insert(
                targetId: targetId,
                cwd: cwd,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SessionSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SessionSettingsTable,
      SessionSetting,
      $$SessionSettingsTableFilterComposer,
      $$SessionSettingsTableOrderingComposer,
      $$SessionSettingsTableAnnotationComposer,
      $$SessionSettingsTableCreateCompanionBuilder,
      $$SessionSettingsTableUpdateCompanionBuilder,
      (
        SessionSetting,
        BaseReferences<_$AppDatabase, $SessionSettingsTable, SessionSetting>,
      ),
      SessionSetting,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$PairedDevicesTableTableManager get pairedDevices =>
      $$PairedDevicesTableTableManager(_db, _db.pairedDevices);
  $$SessionCacheTableTableManager get sessionCache =>
      $$SessionCacheTableTableManager(_db, _db.sessionCache);
  $$ChatMessagesTableTableManager get chatMessages =>
      $$ChatMessagesTableTableManager(_db, _db.chatMessages);
  $$SessionSettingsTableTableManager get sessionSettings =>
      $$SessionSettingsTableTableManager(_db, _db.sessionSettings);
}
