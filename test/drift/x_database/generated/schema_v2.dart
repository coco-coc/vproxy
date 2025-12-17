// dart format width=80
// GENERATED CODE, DO NOT EDIT BY HAND.
// ignore_for_file: type=lint
import 'package:drift/drift.dart';

class Subscriptions extends Table
    with TableInfo<Subscriptions, SubscriptionsData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Subscriptions(this.attachedDatabase, [this._alias]);
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  late final GeneratedColumn<String> link = GeneratedColumn<String>(
      'link', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  late final GeneratedColumn<double> remainingData = GeneratedColumn<double>(
      'remaining_data', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  late final GeneratedColumn<int> endTime = GeneratedColumn<int>(
      'end_time', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  late final GeneratedColumn<String> website = GeneratedColumn<String>(
      'website', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const CustomExpression('\'\''));
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const CustomExpression('\'\''));
  late final GeneratedColumn<int> lastUpdate = GeneratedColumn<int>(
      'last_update', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  late final GeneratedColumn<int> lastSuccessUpdate = GeneratedColumn<int>(
      'last_success_update', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  late final GeneratedColumn<bool> enabled = GeneratedColumn<bool>(
      'enabled', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("enabled" IN (0, 1))'),
      defaultValue: const CustomExpression('1'));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        link,
        remainingData,
        endTime,
        website,
        description,
        lastUpdate,
        lastSuccessUpdate,
        enabled
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'subscriptions';
  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SubscriptionsData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SubscriptionsData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      link: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}link'])!,
      remainingData: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}remaining_data']),
      endTime: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}end_time']),
      website: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}website'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description'])!,
      lastUpdate: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}last_update'])!,
      lastSuccessUpdate: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}last_success_update'])!,
      enabled: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}enabled'])!,
    );
  }

  @override
  Subscriptions createAlias(String alias) {
    return Subscriptions(attachedDatabase, alias);
  }
}

class SubscriptionsData extends DataClass
    implements Insertable<SubscriptionsData> {
  final int id;
  final String name;
  final String link;
  final double? remainingData;
  final int? endTime;
  final String website;
  final String description;
  final int lastUpdate;
  final int lastSuccessUpdate;
  final bool enabled;
  const SubscriptionsData(
      {required this.id,
      required this.name,
      required this.link,
      this.remainingData,
      this.endTime,
      required this.website,
      required this.description,
      required this.lastUpdate,
      required this.lastSuccessUpdate,
      required this.enabled});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['link'] = Variable<String>(link);
    if (!nullToAbsent || remainingData != null) {
      map['remaining_data'] = Variable<double>(remainingData);
    }
    if (!nullToAbsent || endTime != null) {
      map['end_time'] = Variable<int>(endTime);
    }
    map['website'] = Variable<String>(website);
    map['description'] = Variable<String>(description);
    map['last_update'] = Variable<int>(lastUpdate);
    map['last_success_update'] = Variable<int>(lastSuccessUpdate);
    map['enabled'] = Variable<bool>(enabled);
    return map;
  }

  SubscriptionsCompanion toCompanion(bool nullToAbsent) {
    return SubscriptionsCompanion(
      id: Value(id),
      name: Value(name),
      link: Value(link),
      remainingData: remainingData == null && nullToAbsent
          ? const Value.absent()
          : Value(remainingData),
      endTime: endTime == null && nullToAbsent
          ? const Value.absent()
          : Value(endTime),
      website: Value(website),
      description: Value(description),
      lastUpdate: Value(lastUpdate),
      lastSuccessUpdate: Value(lastSuccessUpdate),
      enabled: Value(enabled),
    );
  }

  factory SubscriptionsData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SubscriptionsData(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      link: serializer.fromJson<String>(json['link']),
      remainingData: serializer.fromJson<double?>(json['remainingData']),
      endTime: serializer.fromJson<int?>(json['endTime']),
      website: serializer.fromJson<String>(json['website']),
      description: serializer.fromJson<String>(json['description']),
      lastUpdate: serializer.fromJson<int>(json['lastUpdate']),
      lastSuccessUpdate: serializer.fromJson<int>(json['lastSuccessUpdate']),
      enabled: serializer.fromJson<bool>(json['enabled']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'link': serializer.toJson<String>(link),
      'remainingData': serializer.toJson<double?>(remainingData),
      'endTime': serializer.toJson<int?>(endTime),
      'website': serializer.toJson<String>(website),
      'description': serializer.toJson<String>(description),
      'lastUpdate': serializer.toJson<int>(lastUpdate),
      'lastSuccessUpdate': serializer.toJson<int>(lastSuccessUpdate),
      'enabled': serializer.toJson<bool>(enabled),
    };
  }

  SubscriptionsData copyWith(
          {int? id,
          String? name,
          String? link,
          Value<double?> remainingData = const Value.absent(),
          Value<int?> endTime = const Value.absent(),
          String? website,
          String? description,
          int? lastUpdate,
          int? lastSuccessUpdate,
          bool? enabled}) =>
      SubscriptionsData(
        id: id ?? this.id,
        name: name ?? this.name,
        link: link ?? this.link,
        remainingData:
            remainingData.present ? remainingData.value : this.remainingData,
        endTime: endTime.present ? endTime.value : this.endTime,
        website: website ?? this.website,
        description: description ?? this.description,
        lastUpdate: lastUpdate ?? this.lastUpdate,
        lastSuccessUpdate: lastSuccessUpdate ?? this.lastSuccessUpdate,
        enabled: enabled ?? this.enabled,
      );
  SubscriptionsData copyWithCompanion(SubscriptionsCompanion data) {
    return SubscriptionsData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      link: data.link.present ? data.link.value : this.link,
      remainingData: data.remainingData.present
          ? data.remainingData.value
          : this.remainingData,
      endTime: data.endTime.present ? data.endTime.value : this.endTime,
      website: data.website.present ? data.website.value : this.website,
      description:
          data.description.present ? data.description.value : this.description,
      lastUpdate:
          data.lastUpdate.present ? data.lastUpdate.value : this.lastUpdate,
      lastSuccessUpdate: data.lastSuccessUpdate.present
          ? data.lastSuccessUpdate.value
          : this.lastSuccessUpdate,
      enabled: data.enabled.present ? data.enabled.value : this.enabled,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SubscriptionsData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('link: $link, ')
          ..write('remainingData: $remainingData, ')
          ..write('endTime: $endTime, ')
          ..write('website: $website, ')
          ..write('description: $description, ')
          ..write('lastUpdate: $lastUpdate, ')
          ..write('lastSuccessUpdate: $lastSuccessUpdate, ')
          ..write('enabled: $enabled')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, link, remainingData, endTime,
      website, description, lastUpdate, lastSuccessUpdate, enabled);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SubscriptionsData &&
          other.id == this.id &&
          other.name == this.name &&
          other.link == this.link &&
          other.remainingData == this.remainingData &&
          other.endTime == this.endTime &&
          other.website == this.website &&
          other.description == this.description &&
          other.lastUpdate == this.lastUpdate &&
          other.lastSuccessUpdate == this.lastSuccessUpdate &&
          other.enabled == this.enabled);
}

