// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $ServerConfigsTable extends ServerConfigs
    with TableInfo<$ServerConfigsTable, ServerConfig> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ServerConfigsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _schemeMeta = const VerificationMeta('scheme');
  @override
  late final GeneratedColumn<String> scheme = GeneratedColumn<String>(
    'scheme',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hostMeta = const VerificationMeta('host');
  @override
  late final GeneratedColumn<String> host = GeneratedColumn<String>(
    'host',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tokenMeta = const VerificationMeta('token');
  @override
  late final GeneratedColumn<String> token = GeneratedColumn<String>(
    'token',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _preferredAuthMethodIdMeta =
      const VerificationMeta('preferredAuthMethodId');
  @override
  late final GeneratedColumn<String> preferredAuthMethodId =
      GeneratedColumn<String>(
        'preferred_auth_method_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    scheme,
    host,
    token,
    preferredAuthMethodId,
    type,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'server_configs';
  @override
  VerificationContext validateIntegrity(
    Insertable<ServerConfig> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('scheme')) {
      context.handle(
        _schemeMeta,
        scheme.isAcceptableOrUnknown(data['scheme']!, _schemeMeta),
      );
    } else if (isInserting) {
      context.missing(_schemeMeta);
    }
    if (data.containsKey('host')) {
      context.handle(
        _hostMeta,
        host.isAcceptableOrUnknown(data['host']!, _hostMeta),
      );
    } else if (isInserting) {
      context.missing(_hostMeta);
    }
    if (data.containsKey('token')) {
      context.handle(
        _tokenMeta,
        token.isAcceptableOrUnknown(data['token']!, _tokenMeta),
      );
    } else if (isInserting) {
      context.missing(_tokenMeta);
    }
    if (data.containsKey('preferred_auth_method_id')) {
      context.handle(
        _preferredAuthMethodIdMeta,
        preferredAuthMethodId.isAcceptableOrUnknown(
          data['preferred_auth_method_id']!,
          _preferredAuthMethodIdMeta,
        ),
      );
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ServerConfig map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ServerConfig(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      scheme: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}scheme'],
      )!,
      host: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}host'],
      )!,
      token: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}token'],
      )!,
      preferredAuthMethodId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}preferred_auth_method_id'],
      ),
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
    );
  }

  @override
  $ServerConfigsTable createAlias(String alias) {
    return $ServerConfigsTable(attachedDatabase, alias);
  }
}