class SubscriptionsCompanion extends UpdateCompanion<SubscriptionsData> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> link;
  final Value<double?> remainingData;
  final Value<int?> endTime;
  final Value<String> website;
  final Value<String> description;
  final Value<int> lastUpdate;
  final Value<int> lastSuccessUpdate;
  final Value<bool> enabled;
  const SubscriptionsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.link = const Value.absent(),
    this.remainingData = const Value.absent(),
    this.endTime = const Value.absent(),
    this.website = const Value.absent(),
    this.description = const Value.absent(),
    this.lastUpdate = const Value.absent(),
    this.lastSuccessUpdate = const Value.absent(),
    this.enabled = const Value.absent(),
  });
  SubscriptionsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String link,
    this.remainingData = const Value.absent(),
    this.endTime = const Value.absent(),
    this.website = const Value.absent(),
    this.description = const Value.absent(),
    required int lastUpdate,
    required int lastSuccessUpdate,
    this.enabled = const Value.absent(),
  })  : name = Value(name),
        link = Value(link),
        lastUpdate = Value(lastUpdate),
        lastSuccessUpdate = Value(lastSuccessUpdate);
  static Insertable<SubscriptionsData> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? link,
    Expression<double>? remainingData,
    Expression<int>? endTime,
    Expression<String>? website,
    Expression<String>? description,
    Expression<int>? lastUpdate,
    Expression<int>? lastSuccessUpdate,
    Expression<bool>? enabled,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (link != null) 'link': link,
      if (remainingData != null) 'remaining_data': remainingData,
      if (endTime != null) 'end_time': endTime,
      if (website != null) 'website': website,
      if (description != null) 'description': description,
      if (lastUpdate != null) 'last_update': lastUpdate,
      if (lastSuccessUpdate != null) 'last_success_update': lastSuccessUpdate,
      if (enabled != null) 'enabled': enabled,
    });
  }

  SubscriptionsCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<String>? link,
      Value<double?>? remainingData,
      Value<int?>? endTime,
      Value<String>? website,
      Value<String>? description,
      Value<int>? lastUpdate,
      Value<int>? lastSuccessUpdate,
      Value<bool>? enabled}) {
    return SubscriptionsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      link: link ?? this.link,
      remainingData: remainingData ?? this.remainingData,
      endTime: endTime ?? this.endTime,
      website: website ?? this.website,
      description: description ?? this.description,
      lastUpdate: lastUpdate ?? this.lastUpdate,
      lastSuccessUpdate: lastSuccessUpdate ?? this.lastSuccessUpdate,
      enabled: enabled ?? this.enabled,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (link.present) {
      map['link'] = Variable<String>(link.value);
    }
    if (remainingData.present) {
      map['remaining_data'] = Variable<double>(remainingData.value);
    }
    if (endTime.present) {
      map['end_time'] = Variable<int>(endTime.value);
    }
    if (website.present) {
      map['website'] = Variable<String>(website.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (lastUpdate.present) {
      map['last_update'] = Variable<int>(lastUpdate.value);
    }
    if (lastSuccessUpdate.present) {
      map['last_success_update'] = Variable<int>(lastSuccessUpdate.value);
    }
    if (enabled.present) {
      map['enabled'] = Variable<bool>(enabled.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SubscriptionsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('link: $link, ')
          ..write('remainingData: $remainingData, ')
          ..write('endTime: $endTime, ')
          ..write('website: $website, ')
          ..write('description: $description, ')
          ..write('lastUpdate: $lastUpdate, ')
          ..write('lastSuccessUpdate: $lastSuccessUpdate, ')
          ..write('enabled: $enabled')
          ..write(')'))
        .toString();
  }
}

class OutboundHandlers extends Table
    with TableInfo<OutboundHandlers, OutboundHandlersData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  OutboundHandlers(this.attachedDatabase, [this._alias]);
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  late final GeneratedColumn<bool> selected = GeneratedColumn<bool>(
      'selected', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("selected" IN (0, 1))'));
  late final GeneratedColumn<bool> enabled = GeneratedColumn<bool>(
      'enabled', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("enabled" IN (0, 1))'));
  late final GeneratedColumn<String> countryCode = GeneratedColumn<String>(
      'country_code', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  late final GeneratedColumn<String> sni = GeneratedColumn<String>(
      'sni', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  late final GeneratedColumn<double> speed = GeneratedColumn<double>(
      'speed', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const CustomExpression('0.0'));
  late final GeneratedColumn<int> ping = GeneratedColumn<int>(
      'ping', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const CustomExpression('0'));
  late final GeneratedColumn<double> speed1 = GeneratedColumn<double>(
      'speed1', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const CustomExpression('0.0'));
  late final GeneratedColumn<double> dspeed = GeneratedColumn<double>(
      'dspeed', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const CustomExpression('0.0'));
  late final GeneratedColumn<int> ok = GeneratedColumn<int>(
      'ok', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const CustomExpression('0'));
  late final GeneratedColumn<int> tcpOK = GeneratedColumn<int>(
      'tcp_o_k', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const CustomExpression('0'));
  late final GeneratedColumn<int> dbCdn = GeneratedColumn<int>(
      'db_cdn', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  late final GeneratedColumn<String> serverIp = GeneratedColumn<String>(
      'server_ip', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  late final GeneratedColumn<Uint8List> config = GeneratedColumn<Uint8List>(
      'config', aliasedName, false,
      type: DriftSqlType.blob, requiredDuringInsert: true);
  late final GeneratedColumn<int> subId = GeneratedColumn<int>(
      'sub_id', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES subscriptions (id) ON DELETE CASCADE'));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        selected,
        enabled,
        countryCode,
        sni,
        speed,
        ping,
        speed1,
        dspeed,
        ok,
        tcpOK,
        dbCdn,
        serverIp,
        config,
        subId
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'outbound_handlers';
  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  OutboundHandlersData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OutboundHandlersData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      selected: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}selected'])!,
      enabled: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}enabled'])!,
      countryCode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}country_code'])!,
      sni: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sni'])!,
      speed: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}speed'])!,
      ping: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}ping'])!,
      speed1: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}speed1'])!,
      dspeed: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}dspeed'])!,
      ok: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}ok'])!,
      tcpOK: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}tcp_o_k'])!,
      dbCdn: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}db_cdn']),
      serverIp: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}server_ip'])!,
      config: attachedDatabase.typeMapping
          .read(DriftSqlType.blob, data['${effectivePrefix}config'])!,
      subId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sub_id']),
    );
  }

  @override
  OutboundHandlers createAlias(String alias) {
    return OutboundHandlers(attachedDatabase, alias);
  }
}

class OutboundHandlersData extends DataClass
    implements Insertable<OutboundHandlersData> {
  final int id;
  final bool selected;
  final bool enabled;
  final String countryCode;
  final String sni;
  final double speed;
  final int ping;
  final double speed1;
  final double dspeed;
  final int ok;
  final int tcpOK;
  final int? dbCdn;
  final String serverIp;
  final Uint8List config;
  final int? subId;
  const OutboundHandlersData(
      {required this.id,
      required this.selected,
      required this.enabled,
      required this.countryCode,
      required this.sni,
      required this.speed,
      required this.ping,
      required this.speed1,
      required this.dspeed,
      required this.ok,
      required this.tcpOK,
      this.dbCdn,
      required this.serverIp,
      required this.config,
      this.subId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['selected'] = Variable<bool>(selected);
    map['enabled'] = Variable<bool>(enabled);
    map['country_code'] = Variable<String>(countryCode);
    map['sni'] = Variable<String>(sni);
    map['speed'] = Variable<double>(speed);
    map['ping'] = Variable<int>(ping);
    map['speed1'] = Variable<double>(speed1);
    map['dspeed'] = Variable<double>(dspeed);
    map['ok'] = Variable<int>(ok);
    map['tcp_o_k'] = Variable<int>(tcpOK);
    if (!nullToAbsent || dbCdn != null) {
      map['db_cdn'] = Variable<int>(dbCdn);
    }
    map['server_ip'] = Variable<String>(serverIp);
    map['config'] = Variable<Uint8List>(config);
    if (!nullToAbsent || subId != null) {
      map['sub_id'] = Variable<int>(subId);
    }
    return map;
  }

  OutboundHandlersCompanion toCompanion(bool nullToAbsent) {
    return OutboundHandlersCompanion(
      id: Value(id),
      selected: Value(selected),
      enabled: Value(enabled),
      countryCode: Value(countryCode),
      sni: Value(sni),
      speed: Value(speed),
      ping: Value(ping),
      speed1: Value(speed1),
      dspeed: Value(dspeed),
      ok: Value(ok),
      tcpOK: Value(tcpOK),
      dbCdn:
          dbCdn == null && nullToAbsent ? const Value.absent() : Value(dbCdn),
      serverIp: Value(serverIp),
      config: Value(config),
      subId:
          subId == null && nullToAbsent ? const Value.absent() : Value(subId),
    );
  }

  factory OutboundHandlersData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OutboundHandlersData(
      id: serializer.fromJson<int>(json['id']),
      selected: serializer.fromJson<bool>(json['selected']),
      enabled: serializer.fromJson<bool>(json['enabled']),
      countryCode: serializer.fromJson<String>(json['countryCode']),
      sni: serializer.fromJson<String>(json['sni']),
      speed: serializer.fromJson<double>(json['speed']),
      ping: serializer.fromJson<int>(json['ping']),
      speed1: serializer.fromJson<double>(json['speed1']),
      dspeed: serializer.fromJson<double>(json['dspeed']),
      ok: serializer.fromJson<int>(json['ok']),
      tcpOK: serializer.fromJson<int>(json['tcpOK']),
      dbCdn: serializer.fromJson<int?>(json['dbCdn']),
      serverIp: serializer.fromJson<String>(json['serverIp']),
      config: serializer.fromJson<Uint8List>(json['config']),
      subId: serializer.fromJson<int?>(json['subId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'selected': serializer.toJson<bool>(selected),
      'enabled': serializer.toJson<bool>(enabled),
      'countryCode': serializer.toJson<String>(countryCode),
      'sni': serializer.toJson<String>(sni),
      'speed': serializer.toJson<double>(speed),
      'ping': serializer.toJson<int>(ping),
      'speed1': serializer.toJson<double>(speed1),
      'dspeed': serializer.toJson<double>(dspeed),
      'ok': serializer.toJson<int>(ok),
      'tcpOK': serializer.toJson<int>(tcpOK),
      'dbCdn': serializer.toJson<int?>(dbCdn),
      'serverIp': serializer.toJson<String>(serverIp),
      'config': serializer.toJson<Uint8List>(config),
      'subId': serializer.toJson<int?>(subId),
    };
  }

  OutboundHandlersData copyWith(
          {int? id,
          bool? selected,
          bool? enabled,
          String? countryCode,
          String? sni,
          double? speed,
          int? ping,
          double? speed1,
          double? dspeed,
          int? ok,
          int? tcpOK,
          Value<int?> dbCdn = const Value.absent(),
          String? serverIp,
          Uint8List? config,
          Value<int?> subId = const Value.absent()}) =>
      OutboundHandlersData(
        id: id ?? this.id,
        selected: selected ?? this.selected,
        enabled: enabled ?? this.enabled,
        countryCode: countryCode ?? this.countryCode,
        sni: sni ?? this.sni,
        speed: speed ?? this.speed,
        ping: ping ?? this.ping,
        speed1: speed1 ?? this.speed1,
        dspeed: dspeed ?? this.dspeed,
        ok: ok ?? this.ok,
        tcpOK: tcpOK ?? this.tcpOK,
        dbCdn: dbCdn.present ? dbCdn.value : this.dbCdn,
        serverIp: serverIp ?? this.serverIp,
        config: config ?? this.config,
        subId: subId.present ? subId.value : this.subId,
      );
  OutboundHandlersData copyWithCompanion(OutboundHandlersCompanion data) {
    return OutboundHandlersData(
      id: data.id.present ? data.id.value : this.id,
      selected: data.selected.present ? data.selected.value : this.selected,
      enabled: data.enabled.present ? data.enabled.value : this.enabled,
      countryCode:
          data.countryCode.present ? data.countryCode.value : this.countryCode,
      sni: data.sni.present ? data.sni.value : this.sni,
      speed: data.speed.present ? data.speed.value : this.speed,
      ping: data.ping.present ? data.ping.value : this.ping,
      speed1: data.speed1.present ? data.speed1.value : this.speed1,
      dspeed: data.dspeed.present ? data.dspeed.value : this.dspeed,
      ok: data.ok.present ? data.ok.value : this.ok,
      tcpOK: data.tcpOK.present ? data.tcpOK.value : this.tcpOK,
      dbCdn: data.dbCdn.present ? data.dbCdn.value : this.dbCdn,
      serverIp: data.serverIp.present ? data.serverIp.value : this.serverIp,
      config: data.config.present ? data.config.value : this.config,
      subId: data.subId.present ? data.subId.value : this.subId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OutboundHandlersData(')
          ..write('id: $id, ')
          ..write('selected: $selected, ')
          ..write('enabled: $enabled, ')
          ..write('countryCode: $countryCode, ')
          ..write('sni: $sni, ')
          ..write('speed: $speed, ')
          ..write('ping: $ping, ')
          ..write('speed1: $speed1, ')
          ..write('dspeed: $dspeed, ')
          ..write('ok: $ok, ')
          ..write('tcpOK: $tcpOK, ')
          ..write('dbCdn: $dbCdn, ')
          ..write('serverIp: $serverIp, ')
          ..write('config: $config, ')
          ..write('subId: $subId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      selected,
      enabled,
      countryCode,
      sni,
      speed,
      ping,
      speed1,
      dspeed,
      ok,
      tcpOK,
      dbCdn,
      serverIp,
      $driftBlobEquality.hash(config),
      subId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OutboundHandlersData &&
          other.id == this.id &&
          other.selected == this.selected &&
          other.enabled == this.enabled &&
          other.countryCode == this.countryCode &&
          other.sni == this.sni &&
          other.speed == this.speed &&
          other.ping == this.ping &&
          other.speed1 == this.speed1 &&
          other.dspeed == this.dspeed &&
          other.ok == this.ok &&
          other.tcpOK == this.tcpOK &&
          other.dbCdn == this.dbCdn &&
          other.serverIp == this.serverIp &&
          $driftBlobEquality.equals(other.config, this.config) &&
          other.subId == this.subId);
}

class OutboundHandlersCompanion extends UpdateCompanion<OutboundHandlersData> {
  final Value<int> id;
  final Value<bool> selected;
  final Value<bool> enabled;
  final Value<String> countryCode;
  final Value<String> sni;
  final Value<double> speed;
  final Value<int> ping;
  final Value<double> speed1;
  final Value<double> dspeed;
  final Value<int> ok;
  final Value<int> tcpOK;
  final Value<int?> dbCdn;
  final Value<String> serverIp;
  final Value<Uint8List> config;
  final Value<int?> subId;
  const OutboundHandlersCompanion({
    this.id = const Value.absent(),
    this.selected = const Value.absent(),
    this.enabled = const Value.absent(),
    this.countryCode = const Value.absent(),
    this.sni = const Value.absent(),
    this.speed = const Value.absent(),
    this.ping = const Value.absent(),
    this.speed1 = const Value.absent(),
    this.dspeed = const Value.absent(),
    this.ok = const Value.absent(),
    this.tcpOK = const Value.absent(),
    this.dbCdn = const Value.absent(),
    this.serverIp = const Value.absent(),
    this.config = const Value.absent(),
    this.subId = const Value.absent(),
  });
  OutboundHandlersCompanion.insert({
    this.id = const Value.absent(),
    required bool selected,
    required bool enabled,
    required String countryCode,
    required String sni,
    this.speed = const Value.absent(),
    this.ping = const Value.absent(),
    this.speed1 = const Value.absent(),
    this.dspeed = const Value.absent(),
    this.ok = const Value.absent(),
    this.tcpOK = const Value.absent(),
    this.dbCdn = const Value.absent(),
    required String serverIp,
    required Uint8List config,
    this.subId = const Value.absent(),
  })  : selected = Value(selected),
        enabled = Value(enabled),
        countryCode = Value(countryCode),
        sni = Value(sni),
        serverIp = Value(serverIp),
        config = Value(config);
  static Insertable<OutboundHandlersData> custom({
    Expression<int>? id,
    Expression<bool>? selected,
    Expression<bool>? enabled,
    Expression<String>? countryCode,
    Expression<String>? sni,
    Expression<double>? speed,
    Expression<int>? ping,
    Expression<double>? speed1,
    Expression<double>? dspeed,
    Expression<int>? ok,
    Expression<int>? tcpOK,
    Expression<int>? dbCdn,
    Expression<String>? serverIp,
    Expression<Uint8List>? config,
    Expression<int>? subId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (selected != null) 'selected': selected,
      if (enabled != null) 'enabled': enabled,
      if (countryCode != null) 'country_code': countryCode,
      if (sni != null) 'sni': sni,
      if (speed != null) 'speed': speed,
      if (ping != null) 'ping': ping,
      if (speed1 != null) 'speed1': speed1,
      if (dspeed != null) 'dspeed': dspeed,
      if (ok != null) 'ok': ok,
      if (tcpOK != null) 'tcp_o_k': tcpOK,
      if (dbCdn != null) 'db_cdn': dbCdn,
      if (serverIp != null) 'server_ip': serverIp,
      if (config != null) 'config': config,
      if (subId != null) 'sub_id': subId,
    });
  }

  OutboundHandlersCompanion copyWith(
      {Value<int>? id,
      Value<bool>? selected,
      Value<bool>? enabled,
      Value<String>? countryCode,
      Value<String>? sni,
      Value<double>? speed,
      Value<int>? ping,
      Value<double>? speed1,
      Value<double>? dspeed,
      Value<int>? ok,
      Value<int>? tcpOK,
      Value<int?>? dbCdn,
      Value<String>? serverIp,
      Value<Uint8List>? config,
      Value<int?>? subId}) {
    return OutboundHandlersCompanion(
      id: id ?? this.id,
      selected: selected ?? this.selected,
      enabled: enabled ?? this.enabled,
      countryCode: countryCode ?? this.countryCode,
      sni: sni ?? this.sni,
      speed: speed ?? this.speed,
      ping: ping ?? this.ping,
      speed1: speed1 ?? this.speed1,
      dspeed: dspeed ?? this.dspeed,
      ok: ok ?? this.ok,
      tcpOK: tcpOK ?? this.tcpOK,
      dbCdn: dbCdn ?? this.dbCdn,
      serverIp: serverIp ?? this.serverIp,
      config: config ?? this.config,
      subId: subId ?? this.subId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (selected.present) {
      map['selected'] = Variable<bool>(selected.value);
    }
    if (enabled.present) {
      map['enabled'] = Variable<bool>(enabled.value);
    }
    if (countryCode.present) {
      map['country_code'] = Variable<String>(countryCode.value);
    }
    if (sni.present) {
      map['sni'] = Variable<String>(sni.value);
    }
    if (speed.present) {
      map['speed'] = Variable<double>(speed.value);
    }
    if (ping.present) {
      map['ping'] = Variable<int>(ping.value);
    }
    if (speed1.present) {
      map['speed1'] = Variable<double>(speed1.value);
    }
    if (dspeed.present) {
      map['dspeed'] = Variable<double>(dspeed.value);
    }
    if (ok.present) {
      map['ok'] = Variable<int>(ok.value);
    }
    if (tcpOK.present) {
      map['tcp_o_k'] = Variable<int>(tcpOK.value);
    }
    if (dbCdn.present) {
      map['db_cdn'] = Variable<int>(dbCdn.value);
    }
    if (serverIp.present) {
      map['server_ip'] = Variable<String>(serverIp.value);
    }
    if (config.present) {
      map['config'] = Variable<Uint8List>(config.value);
    }
    if (subId.present) {
      map['sub_id'] = Variable<int>(subId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OutboundHandlersCompanion(')
          ..write('id: $id, ')
          ..write('selected: $selected, ')
          ..write('enabled: $enabled, ')
          ..write('countryCode: $countryCode, ')
          ..write('sni: $sni, ')
          ..write('speed: $speed, ')
          ..write('ping: $ping, ')
          ..write('speed1: $speed1, ')
          ..write('dspeed: $dspeed, ')
          ..write('ok: $ok, ')
          ..write('tcpOK: $tcpOK, ')
          ..write('dbCdn: $dbCdn, ')
          ..write('serverIp: $serverIp, ')
          ..write('config: $config, ')
          ..write('subId: $subId')
          ..write(')'))
        .toString();
  }
}

class DnsRecords extends Table with TableInfo<DnsRecords, DnsRecordsData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  DnsRecords(this.attachedDatabase, [this._alias]);
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  late final GeneratedColumn<Uint8List> dnsRecord = GeneratedColumn<Uint8List>(
      'dns_record', aliasedName, false,
      type: DriftSqlType.blob, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, dnsRecord];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'dns_records';
  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DnsRecordsData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DnsRecordsData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      dnsRecord: attachedDatabase.typeMapping
          .read(DriftSqlType.blob, data['${effectivePrefix}dns_record'])!,
    );
  }

  @override
  DnsRecords createAlias(String alias) {
    return DnsRecords(attachedDatabase, alias);
  }
}

class DnsRecordsData extends DataClass implements Insertable<DnsRecordsData> {
  final int id;
  final Uint8List dnsRecord;
  const DnsRecordsData({required this.id, required this.dnsRecord});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['dns_record'] = Variable<Uint8List>(dnsRecord);
    return map;
  }

  DnsRecordsCompanion toCompanion(bool nullToAbsent) {
    return DnsRecordsCompanion(
      id: Value(id),
      dnsRecord: Value(dnsRecord),
    );
  }

  factory DnsRecordsData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DnsRecordsData(
      id: serializer.fromJson<int>(json['id']),
      dnsRecord: serializer.fromJson<Uint8List>(json['dnsRecord']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'dnsRecord': serializer.toJson<Uint8List>(dnsRecord),
    };
  }

  DnsRecordsData copyWith({int? id, Uint8List? dnsRecord}) => DnsRecordsData(
        id: id ?? this.id,
        dnsRecord: dnsRecord ?? this.dnsRecord,
      );
  DnsRecordsData copyWithCompanion(DnsRecordsCompanion data) {
    return DnsRecordsData(
      id: data.id.present ? data.id.value : this.id,
      dnsRecord: data.dnsRecord.present ? data.dnsRecord.value : this.dnsRecord,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DnsRecordsData(')
          ..write('id: $id, ')
          ..write('dnsRecord: $dnsRecord')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, $driftBlobEquality.hash(dnsRecord));
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DnsRecordsData &&
          other.id == this.id &&
          $driftBlobEquality.equals(other.dnsRecord, this.dnsRecord));
}

class DnsRecordsCompanion extends UpdateCompanion<DnsRecordsData> {
  final Value<int> id;
  final Value<Uint8List> dnsRecord;
  const DnsRecordsCompanion({
    this.id = const Value.absent(),
    this.dnsRecord = const Value.absent(),
  });
  DnsRecordsCompanion.insert({
    this.id = const Value.absent(),
    required Uint8List dnsRecord,
  }) : dnsRecord = Value(dnsRecord);
  static Insertable<DnsRecordsData> custom({
    Expression<int>? id,
    Expression<Uint8List>? dnsRecord,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (dnsRecord != null) 'dns_record': dnsRecord,
    });
  }

  DnsRecordsCompanion copyWith({Value<int>? id, Value<Uint8List>? dnsRecord}) {
    return DnsRecordsCompanion(
      id: id ?? this.id,
      dnsRecord: dnsRecord ?? this.dnsRecord,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (dnsRecord.present) {
      map['dns_record'] = Variable<Uint8List>(dnsRecord.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DnsRecordsCompanion(')
          ..write('id: $id, ')
          ..write('dnsRecord: $dnsRecord')
          ..write(')'))
        .toString();
  }
}

class GeoDomains extends Table with TableInfo<GeoDomains, GeoDomainsData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  GeoDomains(this.attachedDatabase, [this._alias]);
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  late final GeneratedColumn<bool> goProxy = GeneratedColumn<bool>(
      'go_proxy', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("go_proxy" IN (0, 1))'));
  late final GeneratedColumn<Uint8List> geoDomain = GeneratedColumn<Uint8List>(
      'geo_domain', aliasedName, false,
      type: DriftSqlType.blob, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, goProxy, geoDomain];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'geo_domains';
  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
        {geoDomain},
      ];
  @override
  GeoDomainsData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GeoDomainsData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      goProxy: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}go_proxy'])!,
      geoDomain: attachedDatabase.typeMapping
          .read(DriftSqlType.blob, data['${effectivePrefix}geo_domain'])!,
    );
  }

  @override
  GeoDomains createAlias(String alias) {
    return GeoDomains(attachedDatabase, alias);
  }
}

class GeoDomainsData extends DataClass implements Insertable<GeoDomainsData> {
  final int id;
  final bool goProxy;
  final Uint8List geoDomain;
  const GeoDomainsData(
      {required this.id, required this.goProxy, required this.geoDomain});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['go_proxy'] = Variable<bool>(goProxy);
    map['geo_domain'] = Variable<Uint8List>(geoDomain);
    return map;
  }

  GeoDomainsCompanion toCompanion(bool nullToAbsent) {
    return GeoDomainsCompanion(
      id: Value(id),
      goProxy: Value(goProxy),
      geoDomain: Value(geoDomain),
    );
  }

  factory GeoDomainsData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GeoDomainsData(
      id: serializer.fromJson<int>(json['id']),
      goProxy: serializer.fromJson<bool>(json['goProxy']),
      geoDomain: serializer.fromJson<Uint8List>(json['geoDomain']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'goProxy': serializer.toJson<bool>(goProxy),
      'geoDomain': serializer.toJson<Uint8List>(geoDomain),
    };
  }

  GeoDomainsData copyWith({int? id, bool? goProxy, Uint8List? geoDomain}) =>
      GeoDomainsData(
        id: id ?? this.id,
        goProxy: goProxy ?? this.goProxy,
        geoDomain: geoDomain ?? this.geoDomain,
      );
  GeoDomainsData copyWithCompanion(GeoDomainsCompanion data) {
    return GeoDomainsData(
      id: data.id.present ? data.id.value : this.id,
      goProxy: data.goProxy.present ? data.goProxy.value : this.goProxy,
      geoDomain: data.geoDomain.present ? data.geoDomain.value : this.geoDomain,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GeoDomainsData(')
          ..write('id: $id, ')
          ..write('goProxy: $goProxy, ')
          ..write('geoDomain: $geoDomain')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, goProxy, $driftBlobEquality.hash(geoDomain));
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GeoDomainsData &&
          other.id == this.id &&
          other.goProxy == this.goProxy &&
          $driftBlobEquality.equals(other.geoDomain, this.geoDomain));
}

class GeoDomainsCompanion extends UpdateCompanion<GeoDomainsData> {
  final Value<int> id;
  final Value<bool> goProxy;
  final Value<Uint8List> geoDomain;
  const GeoDomainsCompanion({
    this.id = const Value.absent(),
    this.goProxy = const Value.absent(),
    this.geoDomain = const Value.absent(),
  });
  GeoDomainsCompanion.insert({
    this.id = const Value.absent(),
    required bool goProxy,
    required Uint8List geoDomain,
  })  : goProxy = Value(goProxy),
        geoDomain = Value(geoDomain);
  static Insertable<GeoDomainsData> custom({
    Expression<int>? id,
    Expression<bool>? goProxy,
    Expression<Uint8List>? geoDomain,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (goProxy != null) 'go_proxy': goProxy,
      if (geoDomain != null) 'geo_domain': geoDomain,
    });
  }

  GeoDomainsCompanion copyWith(
      {Value<int>? id, Value<bool>? goProxy, Value<Uint8List>? geoDomain}) {
    return GeoDomainsCompanion(
      id: id ?? this.id,
      goProxy: goProxy ?? this.goProxy,
      geoDomain: geoDomain ?? this.geoDomain,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (goProxy.present) {
      map['go_proxy'] = Variable<bool>(goProxy.value);
    }
    if (geoDomain.present) {
      map['geo_domain'] = Variable<Uint8List>(geoDomain.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GeoDomainsCompanion(')
          ..write('id: $id, ')
          ..write('goProxy: $goProxy, ')
          ..write('geoDomain: $geoDomain')
          ..write(')'))
        .toString();
  }
}

class Apps extends Table with TableInfo<Apps, AppsData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Apps(this.attachedDatabase, [this._alias]);
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  late final GeneratedColumn<bool> proxy = GeneratedColumn<bool>(
      'proxy', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("proxy" IN (0, 1))'));
  late final GeneratedColumn<Uint8List> appId = GeneratedColumn<Uint8List>(
      'app_id', aliasedName, false,
      type: DriftSqlType.blob, requiredDuringInsert: true);
  late final GeneratedColumn<Uint8List> icon = GeneratedColumn<Uint8List>(
      'icon', aliasedName, true,
      type: DriftSqlType.blob, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [id, proxy, appId, icon];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'apps';
  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
        {appId},
      ];
  @override
  AppsData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppsData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      proxy: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}proxy'])!,
      appId: attachedDatabase.typeMapping
          .read(DriftSqlType.blob, data['${effectivePrefix}app_id'])!,
      icon: attachedDatabase.typeMapping
          .read(DriftSqlType.blob, data['${effectivePrefix}icon']),
    );
  }

  @override
  Apps createAlias(String alias) {
    return Apps(attachedDatabase, alias);
  }
}

class AppsData extends DataClass implements Insertable<AppsData> {
  final int id;
  final bool proxy;
  final Uint8List appId;
  final Uint8List? icon;
  const AppsData(
      {required this.id, required this.proxy, required this.appId, this.icon});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['proxy'] = Variable<bool>(proxy);
    map['app_id'] = Variable<Uint8List>(appId);
    if (!nullToAbsent || icon != null) {
      map['icon'] = Variable<Uint8List>(icon);
    }
    return map;
  }

  AppsCompanion toCompanion(bool nullToAbsent) {
    return AppsCompanion(
      id: Value(id),
      proxy: Value(proxy),
      appId: Value(appId),
      icon: icon == null && nullToAbsent ? const Value.absent() : Value(icon),
    );
  }

  factory AppsData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppsData(
      id: serializer.fromJson<int>(json['id']),
      proxy: serializer.fromJson<bool>(json['proxy']),
      appId: serializer.fromJson<Uint8List>(json['appId']),
      icon: serializer.fromJson<Uint8List?>(json['icon']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'proxy': serializer.toJson<bool>(proxy),
      'appId': serializer.toJson<Uint8List>(appId),
      'icon': serializer.toJson<Uint8List?>(icon),
    };
  }

  AppsData copyWith(
          {int? id,
          bool? proxy,
          Uint8List? appId,
          Value<Uint8List?> icon = const Value.absent()}) =>
      AppsData(
        id: id ?? this.id,
        proxy: proxy ?? this.proxy,
        appId: appId ?? this.appId,
        icon: icon.present ? icon.value : this.icon,
      );
  AppsData copyWithCompanion(AppsCompanion data) {
    return AppsData(
      id: data.id.present ? data.id.value : this.id,
      proxy: data.proxy.present ? data.proxy.value : this.proxy,
      appId: data.appId.present ? data.appId.value : this.appId,
      icon: data.icon.present ? data.icon.value : this.icon,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppsData(')
          ..write('id: $id, ')
          ..write('proxy: $proxy, ')
          ..write('appId: $appId, ')
          ..write('icon: $icon')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, proxy, $driftBlobEquality.hash(appId), $driftBlobEquality.hash(icon));
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppsData &&
          other.id == this.id &&
          other.proxy == this.proxy &&
          $driftBlobEquality.equals(other.appId, this.appId) &&
          $driftBlobEquality.equals(other.icon, this.icon));
}

class AppsCompanion extends UpdateCompanion<AppsData> {
  final Value<int> id;
  final Value<bool> proxy;
  final Value<Uint8List> appId;
  final Value<Uint8List?> icon;
  const AppsCompanion({
    this.id = const Value.absent(),
    this.proxy = const Value.absent(),
    this.appId = const Value.absent(),
    this.icon = const Value.absent(),
  });
  AppsCompanion.insert({
    this.id = const Value.absent(),
    required bool proxy,
    required Uint8List appId,
    this.icon = const Value.absent(),
  })  : proxy = Value(proxy),
        appId = Value(appId);
  static Insertable<AppsData> custom({
    Expression<int>? id,
    Expression<bool>? proxy,
    Expression<Uint8List>? appId,
    Expression<Uint8List>? icon,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (proxy != null) 'proxy': proxy,
      if (appId != null) 'app_id': appId,
      if (icon != null) 'icon': icon,
    });
  }

  AppsCompanion copyWith(
      {Value<int>? id,
      Value<bool>? proxy,
      Value<Uint8List>? appId,
      Value<Uint8List?>? icon}) {
    return AppsCompanion(
      id: id ?? this.id,
      proxy: proxy ?? this.proxy,
      appId: appId ?? this.appId,
      icon: icon ?? this.icon,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (proxy.present) {
      map['proxy'] = Variable<bool>(proxy.value);
    }
    if (appId.present) {
      map['app_id'] = Variable<Uint8List>(appId.value);
    }
    if (icon.present) {
      map['icon'] = Variable<Uint8List>(icon.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppsCompanion(')
          ..write('id: $id, ')
          ..write('proxy: $proxy, ')
          ..write('appId: $appId, ')
          ..write('icon: $icon')
          ..write(')'))
        .toString();
  }
}

class Cidrs extends Table with TableInfo<Cidrs, CidrsData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Cidrs(this.attachedDatabase, [this._alias]);
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  late final GeneratedColumn<bool> proxy = GeneratedColumn<bool>(
      'proxy', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("proxy" IN (0, 1))'));
  late final GeneratedColumn<Uint8List> cidr = GeneratedColumn<Uint8List>(
      'cidr', aliasedName, false,
      type: DriftSqlType.blob, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, proxy, cidr];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cidrs';
  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
        {cidr},
      ];
  @override
  CidrsData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CidrsData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      proxy: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}proxy'])!,
      cidr: attachedDatabase.typeMapping
          .read(DriftSqlType.blob, data['${effectivePrefix}cidr'])!,
    );
  }

  @override
  Cidrs createAlias(String alias) {
    return Cidrs(attachedDatabase, alias);
  }
}