class ServerConfig extends DataClass implements Insertable<ServerConfig> {
  final String id;
  final String name;
  final String scheme;
  final String host;
  final String token;
  final String? preferredAuthMethodId;
  final String type;
  const ServerConfig({
    required this.id,
    required this.name,
    required this.scheme,
    required this.host,
    required this.token,
    this.preferredAuthMethodId,
    required this.type,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['scheme'] = Variable<String>(scheme);
    map['host'] = Variable<String>(host);
    map['token'] = Variable<String>(token);
    if (!nullToAbsent || preferredAuthMethodId != null) {
      map['preferred_auth_method_id'] = Variable<String>(preferredAuthMethodId);
    }
    map['type'] = Variable<String>(type);
    return map;
  }

  ServerConfigsCompanion toCompanion(bool nullToAbsent) {
    return ServerConfigsCompanion(
      id: Value(id),
      name: Value(name),
      scheme: Value(scheme),
      host: Value(host),
      token: Value(token),
      preferredAuthMethodId: preferredAuthMethodId == null && nullToAbsent
          ? const Value.absent()
          : Value(preferredAuthMethodId),
      type: Value(type),
    );
  }

  factory ServerConfig.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ServerConfig(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      scheme: serializer.fromJson<String>(json['scheme']),
      host: serializer.fromJson<String>(json['host']),
      token: serializer.fromJson<String>(json['token']),
      preferredAuthMethodId: serializer.fromJson<String?>(
        json['preferredAuthMethodId'],
      ),
      type: serializer.fromJson<String>(json['type']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'scheme': serializer.toJson<String>(scheme),
      'host': serializer.toJson<String>(host),
      'token': serializer.toJson<String>(token),
      'preferredAuthMethodId': serializer.toJson<String?>(
        preferredAuthMethodId,
      ),
      'type': serializer.toJson<String>(type),
    };
  }

  ServerConfig copyWith({
    String? id,
    String? name,
    String? scheme,
    String? host,
    String? token,
    Value<String?> preferredAuthMethodId = const Value.absent(),
    String? type,
  }) => ServerConfig(
    id: id ?? this.id,
    name: name ?? this.name,
    scheme: scheme ?? this.scheme,
    host: host ?? this.host,
    token: token ?? this.token,
    preferredAuthMethodId: preferredAuthMethodId.present
        ? preferredAuthMethodId.value
        : this.preferredAuthMethodId,
    type: type ?? this.type,
  );
  ServerConfig copyWithCompanion(ServerConfigsCompanion data) {
    return ServerConfig(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      scheme: data.scheme.present ? data.scheme.value : this.scheme,
      host: data.host.present ? data.host.value : this.host,
      token: data.token.present ? data.token.value : this.token,
      preferredAuthMethodId: data.preferredAuthMethodId.present
          ? data.preferredAuthMethodId.value
          : this.preferredAuthMethodId,
      type: data.type.present ? data.type.value : this.type,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ServerConfig(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('scheme: $scheme, ')
          ..write('host: $host, ')
          ..write('token: $token, ')
          ..write('preferredAuthMethodId: $preferredAuthMethodId, ')
          ..write('type: $type')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, scheme, host, token, preferredAuthMethodId, type);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ServerConfig &&
          other.id == this.id &&
          other.name == this.name &&
          other.scheme == this.scheme &&
          other.host == this.host &&
          other.token == this.token &&
          other.preferredAuthMethodId == this.preferredAuthMethodId &&
          other.type == this.type);
}

class ServerConfigsCompanion extends UpdateCompanion<ServerConfig> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> scheme;
  final Value<String> host;
  final Value<String> token;
  final Value<String?> preferredAuthMethodId;
  final Value<String> type;
  final Value<int> rowid;
  const ServerConfigsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.scheme = const Value.absent(),
    this.host = const Value.absent(),
    this.token = const Value.absent(),
    this.preferredAuthMethodId = const Value.absent(),
    this.type = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ServerConfigsCompanion.insert({
    required String id,
    required String name,
    required String scheme,
    required String host,
    required String token,
    this.preferredAuthMethodId = const Value.absent(),
    required String type,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       scheme = Value(scheme),
       host = Value(host),
       token = Value(token),
       type = Value(type);
  static Insertable<ServerConfig> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? scheme,
    Expression<String>? host,
    Expression<String>? token,
    Expression<String>? preferredAuthMethodId,
    Expression<String>? type,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (scheme != null) 'scheme': scheme,
      if (host != null) 'host': host,
      if (token != null) 'token': token,
      if (preferredAuthMethodId != null)
        'preferred_auth_method_id': preferredAuthMethodId,
      if (type != null) 'type': type,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ServerConfigsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? scheme,
    Value<String>? host,
    Value<String>? token,
    Value<String?>? preferredAuthMethodId,
    Value<String>? type,
    Value<int>? rowid,
  }) {
    return ServerConfigsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      scheme: scheme ?? this.scheme,
      host: host ?? this.host,
      token: token ?? this.token,
      preferredAuthMethodId:
          preferredAuthMethodId ?? this.preferredAuthMethodId,
      type: type ?? this.type,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (scheme.present) {
      map['scheme'] = Variable<String>(scheme.value);
    }
    if (host.present) {
      map['host'] = Variable<String>(host.value);
    }
    if (token.present) {
      map['token'] = Variable<String>(token.value);
    }
    if (preferredAuthMethodId.present) {
      map['preferred_auth_method_id'] = Variable<String>(
        preferredAuthMethodId.value,
      );
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ServerConfigsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('scheme: $scheme, ')
          ..write('host: $host, ')
          ..write('token: $token, ')
          ..write('preferredAuthMethodId: $preferredAuthMethodId, ')
          ..write('type: $type, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $GatewaySourcesTable extends GatewaySources
    with TableInfo<$GatewaySourcesTable, GatewaySource> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GatewaySourcesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _schemeMeta = const VerificationMeta('scheme');
  @override
  late final GeneratedColumn<String> scheme = GeneratedColumn<String>(
    'scheme',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hostMeta = const VerificationMeta('host');
  @override
  late final GeneratedColumn<String> host = GeneratedColumn<String>(
    'host',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _gatewayCredentialMeta = const VerificationMeta(
    'gatewayCredential',
  );
  @override
  late final GeneratedColumn<String> gatewayCredential =
      GeneratedColumn<String>(
        'gateway_credential',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _gatewayCredentialExpiresAtMeta =
      const VerificationMeta('gatewayCredentialExpiresAt');
  @override
  late final GeneratedColumn<DateTime> gatewayCredentialExpiresAt =
      GeneratedColumn<DateTime>(
        'gateway_credential_expires_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _gatewayRemoteModeMeta = const VerificationMeta(
    'gatewayRemoteMode',
  );
  @override
  late final GeneratedColumn<String> gatewayRemoteMode =
      GeneratedColumn<String>(
        'gateway_remote_mode',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    scheme,
    host,
    gatewayCredential,
    gatewayCredentialExpiresAt,
    gatewayRemoteMode,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'gateway_sources';
  @override
  VerificationContext validateIntegrity(
    Insertable<GatewaySource> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('scheme')) {
      context.handle(
        _schemeMeta,
        scheme.isAcceptableOrUnknown(data['scheme']!, _schemeMeta),
      );
    } else if (isInserting) {
      context.missing(_schemeMeta);
    }
    if (data.containsKey('host')) {
      context.handle(
        _hostMeta,
        host.isAcceptableOrUnknown(data['host']!, _hostMeta),
      );
    } else if (isInserting) {
      context.missing(_hostMeta);
    }
    if (data.containsKey('gateway_credential')) {
      context.handle(
        _gatewayCredentialMeta,
        gatewayCredential.isAcceptableOrUnknown(
          data['gateway_credential']!,
          _gatewayCredentialMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_gatewayCredentialMeta);
    }
    if (data.containsKey('gateway_credential_expires_at')) {
      context.handle(
        _gatewayCredentialExpiresAtMeta,
        gatewayCredentialExpiresAt.isAcceptableOrUnknown(
          data['gateway_credential_expires_at']!,
          _gatewayCredentialExpiresAtMeta,
        ),
      );
    }
    if (data.containsKey('gateway_remote_mode')) {
      context.handle(
        _gatewayRemoteModeMeta,
        gatewayRemoteMode.isAcceptableOrUnknown(
          data['gateway_remote_mode']!,
          _gatewayRemoteModeMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GatewaySource map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GatewaySource(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      scheme: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}scheme'],
      )!,
      host: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}host'],
      )!,
      gatewayCredential: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}gateway_credential'],
      )!,
      gatewayCredentialExpiresAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}gateway_credential_expires_at'],
      ),
      gatewayRemoteMode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}gateway_remote_mode'],
      ),
    );
  }

  @override
  $GatewaySourcesTable createAlias(String alias) {
    return $GatewaySourcesTable(attachedDatabase, alias);
  }
}

class GatewaySource extends DataClass implements Insertable<GatewaySource> {
  final String id;
  final String name;
  final String scheme;
  final String host;
  final String gatewayCredential;
  final DateTime? gatewayCredentialExpiresAt;
  final String? gatewayRemoteMode;
  const GatewaySource({
    required this.id,
    required this.name,
    required this.scheme,
    required this.host,
    required this.gatewayCredential,
    this.gatewayCredentialExpiresAt,
    this.gatewayRemoteMode,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['scheme'] = Variable<String>(scheme);
    map['host'] = Variable<String>(host);
    map['gateway_credential'] = Variable<String>(gatewayCredential);
    if (!nullToAbsent || gatewayCredentialExpiresAt != null) {
      map['gateway_credential_expires_at'] = Variable<DateTime>(
        gatewayCredentialExpiresAt,
      );
    }
    if (!nullToAbsent || gatewayRemoteMode != null) {
      map['gateway_remote_mode'] = Variable<String>(gatewayRemoteMode);
    }
    return map;
  }

  GatewaySourcesCompanion toCompanion(bool nullToAbsent) {
    return GatewaySourcesCompanion(
      id: Value(id),
      name: Value(name),
      scheme: Value(scheme),
      host: Value(host),
      gatewayCredential: Value(gatewayCredential),
      gatewayCredentialExpiresAt:
          gatewayCredentialExpiresAt == null && nullToAbsent
          ? const Value.absent()
          : Value(gatewayCredentialExpiresAt),
      gatewayRemoteMode: gatewayRemoteMode == null && nullToAbsent
          ? const Value.absent()
          : Value(gatewayRemoteMode),
    );
  }

  factory GatewaySource.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GatewaySource(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      scheme: serializer.fromJson<String>(json['scheme']),
      host: serializer.fromJson<String>(json['host']),
      gatewayCredential: serializer.fromJson<String>(json['gatewayCredential']),
      gatewayCredentialExpiresAt: serializer.fromJson<DateTime?>(
        json['gatewayCredentialExpiresAt'],
      ),
      gatewayRemoteMode: serializer.fromJson<String?>(
        json['gatewayRemoteMode'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'scheme': serializer.toJson<String>(scheme),
      'host': serializer.toJson<String>(host),
      'gatewayCredential': serializer.toJson<String>(gatewayCredential),
      'gatewayCredentialExpiresAt': serializer.toJson<DateTime?>(
        gatewayCredentialExpiresAt,
      ),
      'gatewayRemoteMode': serializer.toJson<String?>(gatewayRemoteMode),
    };
  }

  GatewaySource copyWith({
    String? id,
    String? name,
    String? scheme,
    String? host,
    String? gatewayCredential,
    Value<DateTime?> gatewayCredentialExpiresAt = const Value.absent(),
    Value<String?> gatewayRemoteMode = const Value.absent(),
  }) => GatewaySource(
    id: id ?? this.id,
    name: name ?? this.name,
    scheme: scheme ?? this.scheme,
    host: host ?? this.host,
    gatewayCredential: gatewayCredential ?? this.gatewayCredential,
    gatewayCredentialExpiresAt: gatewayCredentialExpiresAt.present
        ? gatewayCredentialExpiresAt.value
        : this.gatewayCredentialExpiresAt,
    gatewayRemoteMode: gatewayRemoteMode.present
        ? gatewayRemoteMode.value
        : this.gatewayRemoteMode,
  );
  GatewaySource copyWithCompanion(GatewaySourcesCompanion data) {
    return GatewaySource(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      scheme: data.scheme.present ? data.scheme.value : this.scheme,
      host: data.host.present ? data.host.value : this.host,
      gatewayCredential: data.gatewayCredential.present
          ? data.gatewayCredential.value
          : this.gatewayCredential,
      gatewayCredentialExpiresAt: data.gatewayCredentialExpiresAt.present
          ? data.gatewayCredentialExpiresAt.value
          : this.gatewayCredentialExpiresAt,
      gatewayRemoteMode: data.gatewayRemoteMode.present
          ? data.gatewayRemoteMode.value
          : this.gatewayRemoteMode,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GatewaySource(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('scheme: $scheme, ')
          ..write('host: $host, ')
          ..write('gatewayCredential: $gatewayCredential, ')
          ..write('gatewayCredentialExpiresAt: $gatewayCredentialExpiresAt, ')
          ..write('gatewayRemoteMode: $gatewayRemoteMode')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    scheme,
    host,
    gatewayCredential,
    gatewayCredentialExpiresAt,
    gatewayRemoteMode,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GatewaySource &&
          other.id == this.id &&
          other.name == this.name &&
          other.scheme == this.scheme &&
          other.host == this.host &&
          other.gatewayCredential == this.gatewayCredential &&
          other.gatewayCredentialExpiresAt == this.gatewayCredentialExpiresAt &&
          other.gatewayRemoteMode == this.gatewayRemoteMode);
}

class GatewaySourcesCompanion extends UpdateCompanion<GatewaySource> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> scheme;
  final Value<String> host;
  final Value<String> gatewayCredential;
  final Value<DateTime?> gatewayCredentialExpiresAt;
  final Value<String?> gatewayRemoteMode;
  final Value<int> rowid;
  const GatewaySourcesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.scheme = const Value.absent(),
    this.host = const Value.absent(),
    this.gatewayCredential = const Value.absent(),
    this.gatewayCredentialExpiresAt = const Value.absent(),
    this.gatewayRemoteMode = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GatewaySourcesCompanion.insert({
    required String id,
    required String name,
    required String scheme,
    required String host,
    required String gatewayCredential,
    this.gatewayCredentialExpiresAt = const Value.absent(),
    this.gatewayRemoteMode = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       scheme = Value(scheme),
       host = Value(host),
       gatewayCredential = Value(gatewayCredential);
  static Insertable<GatewaySource> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? scheme,
    Expression<String>? host,
    Expression<String>? gatewayCredential,
    Expression<DateTime>? gatewayCredentialExpiresAt,
    Expression<String>? gatewayRemoteMode,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (scheme != null) 'scheme': scheme,
      if (host != null) 'host': host,
      if (gatewayCredential != null) 'gateway_credential': gatewayCredential,
      if (gatewayCredentialExpiresAt != null)
        'gateway_credential_expires_at': gatewayCredentialExpiresAt,
      if (gatewayRemoteMode != null) 'gateway_remote_mode': gatewayRemoteMode,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GatewaySourcesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? scheme,
    Value<String>? host,
    Value<String>? gatewayCredential,
    Value<DateTime?>? gatewayCredentialExpiresAt,
    Value<String?>? gatewayRemoteMode,
    Value<int>? rowid,
  }) {
    return GatewaySourcesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      scheme: scheme ?? this.scheme,
      host: host ?? this.host,
      gatewayCredential: gatewayCredential ?? this.gatewayCredential,
      gatewayCredentialExpiresAt:
          gatewayCredentialExpiresAt ?? this.gatewayCredentialExpiresAt,
      gatewayRemoteMode: gatewayRemoteMode ?? this.gatewayRemoteMode,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (scheme.present) {
      map['scheme'] = Variable<String>(scheme.value);
    }
    if (host.present) {
      map['host'] = Variable<String>(host.value);
    }
    if (gatewayCredential.present) {
      map['gateway_credential'] = Variable<String>(gatewayCredential.value);
    }
    if (gatewayCredentialExpiresAt.present) {
      map['gateway_credential_expires_at'] = Variable<DateTime>(
        gatewayCredentialExpiresAt.value,
      );
    }
    if (gatewayRemoteMode.present) {
      map['gateway_remote_mode'] = Variable<String>(gatewayRemoteMode.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GatewaySourcesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('scheme: $scheme, ')
          ..write('host: $host, ')
          ..write('gatewayCredential: $gatewayCredential, ')
          ..write('gatewayCredentialExpiresAt: $gatewayCredentialExpiresAt, ')
          ..write('gatewayRemoteMode: $gatewayRemoteMode, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $GatewayAgentBindingsTable extends GatewayAgentBindings
    with TableInfo<$GatewayAgentBindingsTable, GatewayAgentBinding> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GatewayAgentBindingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _gatewaySourceIdMeta = const VerificationMeta(
    'gatewaySourceId',
  );
  @override
  late final GeneratedColumn<String> gatewaySourceId = GeneratedColumn<String>(
    'gateway_source_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _agentIdMeta = const VerificationMeta(
    'agentId',
  );
  @override
  late final GeneratedColumn<String> agentId = GeneratedColumn<String>(
    'agent_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _preferredAuthMethodIdMeta =
      const VerificationMeta('preferredAuthMethodId');
  @override
  late final GeneratedColumn<String> preferredAuthMethodId =
      GeneratedColumn<String>(
        'preferred_auth_method_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    gatewaySourceId,
    agentId,
    preferredAuthMethodId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'gateway_agent_bindings';
  @override
  VerificationContext validateIntegrity(
    Insertable<GatewayAgentBinding> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('gateway_source_id')) {
      context.handle(
        _gatewaySourceIdMeta,
        gatewaySourceId.isAcceptableOrUnknown(
          data['gateway_source_id']!,
          _gatewaySourceIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_gatewaySourceIdMeta);
    }
    if (data.containsKey('agent_id')) {
      context.handle(
        _agentIdMeta,
        agentId.isAcceptableOrUnknown(data['agent_id']!, _agentIdMeta),
      );
    } else if (isInserting) {
      context.missing(_agentIdMeta);
    }
    if (data.containsKey('preferred_auth_method_id')) {
      context.handle(
        _preferredAuthMethodIdMeta,
        preferredAuthMethodId.isAcceptableOrUnknown(
          data['preferred_auth_method_id']!,
          _preferredAuthMethodIdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GatewayAgentBinding map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GatewayAgentBinding(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      gatewaySourceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}gateway_source_id'],
      )!,
      agentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}agent_id'],
      )!,
      preferredAuthMethodId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}preferred_auth_method_id'],
      ),
    );
  }

  @override
  $GatewayAgentBindingsTable createAlias(String alias) {
    return $GatewayAgentBindingsTable(attachedDatabase, alias);
  }
}

class GatewayAgentBinding extends DataClass
    implements Insertable<GatewayAgentBinding> {
  final String id;
  final String name;
  final String gatewaySourceId;
  final String agentId;
  final String? preferredAuthMethodId;
  const GatewayAgentBinding({
    required this.id,
    required this.name,
    required this.gatewaySourceId,
    required this.agentId,
    this.preferredAuthMethodId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['gateway_source_id'] = Variable<String>(gatewaySourceId);
    map['agent_id'] = Variable<String>(agentId);
    if (!nullToAbsent || preferredAuthMethodId != null) {
      map['preferred_auth_method_id'] = Variable<String>(preferredAuthMethodId);
    }
    return map;
  }

  GatewayAgentBindingsCompanion toCompanion(bool nullToAbsent) {
    return GatewayAgentBindingsCompanion(
      id: Value(id),
      name: Value(name),
      gatewaySourceId: Value(gatewaySourceId),
      agentId: Value(agentId),
      preferredAuthMethodId: preferredAuthMethodId == null && nullToAbsent
          ? const Value.absent()
          : Value(preferredAuthMethodId),
    );
  }

  factory GatewayAgentBinding.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GatewayAgentBinding(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      gatewaySourceId: serializer.fromJson<String>(json['gatewaySourceId']),
      agentId: serializer.fromJson<String>(json['agentId']),
      preferredAuthMethodId: serializer.fromJson<String?>(
        json['preferredAuthMethodId'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'gatewaySourceId': serializer.toJson<String>(gatewaySourceId),
      'agentId': serializer.toJson<String>(agentId),
      'preferredAuthMethodId': serializer.toJson<String?>(
        preferredAuthMethodId,
      ),
    };
  }

  GatewayAgentBinding copyWith({
    String? id,
    String? name,
    String? gatewaySourceId,
    String? agentId,
    Value<String?> preferredAuthMethodId = const Value.absent(),
  }) => GatewayAgentBinding(
    id: id ?? this.id,
    name: name ?? this.name,
    gatewaySourceId: gatewaySourceId ?? this.gatewaySourceId,
    agentId: agentId ?? this.agentId,
    preferredAuthMethodId: preferredAuthMethodId.present
        ? preferredAuthMethodId.value
        : this.preferredAuthMethodId,
  );
  GatewayAgentBinding copyWithCompanion(GatewayAgentBindingsCompanion data) {
    return GatewayAgentBinding(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      gatewaySourceId: data.gatewaySourceId.present
          ? data.gatewaySourceId.value
          : this.gatewaySourceId,
      agentId: data.agentId.present ? data.agentId.value : this.agentId,
      preferredAuthMethodId: data.preferredAuthMethodId.present
          ? data.preferredAuthMethodId.value
          : this.preferredAuthMethodId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GatewayAgentBinding(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('gatewaySourceId: $gatewaySourceId, ')
          ..write('agentId: $agentId, ')
          ..write('preferredAuthMethodId: $preferredAuthMethodId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, gatewaySourceId, agentId, preferredAuthMethodId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GatewayAgentBinding &&
          other.id == this.id &&
          other.name == this.name &&
          other.gatewaySourceId == this.gatewaySourceId &&
          other.agentId == this.agentId &&
          other.preferredAuthMethodId == this.preferredAuthMethodId);
}

class GatewayAgentBindingsCompanion
    extends UpdateCompanion<GatewayAgentBinding> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> gatewaySourceId;
  final Value<String> agentId;
  final Value<String?> preferredAuthMethodId;
  final Value<int> rowid;
  const GatewayAgentBindingsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.gatewaySourceId = const Value.absent(),
    this.agentId = const Value.absent(),
    this.preferredAuthMethodId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GatewayAgentBindingsCompanion.insert({
    required String id,
    required String name,
    required String gatewaySourceId,
    required String agentId,
    this.preferredAuthMethodId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       gatewaySourceId = Value(gatewaySourceId),
       agentId = Value(agentId);
  static Insertable<GatewayAgentBinding> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? gatewaySourceId,
    Expression<String>? agentId,
    Expression<String>? preferredAuthMethodId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (gatewaySourceId != null) 'gateway_source_id': gatewaySourceId,
      if (agentId != null) 'agent_id': agentId,
      if (preferredAuthMethodId != null)
        'preferred_auth_method_id': preferredAuthMethodId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GatewayAgentBindingsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? gatewaySourceId,
    Value<String>? agentId,
    Value<String?>? preferredAuthMethodId,
    Value<int>? rowid,
  }) {
    return GatewayAgentBindingsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      gatewaySourceId: gatewaySourceId ?? this.gatewaySourceId,
      agentId: agentId ?? this.agentId,
      preferredAuthMethodId:
          preferredAuthMethodId ?? this.preferredAuthMethodId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (gatewaySourceId.present) {
      map['gateway_source_id'] = Variable<String>(gatewaySourceId.value);
    }
    if (agentId.present) {
      map['agent_id'] = Variable<String>(agentId.value);
    }
    if (preferredAuthMethodId.present) {
      map['preferred_auth_method_id'] = Variable<String>(
        preferredAuthMethodId.value,
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GatewayAgentBindingsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('gatewaySourceId: $gatewaySourceId, ')
          ..write('agentId: $agentId, ')
          ..write('preferredAuthMethodId: $preferredAuthMethodId, ')
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
  static const VerificationMeta _serverIdMeta = const VerificationMeta(
    'serverId',
  );
  @override
  late final GeneratedColumn<String> serverId = GeneratedColumn<String>(
    'server_id',
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
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, serverId, title, cwd, updatedAt];
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
    if (data.containsKey('server_id')) {
      context.handle(
        _serverIdMeta,
        serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta),
      );
    } else if (isInserting) {
      context.missing(_serverIdMeta);
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
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
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
      serverId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}server_id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      ),
      cwd: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cwd'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      ),
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
  final String serverId;
  final String? title;
  final String? cwd;
  final int? updatedAt;
  const SessionCacheData({
    required this.id,
    required this.serverId,
    this.title,
    this.cwd,
    this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['server_id'] = Variable<String>(serverId);
    if (!nullToAbsent || title != null) {
      map['title'] = Variable<String>(title);
    }
    if (!nullToAbsent || cwd != null) {
      map['cwd'] = Variable<String>(cwd);
    }
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<int>(updatedAt);
    }
    return map;
  }

  SessionCacheCompanion toCompanion(bool nullToAbsent) {
    return SessionCacheCompanion(
      id: Value(id),
      serverId: Value(serverId),
      title: title == null && nullToAbsent
          ? const Value.absent()
          : Value(title),
      cwd: cwd == null && nullToAbsent ? const Value.absent() : Value(cwd),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
    );
  }

  factory SessionCacheData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SessionCacheData(
      id: serializer.fromJson<String>(json['id']),
      serverId: serializer.fromJson<String>(json['serverId']),
      title: serializer.fromJson<String?>(json['title']),
      cwd: serializer.fromJson<String?>(json['cwd']),
      updatedAt: serializer.fromJson<int?>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'serverId': serializer.toJson<String>(serverId),
      'title': serializer.toJson<String?>(title),
      'cwd': serializer.toJson<String?>(cwd),
      'updatedAt': serializer.toJson<int?>(updatedAt),
    };
  }

  SessionCacheData copyWith({
    String? id,
    String? serverId,
    Value<String?> title = const Value.absent(),
    Value<String?> cwd = const Value.absent(),
    Value<int?> updatedAt = const Value.absent(),
  }) => SessionCacheData(
    id: id ?? this.id,
    serverId: serverId ?? this.serverId,
    title: title.present ? title.value : this.title,
    cwd: cwd.present ? cwd.value : this.cwd,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
  );
  SessionCacheData copyWithCompanion(SessionCacheCompanion data) {
    return SessionCacheData(
      id: data.id.present ? data.id.value : this.id,
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
      title: data.title.present ? data.title.value : this.title,
      cwd: data.cwd.present ? data.cwd.value : this.cwd,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SessionCacheData(')
          ..write('id: $id, ')
          ..write('serverId: $serverId, ')
          ..write('title: $title, ')
          ..write('cwd: $cwd, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, serverId, title, cwd, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SessionCacheData &&
          other.id == this.id &&
          other.serverId == this.serverId &&
          other.title == this.title &&
          other.cwd == this.cwd &&
          other.updatedAt == this.updatedAt);
}

class SessionCacheCompanion extends UpdateCompanion<SessionCacheData> {
  final Value<String> id;
  final Value<String> serverId;
  final Value<String?> title;
  final Value<String?> cwd;
  final Value<int?> updatedAt;
  final Value<int> rowid;
  const SessionCacheCompanion({
    this.id = const Value.absent(),
    this.serverId = const Value.absent(),
    this.title = const Value.absent(),
    this.cwd = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SessionCacheCompanion.insert({
    required String id,
    required String serverId,
    this.title = const Value.absent(),
    this.cwd = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       serverId = Value(serverId);
  static Insertable<SessionCacheData> custom({
    Expression<String>? id,
    Expression<String>? serverId,
    Expression<String>? title,
    Expression<String>? cwd,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (serverId != null) 'server_id': serverId,
      if (title != null) 'title': title,
      if (cwd != null) 'cwd': cwd,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SessionCacheCompanion copyWith({
    Value<String>? id,
    Value<String>? serverId,
    Value<String?>? title,
    Value<String?>? cwd,
    Value<int?>? updatedAt,
    Value<int>? rowid,
  }) {
    return SessionCacheCompanion(
      id: id ?? this.id,
      serverId: serverId ?? this.serverId,
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
    if (serverId.present) {
      map['server_id'] = Variable<String>(serverId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (cwd.present) {
      map['cwd'] = Variable<String>(cwd.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
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
          ..write('serverId: $serverId, ')
          ..write('title: $title, ')
          ..write('cwd: $cwd, ')
          ..write('updatedAt: $updatedAt, ')
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
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
      ),
    );
  }

  @override
  $SessionSettingsTable createAlias(String alias) {
    return $SessionSettingsTable(attachedDatabase, alias);
  }
}

class SessionSetting extends DataClass implements Insertable<SessionSetting> {
  final String targetId;
  final String? cwd;
  const SessionSetting({required this.targetId, this.cwd});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['target_id'] = Variable<String>(targetId);
    if (!nullToAbsent || cwd != null) {
      map['cwd'] = Variable<String>(cwd);
    }
    return map;
  }

  SessionSettingsCompanion toCompanion(bool nullToAbsent) {
    return SessionSettingsCompanion(
      targetId: Value(targetId),
      cwd: cwd == null && nullToAbsent ? const Value.absent() : Value(cwd),
    );
  }

  factory SessionSetting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SessionSetting(
      targetId: serializer.fromJson<String>(json['targetId']),
      cwd: serializer.fromJson<String?>(json['cwd']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'targetId': serializer.toJson<String>(targetId),
      'cwd': serializer.toJson<String?>(cwd),
    };
  }

  SessionSetting copyWith({
    String? targetId,
    Value<String?> cwd = const Value.absent(),
  }) => SessionSetting(
    targetId: targetId ?? this.targetId,
    cwd: cwd.present ? cwd.value : this.cwd,
  );
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
  final Value<String?> cwd;
  final Value<int> rowid;
  const SessionSettingsCompanion({
    this.targetId = const Value.absent(),
    this.cwd = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SessionSettingsCompanion.insert({
    required String targetId,
    this.cwd = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : targetId = Value(targetId);
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
    Value<String?>? cwd,
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
  static const VerificationMeta _messageJsonMeta = const VerificationMeta(
    'messageJson',
  );
  @override
  late final GeneratedColumn<String> messageJson = GeneratedColumn<String>(
    'message_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, sessionId, messageJson, createdAt];
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
    if (data.containsKey('message_json')) {
      context.handle(
        _messageJsonMeta,
        messageJson.isAcceptableOrUnknown(
          data['message_json']!,
          _messageJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_messageJsonMeta);
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
      messageJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}message_json'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
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
  final String messageJson;
  final int createdAt;
  const ChatMessage({
    required this.id,
    required this.sessionId,
    required this.messageJson,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['session_id'] = Variable<String>(sessionId);
    map['message_json'] = Variable<String>(messageJson);
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  ChatMessagesCompanion toCompanion(bool nullToAbsent) {
    return ChatMessagesCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      messageJson: Value(messageJson),
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
      messageJson: serializer.fromJson<String>(json['messageJson']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'sessionId': serializer.toJson<String>(sessionId),
      'messageJson': serializer.toJson<String>(messageJson),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  ChatMessage copyWith({
    String? id,
    String? sessionId,
    String? messageJson,
    int? createdAt,
  }) => ChatMessage(
    id: id ?? this.id,
    sessionId: sessionId ?? this.sessionId,
    messageJson: messageJson ?? this.messageJson,
    createdAt: createdAt ?? this.createdAt,
  );
  ChatMessage copyWithCompanion(ChatMessagesCompanion data) {
    return ChatMessage(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      messageJson: data.messageJson.present
          ? data.messageJson.value
          : this.messageJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChatMessage(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('messageJson: $messageJson, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, sessionId, messageJson, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChatMessage &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.messageJson == this.messageJson &&
          other.createdAt == this.createdAt);
}

class ChatMessagesCompanion extends UpdateCompanion<ChatMessage> {
  final Value<String> id;
  final Value<String> sessionId;
  final Value<String> messageJson;
  final Value<int> createdAt;
  final Value<int> rowid;
  const ChatMessagesCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.messageJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ChatMessagesCompanion.insert({
    required String id,
    required String sessionId,
    required String messageJson,
    required int createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       sessionId = Value(sessionId),
       messageJson = Value(messageJson),
       createdAt = Value(createdAt);
  static Insertable<ChatMessage> custom({
    Expression<String>? id,
    Expression<String>? sessionId,
    Expression<String>? messageJson,
    Expression<int>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (messageJson != null) 'message_json': messageJson,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ChatMessagesCompanion copyWith({
    Value<String>? id,
    Value<String>? sessionId,
    Value<String>? messageJson,
    Value<int>? createdAt,
    Value<int>? rowid,
  }) {
    return ChatMessagesCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      messageJson: messageJson ?? this.messageJson,
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
    if (messageJson.present) {
      map['message_json'] = Variable<String>(messageJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
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
          ..write('messageJson: $messageJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ServerConfigsTable serverConfigs = $ServerConfigsTable(this);
  late final $GatewaySourcesTable gatewaySources = $GatewaySourcesTable(this);
  late final $GatewayAgentBindingsTable gatewayAgentBindings =
      $GatewayAgentBindingsTable(this);
  late final $SessionCacheTable sessionCache = $SessionCacheTable(this);
  late final $SessionSettingsTable sessionSettings = $SessionSettingsTable(
    this,
  );
  late final $ChatMessagesTable chatMessages = $ChatMessagesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    serverConfigs,
    gatewaySources,
    gatewayAgentBindings,
    sessionCache,
    sessionSettings,
    chatMessages,
  ];
}

typedef $$ServerConfigsTableCreateCompanionBuilder =
    ServerConfigsCompanion Function({
      required String id,
      required String name,
      required String scheme,
      required String host,
      required String token,
      Value<String?> preferredAuthMethodId,
      required String type,
      Value<int> rowid,
    });
typedef $$ServerConfigsTableUpdateCompanionBuilder =
    ServerConfigsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> scheme,
      Value<String> host,
      Value<String> token,
      Value<String?> preferredAuthMethodId,
      Value<String> type,
      Value<int> rowid,
    });

class $$ServerConfigsTableFilterComposer
    extends Composer<_$AppDatabase, $ServerConfigsTable> {
  $$ServerConfigsTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get scheme => $composableBuilder(
    column: $table.scheme,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get host => $composableBuilder(
    column: $table.host,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get token => $composableBuilder(
    column: $table.token,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get preferredAuthMethodId => $composableBuilder(
    column: $table.preferredAuthMethodId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ServerConfigsTableOrderingComposer
    extends Composer<_$AppDatabase, $ServerConfigsTable> {
  $$ServerConfigsTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get scheme => $composableBuilder(
    column: $table.scheme,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get host => $composableBuilder(
    column: $table.host,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get token => $composableBuilder(
    column: $table.token,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get preferredAuthMethodId => $composableBuilder(
    column: $table.preferredAuthMethodId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ServerConfigsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ServerConfigsTable> {
  $$ServerConfigsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get scheme =>
      $composableBuilder(column: $table.scheme, builder: (column) => column);

  GeneratedColumn<String> get host =>
      $composableBuilder(column: $table.host, builder: (column) => column);

  GeneratedColumn<String> get token =>
      $composableBuilder(column: $table.token, builder: (column) => column);

  GeneratedColumn<String> get preferredAuthMethodId => $composableBuilder(
    column: $table.preferredAuthMethodId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);
}

class $$ServerConfigsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ServerConfigsTable,
          ServerConfig,
          $$ServerConfigsTableFilterComposer,
          $$ServerConfigsTableOrderingComposer,
          $$ServerConfigsTableAnnotationComposer,
          $$ServerConfigsTableCreateCompanionBuilder,
          $$ServerConfigsTableUpdateCompanionBuilder,
          (
            ServerConfig,
            BaseReferences<_$AppDatabase, $ServerConfigsTable, ServerConfig>,
          ),
          ServerConfig,
          PrefetchHooks Function()
        > {
  $$ServerConfigsTableTableManager(_$AppDatabase db, $ServerConfigsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ServerConfigsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ServerConfigsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ServerConfigsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> scheme = const Value.absent(),
                Value<String> host = const Value.absent(),
                Value<String> token = const Value.absent(),
                Value<String?> preferredAuthMethodId = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ServerConfigsCompanion(
                id: id,
                name: name,
                scheme: scheme,
                host: host,
                token: token,
                preferredAuthMethodId: preferredAuthMethodId,
                type: type,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String scheme,
                required String host,
                required String token,
                Value<String?> preferredAuthMethodId = const Value.absent(),
                required String type,
                Value<int> rowid = const Value.absent(),
              }) => ServerConfigsCompanion.insert(
                id: id,
                name: name,
                scheme: scheme,
                host: host,
                token: token,
                preferredAuthMethodId: preferredAuthMethodId,
                type: type,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ServerConfigsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ServerConfigsTable,
      ServerConfig,
      $$ServerConfigsTableFilterComposer,
      $$ServerConfigsTableOrderingComposer,
      $$ServerConfigsTableAnnotationComposer,
      $$ServerConfigsTableCreateCompanionBuilder,
      $$ServerConfigsTableUpdateCompanionBuilder,
      (
        ServerConfig,
        BaseReferences<_$AppDatabase, $ServerConfigsTable, ServerConfig>,
      ),
      ServerConfig,
      PrefetchHooks Function()
    >;
typedef $$GatewaySourcesTableCreateCompanionBuilder =
    GatewaySourcesCompanion Function({
      required String id,
      required String name,
      required String scheme,
      required String host,
      required String gatewayCredential,
      Value<DateTime?> gatewayCredentialExpiresAt,
      Value<String?> gatewayRemoteMode,
      Value<int> rowid,
    });
typedef $$GatewaySourcesTableUpdateCompanionBuilder =
    GatewaySourcesCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> scheme,
      Value<String> host,
      Value<String> gatewayCredential,
      Value<DateTime?> gatewayCredentialExpiresAt,
      Value<String?> gatewayRemoteMode,
      Value<int> rowid,
    });

class $$GatewaySourcesTableFilterComposer
    extends Composer<_$AppDatabase, $GatewaySourcesTable> {
  $$GatewaySourcesTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get scheme => $composableBuilder(
    column: $table.scheme,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get host => $composableBuilder(
    column: $table.host,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get gatewayCredential => $composableBuilder(
    column: $table.gatewayCredential,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get gatewayCredentialExpiresAt => $composableBuilder(
    column: $table.gatewayCredentialExpiresAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get gatewayRemoteMode => $composableBuilder(
    column: $table.gatewayRemoteMode,
    builder: (column) => ColumnFilters(column),
  );
}

class $$GatewaySourcesTableOrderingComposer
    extends Composer<_$AppDatabase, $GatewaySourcesTable> {
  $$GatewaySourcesTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get scheme => $composableBuilder(
    column: $table.scheme,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get host => $composableBuilder(
    column: $table.host,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get gatewayCredential => $composableBuilder(
    column: $table.gatewayCredential,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get gatewayCredentialExpiresAt =>
      $composableBuilder(
        column: $table.gatewayCredentialExpiresAt,
        builder: (column) => ColumnOrderings(column),
      );

  ColumnOrderings<String> get gatewayRemoteMode => $composableBuilder(
    column: $table.gatewayRemoteMode,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$GatewaySourcesTableAnnotationComposer
    extends Composer<_$AppDatabase, $GatewaySourcesTable> {
  $$GatewaySourcesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get scheme =>
      $composableBuilder(column: $table.scheme, builder: (column) => column);

  GeneratedColumn<String> get host =>
      $composableBuilder(column: $table.host, builder: (column) => column);

  GeneratedColumn<String> get gatewayCredential => $composableBuilder(
    column: $table.gatewayCredential,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get gatewayCredentialExpiresAt =>
      $composableBuilder(
        column: $table.gatewayCredentialExpiresAt,
        builder: (column) => column,
      );

  GeneratedColumn<String> get gatewayRemoteMode => $composableBuilder(
    column: $table.gatewayRemoteMode,
    builder: (column) => column,
  );
}

class $$GatewaySourcesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GatewaySourcesTable,
          GatewaySource,
          $$GatewaySourcesTableFilterComposer,
          $$GatewaySourcesTableOrderingComposer,
          $$GatewaySourcesTableAnnotationComposer,
          $$GatewaySourcesTableCreateCompanionBuilder,
          $$GatewaySourcesTableUpdateCompanionBuilder,
          (
            GatewaySource,
            BaseReferences<_$AppDatabase, $GatewaySourcesTable, GatewaySource>,
          ),
          GatewaySource,
          PrefetchHooks Function()
        > {
  $$GatewaySourcesTableTableManager(
    _$AppDatabase db,
    $GatewaySourcesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GatewaySourcesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GatewaySourcesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GatewaySourcesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> scheme = const Value.absent(),
                Value<String> host = const Value.absent(),
                Value<String> gatewayCredential = const Value.absent(),
                Value<DateTime?> gatewayCredentialExpiresAt =
                    const Value.absent(),
                Value<String?> gatewayRemoteMode = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GatewaySourcesCompanion(
                id: id,
                name: name,
                scheme: scheme,
                host: host,
                gatewayCredential: gatewayCredential,
                gatewayCredentialExpiresAt: gatewayCredentialExpiresAt,
                gatewayRemoteMode: gatewayRemoteMode,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String scheme,
                required String host,
                required String gatewayCredential,
                Value<DateTime?> gatewayCredentialExpiresAt =
                    const Value.absent(),
                Value<String?> gatewayRemoteMode = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GatewaySourcesCompanion.insert(
                id: id,
                name: name,
                scheme: scheme,
                host: host,
                gatewayCredential: gatewayCredential,
                gatewayCredentialExpiresAt: gatewayCredentialExpiresAt,
                gatewayRemoteMode: gatewayRemoteMode,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$GatewaySourcesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GatewaySourcesTable,
      GatewaySource,
      $$GatewaySourcesTableFilterComposer,
      $$GatewaySourcesTableOrderingComposer,
      $$GatewaySourcesTableAnnotationComposer,
      $$GatewaySourcesTableCreateCompanionBuilder,
      $$GatewaySourcesTableUpdateCompanionBuilder,
      (
        GatewaySource,
        BaseReferences<_$AppDatabase, $GatewaySourcesTable, GatewaySource>,
      ),
      GatewaySource,
      PrefetchHooks Function()
    >;
typedef $$GatewayAgentBindingsTableCreateCompanionBuilder =
    GatewayAgentBindingsCompanion Function({
      required String id,
      required String name,
      required String gatewaySourceId,
      required String agentId,
      Value<String?> preferredAuthMethodId,
      Value<int> rowid,
    });
typedef $$GatewayAgentBindingsTableUpdateCompanionBuilder =
    GatewayAgentBindingsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> gatewaySourceId,
      Value<String> agentId,
      Value<String?> preferredAuthMethodId,
      Value<int> rowid,
    });

class $$GatewayAgentBindingsTableFilterComposer
    extends Composer<_$AppDatabase, $GatewayAgentBindingsTable> {
  $$GatewayAgentBindingsTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get gatewaySourceId => $composableBuilder(
    column: $table.gatewaySourceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get agentId => $composableBuilder(
    column: $table.agentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get preferredAuthMethodId => $composableBuilder(
    column: $table.preferredAuthMethodId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$GatewayAgentBindingsTableOrderingComposer
    extends Composer<_$AppDatabase, $GatewayAgentBindingsTable> {
  $$GatewayAgentBindingsTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get gatewaySourceId => $composableBuilder(
    column: $table.gatewaySourceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get agentId => $composableBuilder(
    column: $table.agentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get preferredAuthMethodId => $composableBuilder(
    column: $table.preferredAuthMethodId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$GatewayAgentBindingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $GatewayAgentBindingsTable> {
  $$GatewayAgentBindingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get gatewaySourceId => $composableBuilder(
    column: $table.gatewaySourceId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get agentId =>
      $composableBuilder(column: $table.agentId, builder: (column) => column);

  GeneratedColumn<String> get preferredAuthMethodId => $composableBuilder(
    column: $table.preferredAuthMethodId,
    builder: (column) => column,
  );
}

class $$GatewayAgentBindingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GatewayAgentBindingsTable,
          GatewayAgentBinding,
          $$GatewayAgentBindingsTableFilterComposer,
          $$GatewayAgentBindingsTableOrderingComposer,
          $$GatewayAgentBindingsTableAnnotationComposer,
          $$GatewayAgentBindingsTableCreateCompanionBuilder,
          $$GatewayAgentBindingsTableUpdateCompanionBuilder,
          (
            GatewayAgentBinding,
            BaseReferences<
              _$AppDatabase,
              $GatewayAgentBindingsTable,
              GatewayAgentBinding
            >,
          ),
          GatewayAgentBinding,
          PrefetchHooks Function()
        > {
  $$GatewayAgentBindingsTableTableManager(
    _$AppDatabase db,
    $GatewayAgentBindingsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GatewayAgentBindingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GatewayAgentBindingsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$GatewayAgentBindingsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> gatewaySourceId = const Value.absent(),
                Value<String> agentId = const Value.absent(),
                Value<String?> preferredAuthMethodId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GatewayAgentBindingsCompanion(
                id: id,
                name: name,
                gatewaySourceId: gatewaySourceId,
                agentId: agentId,
                preferredAuthMethodId: preferredAuthMethodId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String gatewaySourceId,
                required String agentId,
                Value<String?> preferredAuthMethodId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GatewayAgentBindingsCompanion.insert(
                id: id,
                name: name,
                gatewaySourceId: gatewaySourceId,
                agentId: agentId,
                preferredAuthMethodId: preferredAuthMethodId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$GatewayAgentBindingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GatewayAgentBindingsTable,
      GatewayAgentBinding,
      $$GatewayAgentBindingsTableFilterComposer,
      $$GatewayAgentBindingsTableOrderingComposer,
      $$GatewayAgentBindingsTableAnnotationComposer,
      $$GatewayAgentBindingsTableCreateCompanionBuilder,
      $$GatewayAgentBindingsTableUpdateCompanionBuilder,
      (
        GatewayAgentBinding,
        BaseReferences<
          _$AppDatabase,
          $GatewayAgentBindingsTable,
          GatewayAgentBinding
        >,
      ),
      GatewayAgentBinding,
      PrefetchHooks Function()
    >;
typedef $$SessionCacheTableCreateCompanionBuilder =
    SessionCacheCompanion Function({
      required String id,
      required String serverId,
      Value<String?> title,
      Value<String?> cwd,
      Value<int?> updatedAt,
      Value<int> rowid,
    });
typedef $$SessionCacheTableUpdateCompanionBuilder =
    SessionCacheCompanion Function({
      Value<String> id,
      Value<String> serverId,
      Value<String?> title,
      Value<String?> cwd,
      Value<int?> updatedAt,
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

  ColumnFilters<String> get serverId => $composableBuilder(
    column: $table.serverId,
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

  ColumnFilters<int> get updatedAt => $composableBuilder(
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

  ColumnOrderings<String> get serverId => $composableBuilder(
    column: $table.serverId,
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

  ColumnOrderings<int> get updatedAt => $composableBuilder(
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

  GeneratedColumn<String> get serverId =>
      $composableBuilder(column: $table.serverId, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get cwd =>
      $composableBuilder(column: $table.cwd, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
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
                Value<String> serverId = const Value.absent(),
                Value<String?> title = const Value.absent(),
                Value<String?> cwd = const Value.absent(),
                Value<int?> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SessionCacheCompanion(
                id: id,
                serverId: serverId,
                title: title,
                cwd: cwd,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String serverId,
                Value<String?> title = const Value.absent(),
                Value<String?> cwd = const Value.absent(),
                Value<int?> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SessionCacheCompanion.insert(
                id: id,
                serverId: serverId,
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
typedef $$SessionSettingsTableCreateCompanionBuilder =
    SessionSettingsCompanion Function({
      required String targetId,
      Value<String?> cwd,
      Value<int> rowid,
    });
typedef $$SessionSettingsTableUpdateCompanionBuilder =
    SessionSettingsCompanion Function({
      Value<String> targetId,
      Value<String?> cwd,
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
                Value<String?> cwd = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SessionSettingsCompanion(
                targetId: targetId,
                cwd: cwd,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String targetId,
                Value<String?> cwd = const Value.absent(),
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
typedef $$ChatMessagesTableCreateCompanionBuilder =
    ChatMessagesCompanion Function({
      required String id,
      required String sessionId,
      required String messageJson,
      required int createdAt,
      Value<int> rowid,
    });
typedef $$ChatMessagesTableUpdateCompanionBuilder =
    ChatMessagesCompanion Function({
      Value<String> id,
      Value<String> sessionId,
      Value<String> messageJson,
      Value<int> createdAt,
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

  ColumnFilters<String> get messageJson => $composableBuilder(
    column: $table.messageJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
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

  ColumnOrderings<String> get messageJson => $composableBuilder(
    column: $table.messageJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
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

  GeneratedColumn<String> get messageJson => $composableBuilder(
    column: $table.messageJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
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
                Value<String> messageJson = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ChatMessagesCompanion(
                id: id,
                sessionId: sessionId,
                messageJson: messageJson,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String sessionId,
                required String messageJson,
                required int createdAt,
                Value<int> rowid = const Value.absent(),
              }) => ChatMessagesCompanion.insert(
                id: id,
                sessionId: sessionId,
                messageJson: messageJson,
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

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ServerConfigsTableTableManager get serverConfigs =>
      $$ServerConfigsTableTableManager(_db, _db.serverConfigs);
  $$GatewaySourcesTableTableManager get gatewaySources =>
      $$GatewaySourcesTableTableManager(_db, _db.gatewaySources);
  $$GatewayAgentBindingsTableTableManager get gatewayAgentBindings =>
      $$GatewayAgentBindingsTableTableManager(_db, _db.gatewayAgentBindings);
  $$SessionCacheTableTableManager get sessionCache =>
      $$SessionCacheTableTableManager(_db, _db.sessionCache);
  $$SessionSettingsTableTableManager get sessionSettings =>
      $$SessionSettingsTableTableManager(_db, _db.sessionSettings);
  $$ChatMessagesTableTableManager get chatMessages =>
      $$ChatMessagesTableTableManager(_db, _db.chatMessages);
}