class CidrsData extends DataClass implements Insertable<CidrsData> {
  final int id;
  final bool proxy;
  final Uint8List cidr;
  const CidrsData({required this.id, required this.proxy, required this.cidr});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['proxy'] = Variable<bool>(proxy);
    map['cidr'] = Variable<Uint8List>(cidr);
    return map;
  }

  CidrsCompanion toCompanion(bool nullToAbsent) {
    return CidrsCompanion(
      id: Value(id),
      proxy: Value(proxy),
      cidr: Value(cidr),
    );
  }

  factory CidrsData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CidrsData(
      id: serializer.fromJson<int>(json['id']),
      proxy: serializer.fromJson<bool>(json['proxy']),
      cidr: serializer.fromJson<Uint8List>(json['cidr']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'proxy': serializer.toJson<bool>(proxy),
      'cidr': serializer.toJson<Uint8List>(cidr),
    };
  }

  CidrsData copyWith({int? id, bool? proxy, Uint8List? cidr}) => CidrsData(
        id: id ?? this.id,
        proxy: proxy ?? this.proxy,
        cidr: cidr ?? this.cidr,
      );
  CidrsData copyWithCompanion(CidrsCompanion data) {
    return CidrsData(
      id: data.id.present ? data.id.value : this.id,
      proxy: data.proxy.present ? data.proxy.value : this.proxy,
      cidr: data.cidr.present ? data.cidr.value : this.cidr,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CidrsData(')
          ..write('id: $id, ')
          ..write('proxy: $proxy, ')
          ..write('cidr: $cidr')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, proxy, $driftBlobEquality.hash(cidr));
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CidrsData &&
          other.id == this.id &&
          other.proxy == this.proxy &&
          $driftBlobEquality.equals(other.cidr, this.cidr));
}

class CidrsCompanion extends UpdateCompanion<CidrsData> {
  final Value<int> id;
  final Value<bool> proxy;
  final Value<Uint8List> cidr;
  const CidrsCompanion({
    this.id = const Value.absent(),
    this.proxy = const Value.absent(),
    this.cidr = const Value.absent(),
  });
  CidrsCompanion.insert({
    this.id = const Value.absent(),
    required bool proxy,
    required Uint8List cidr,
  })  : proxy = Value(proxy),
        cidr = Value(cidr);
  static Insertable<CidrsData> custom({
    Expression<int>? id,
    Expression<bool>? proxy,
    Expression<Uint8List>? cidr,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (proxy != null) 'proxy': proxy,
      if (cidr != null) 'cidr': cidr,
    });
  }

  CidrsCompanion copyWith(
      {Value<int>? id, Value<bool>? proxy, Value<Uint8List>? cidr}) {
    return CidrsCompanion(
      id: id ?? this.id,
      proxy: proxy ?? this.proxy,
      cidr: cidr ?? this.cidr,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (proxy.present) {
      map['proxy'] = Variable<bool>(proxy.value);
    }
    if (cidr.present) {
      map['cidr'] = Variable<Uint8List>(cidr.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CidrsCompanion(')
          ..write('id: $id, ')
          ..write('proxy: $proxy, ')
          ..write('cidr: $cidr')
          ..write(')'))
        .toString();
  }
}

class SshServers extends Table with TableInfo<SshServers, SshServersData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  SshServers(this.attachedDatabase, [this._alias]);
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
      'address', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  late final GeneratedColumn<String> storageKey = GeneratedColumn<String>(
      'storage_key', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  late final GeneratedColumn<String> country = GeneratedColumn<String>(
      'country', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  late final GeneratedColumn<int> authMethod = GeneratedColumn<int>(
      'auth_method', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, name, address, storageKey, country, authMethod];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ssh_servers';
  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SshServersData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SshServersData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      address: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}address'])!,
      storageKey: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}storage_key'])!,
      country: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}country']),
      authMethod: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}auth_method'])!,
    );
  }

  @override
  SshServers createAlias(String alias) {
    return SshServers(attachedDatabase, alias);
  }
}

class SshServersData extends DataClass implements Insertable<SshServersData> {
  final int id;
  final String name;
  final String address;
  final String storageKey;
  final String? country;
  final int authMethod;
  const SshServersData(
      {required this.id,
      required this.name,
      required this.address,
      required this.storageKey,
      this.country,
      required this.authMethod});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['address'] = Variable<String>(address);
    map['storage_key'] = Variable<String>(storageKey);
    if (!nullToAbsent || country != null) {
      map['country'] = Variable<String>(country);
    }
    map['auth_method'] = Variable<int>(authMethod);
    return map;
  }

  SshServersCompanion toCompanion(bool nullToAbsent) {
    return SshServersCompanion(
      id: Value(id),
      name: Value(name),
      address: Value(address),
      storageKey: Value(storageKey),
      country: country == null && nullToAbsent
          ? const Value.absent()
          : Value(country),
      authMethod: Value(authMethod),
    );
  }

  factory SshServersData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SshServersData(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      address: serializer.fromJson<String>(json['address']),
      storageKey: serializer.fromJson<String>(json['storageKey']),
      country: serializer.fromJson<String?>(json['country']),
      authMethod: serializer.fromJson<int>(json['authMethod']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'address': serializer.toJson<String>(address),
      'storageKey': serializer.toJson<String>(storageKey),
      'country': serializer.toJson<String?>(country),
      'authMethod': serializer.toJson<int>(authMethod),
    };
  }

  SshServersData copyWith(
          {int? id,
          String? name,
          String? address,
          String? storageKey,
          Value<String?> country = const Value.absent(),
          int? authMethod}) =>
      SshServersData(
        id: id ?? this.id,
        name: name ?? this.name,
        address: address ?? this.address,
        storageKey: storageKey ?? this.storageKey,
        country: country.present ? country.value : this.country,
        authMethod: authMethod ?? this.authMethod,
      );
  SshServersData copyWithCompanion(SshServersCompanion data) {
    return SshServersData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      address: data.address.present ? data.address.value : this.address,
      storageKey:
          data.storageKey.present ? data.storageKey.value : this.storageKey,
      country: data.country.present ? data.country.value : this.country,
      authMethod:
          data.authMethod.present ? data.authMethod.value : this.authMethod,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SshServersData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('address: $address, ')
          ..write('storageKey: $storageKey, ')
          ..write('country: $country, ')
          ..write('authMethod: $authMethod')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, address, storageKey, country, authMethod);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SshServersData &&
          other.id == this.id &&
          other.name == this.name &&
          other.address == this.address &&
          other.storageKey == this.storageKey &&
          other.country == this.country &&
          other.authMethod == this.authMethod);
}

class SshServersCompanion extends UpdateCompanion<SshServersData> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> address;
  final Value<String> storageKey;
  final Value<String?> country;
  final Value<int> authMethod;
  const SshServersCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.address = const Value.absent(),
    this.storageKey = const Value.absent(),
    this.country = const Value.absent(),
    this.authMethod = const Value.absent(),
  });
  SshServersCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String address,
    required String storageKey,
    this.country = const Value.absent(),
    required int authMethod,
  })  : name = Value(name),
        address = Value(address),
        storageKey = Value(storageKey),
        authMethod = Value(authMethod);
  static Insertable<SshServersData> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? address,
    Expression<String>? storageKey,
    Expression<String>? country,
    Expression<int>? authMethod,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (address != null) 'address': address,
      if (storageKey != null) 'storage_key': storageKey,
      if (country != null) 'country': country,
      if (authMethod != null) 'auth_method': authMethod,
    });
  }

  SshServersCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<String>? address,
      Value<String>? storageKey,
      Value<String?>? country,
      Value<int>? authMethod}) {
    return SshServersCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      storageKey: storageKey ?? this.storageKey,
      country: country ?? this.country,
      authMethod: authMethod ?? this.authMethod,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (storageKey.present) {
      map['storage_key'] = Variable<String>(storageKey.value);
    }
    if (country.present) {
      map['country'] = Variable<String>(country.value);
    }
    if (authMethod.present) {
      map['auth_method'] = Variable<int>(authMethod.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SshServersCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('address: $address, ')
          ..write('storageKey: $storageKey, ')
          ..write('country: $country, ')
          ..write('authMethod: $authMethod')
          ..write(')'))
        .toString();
  }
}

class CommonSshKeys extends Table
    with TableInfo<CommonSshKeys, CommonSshKeysData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  CommonSshKeys(this.attachedDatabase, [this._alias]);
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  late final GeneratedColumn<String> remark = GeneratedColumn<String>(
      'remark', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [id, name, remark];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'common_ssh_keys';
  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CommonSshKeysData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CommonSshKeysData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      remark: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}remark']),
    );
  }

  @override
  CommonSshKeys createAlias(String alias) {
    return CommonSshKeys(attachedDatabase, alias);
  }
}

class CommonSshKeysData extends DataClass
    implements Insertable<CommonSshKeysData> {
  final int id;
  final String name;
  final String? remark;
  const CommonSshKeysData({required this.id, required this.name, this.remark});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || remark != null) {
      map['remark'] = Variable<String>(remark);
    }
    return map;
  }

  CommonSshKeysCompanion toCompanion(bool nullToAbsent) {
    return CommonSshKeysCompanion(
      id: Value(id),
      name: Value(name),
      remark:
          remark == null && nullToAbsent ? const Value.absent() : Value(remark),
    );
  }

  factory CommonSshKeysData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CommonSshKeysData(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      remark: serializer.fromJson<String?>(json['remark']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'remark': serializer.toJson<String?>(remark),
    };
  }

  CommonSshKeysData copyWith(
          {int? id,
          String? name,
          Value<String?> remark = const Value.absent()}) =>
      CommonSshKeysData(
        id: id ?? this.id,
        name: name ?? this.name,
        remark: remark.present ? remark.value : this.remark,
      );
  CommonSshKeysData copyWithCompanion(CommonSshKeysCompanion data) {
    return CommonSshKeysData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      remark: data.remark.present ? data.remark.value : this.remark,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CommonSshKeysData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('remark: $remark')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, remark);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CommonSshKeysData &&
          other.id == this.id &&
          other.name == this.name &&
          other.remark == this.remark);
}

class CommonSshKeysCompanion extends UpdateCompanion<CommonSshKeysData> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> remark;
  const CommonSshKeysCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.remark = const Value.absent(),
  });
  CommonSshKeysCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.remark = const Value.absent(),
  }) : name = Value(name);
  static Insertable<CommonSshKeysData> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? remark,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (remark != null) 'remark': remark,
    });
  }

  CommonSshKeysCompanion copyWith(
      {Value<int>? id, Value<String>? name, Value<String?>? remark}) {
    return CommonSshKeysCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      remark: remark ?? this.remark,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (remark.present) {
      map['remark'] = Variable<String>(remark.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CommonSshKeysCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('remark: $remark')
          ..write(')'))
        .toString();
  }
}

class DatabaseAtV2 extends GeneratedDatabase {
  DatabaseAtV2(QueryExecutor e) : super(e);
  late final Subscriptions subscriptions = Subscriptions(this);
  late final OutboundHandlers outboundHandlers = OutboundHandlers(this);
  late final DnsRecords dnsRecords = DnsRecords(this);
  late final GeoDomains geoDomains = GeoDomains(this);
  late final Apps apps = Apps(this);
  late final Cidrs cidrs = Cidrs(this);
  late final SshServers sshServers = SshServers(this);
  late final CommonSshKeys commonSshKeys = CommonSshKeys(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        subscriptions,
        outboundHandlers,
        dnsRecords,
        geoDomains,
        apps,
        cidrs,
        sshServers,
        commonSshKeys
      ];
  @override
  int get schemaVersion => 2;
}
