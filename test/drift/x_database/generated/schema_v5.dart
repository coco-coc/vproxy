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
        lastSuccessUpdate
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
  const SubscriptionsData(
      {required this.id,
      required this.name,
      required this.link,
      this.remainingData,
      this.endTime,
      required this.website,
      required this.description,
      required this.lastUpdate,
      required this.lastSuccessUpdate});
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
          int? lastSuccessUpdate}) =>
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
          ..write('lastSuccessUpdate: $lastSuccessUpdate')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, link, remainingData, endTime,
      website, description, lastUpdate, lastSuccessUpdate);
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
          other.lastSuccessUpdate == this.lastSuccessUpdate);
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
      Value<int>? lastSuccessUpdate}) {
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
          ..write('lastSuccessUpdate: $lastSuccessUpdate')
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
  late final GeneratedColumn<int> speedTestTime = GeneratedColumn<int>(
      'speed_test_time', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const CustomExpression('0'));
  late final GeneratedColumn<int> ping = GeneratedColumn<int>(
      'ping', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const CustomExpression('0'));
  late final GeneratedColumn<int> pingTestTime = GeneratedColumn<int>(
      'ping_test_time', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const CustomExpression('0'));
  late final GeneratedColumn<int> ok = GeneratedColumn<int>(
      'ok', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const CustomExpression('0'));
  late final GeneratedColumn<String> serverIp = GeneratedColumn<String>(
      'server_ip', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  late final GeneratedColumn<Uint8List> config = GeneratedColumn<Uint8List>(
      'config', aliasedName, false,
      type: DriftSqlType.blob, requiredDuringInsert: true);
  late final GeneratedColumn<int> support6 = GeneratedColumn<int>(
      'support6', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const CustomExpression('0'));
  late final GeneratedColumn<int> support6TestTime = GeneratedColumn<int>(
      'support6_test_time', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const CustomExpression('0'));
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
        countryCode,
        sni,
        speed,
        speedTestTime,
        ping,
        pingTestTime,
        ok,
        serverIp,
        config,
        support6,
        support6TestTime,
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
      countryCode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}country_code'])!,
      sni: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sni'])!,
      speed: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}speed'])!,
      speedTestTime: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}speed_test_time'])!,
      ping: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}ping'])!,
      pingTestTime: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}ping_test_time'])!,
      ok: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}ok'])!,
      serverIp: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}server_ip'])!,
      config: attachedDatabase.typeMapping
          .read(DriftSqlType.blob, data['${effectivePrefix}config'])!,
      support6: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}support6'])!,
      support6TestTime: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}support6_test_time'])!,
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
  final String countryCode;
  final String sni;
  final double speed;
  final int speedTestTime;
  final int ping;
  final int pingTestTime;
  final int ok;
  final String serverIp;
  final Uint8List config;
  final int support6;
  final int support6TestTime;
  final int? subId;
  const OutboundHandlersData(
      {required this.id,
      required this.selected,
      required this.countryCode,
      required this.sni,
      required this.speed,
      required this.speedTestTime,
      required this.ping,
      required this.pingTestTime,
      required this.ok,
      required this.serverIp,
      required this.config,
      required this.support6,
      required this.support6TestTime,
      this.subId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['selected'] = Variable<bool>(selected);
    map['country_code'] = Variable<String>(countryCode);
    map['sni'] = Variable<String>(sni);
    map['speed'] = Variable<double>(speed);
    map['speed_test_time'] = Variable<int>(speedTestTime);
    map['ping'] = Variable<int>(ping);
    map['ping_test_time'] = Variable<int>(pingTestTime);
    map['ok'] = Variable<int>(ok);
    map['server_ip'] = Variable<String>(serverIp);
    map['config'] = Variable<Uint8List>(config);
    map['support6'] = Variable<int>(support6);
    map['support6_test_time'] = Variable<int>(support6TestTime);
    if (!nullToAbsent || subId != null) {
      map['sub_id'] = Variable<int>(subId);
    }
    return map;
  }

  OutboundHandlersCompanion toCompanion(bool nullToAbsent) {
    return OutboundHandlersCompanion(
      id: Value(id),
      selected: Value(selected),
      countryCode: Value(countryCode),
      sni: Value(sni),
      speed: Value(speed),
      speedTestTime: Value(speedTestTime),
      ping: Value(ping),
      pingTestTime: Value(pingTestTime),
      ok: Value(ok),
      serverIp: Value(serverIp),
      config: Value(config),
      support6: Value(support6),
      support6TestTime: Value(support6TestTime),
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
      countryCode: serializer.fromJson<String>(json['countryCode']),
      sni: serializer.fromJson<String>(json['sni']),
      speed: serializer.fromJson<double>(json['speed']),
      speedTestTime: serializer.fromJson<int>(json['speedTestTime']),
      ping: serializer.fromJson<int>(json['ping']),
      pingTestTime: serializer.fromJson<int>(json['pingTestTime']),
      ok: serializer.fromJson<int>(json['ok']),
      serverIp: serializer.fromJson<String>(json['serverIp']),
      config: serializer.fromJson<Uint8List>(json['config']),
      support6: serializer.fromJson<int>(json['support6']),
      support6TestTime: serializer.fromJson<int>(json['support6TestTime']),
      subId: serializer.fromJson<int?>(json['subId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'selected': serializer.toJson<bool>(selected),
      'countryCode': serializer.toJson<String>(countryCode),
      'sni': serializer.toJson<String>(sni),
      'speed': serializer.toJson<double>(speed),
      'speedTestTime': serializer.toJson<int>(speedTestTime),
      'ping': serializer.toJson<int>(ping),
      'pingTestTime': serializer.toJson<int>(pingTestTime),
      'ok': serializer.toJson<int>(ok),
      'serverIp': serializer.toJson<String>(serverIp),
      'config': serializer.toJson<Uint8List>(config),
      'support6': serializer.toJson<int>(support6),
      'support6TestTime': serializer.toJson<int>(support6TestTime),
      'subId': serializer.toJson<int?>(subId),
    };
  }

  OutboundHandlersData copyWith(
          {int? id,
          bool? selected,
          String? countryCode,
          String? sni,
          double? speed,
          int? speedTestTime,
          int? ping,
          int? pingTestTime,
          int? ok,
          String? serverIp,
          Uint8List? config,
          int? support6,
          int? support6TestTime,
          Value<int?> subId = const Value.absent()}) =>
      OutboundHandlersData(
        id: id ?? this.id,
        selected: selected ?? this.selected,
        countryCode: countryCode ?? this.countryCode,
        sni: sni ?? this.sni,
        speed: speed ?? this.speed,
        speedTestTime: speedTestTime ?? this.speedTestTime,
        ping: ping ?? this.ping,
        pingTestTime: pingTestTime ?? this.pingTestTime,
        ok: ok ?? this.ok,
        serverIp: serverIp ?? this.serverIp,
        config: config ?? this.config,
        support6: support6 ?? this.support6,
        support6TestTime: support6TestTime ?? this.support6TestTime,
        subId: subId.present ? subId.value : this.subId,
      );
  OutboundHandlersData copyWithCompanion(OutboundHandlersCompanion data) {
    return OutboundHandlersData(
      id: data.id.present ? data.id.value : this.id,
      selected: data.selected.present ? data.selected.value : this.selected,
      countryCode:
          data.countryCode.present ? data.countryCode.value : this.countryCode,
      sni: data.sni.present ? data.sni.value : this.sni,
      speed: data.speed.present ? data.speed.value : this.speed,
      speedTestTime: data.speedTestTime.present
          ? data.speedTestTime.value
          : this.speedTestTime,
      ping: data.ping.present ? data.ping.value : this.ping,
      pingTestTime: data.pingTestTime.present
          ? data.pingTestTime.value
          : this.pingTestTime,
      ok: data.ok.present ? data.ok.value : this.ok,
      serverIp: data.serverIp.present ? data.serverIp.value : this.serverIp,
      config: data.config.present ? data.config.value : this.config,
      support6: data.support6.present ? data.support6.value : this.support6,
      support6TestTime: data.support6TestTime.present
          ? data.support6TestTime.value
          : this.support6TestTime,
      subId: data.subId.present ? data.subId.value : this.subId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OutboundHandlersData(')
          ..write('id: $id, ')
          ..write('selected: $selected, ')
          ..write('countryCode: $countryCode, ')
          ..write('sni: $sni, ')
          ..write('speed: $speed, ')
          ..write('speedTestTime: $speedTestTime, ')
          ..write('ping: $ping, ')
          ..write('pingTestTime: $pingTestTime, ')
          ..write('ok: $ok, ')
          ..write('serverIp: $serverIp, ')
          ..write('config: $config, ')
          ..write('support6: $support6, ')
          ..write('support6TestTime: $support6TestTime, ')
          ..write('subId: $subId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      selected,
      countryCode,
      sni,
      speed,
      speedTestTime,
      ping,
      pingTestTime,
      ok,
      serverIp,
      $driftBlobEquality.hash(config),
      support6,
      support6TestTime,
      subId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OutboundHandlersData &&
          other.id == this.id &&
          other.selected == this.selected &&
          other.countryCode == this.countryCode &&
          other.sni == this.sni &&
          other.speed == this.speed &&
          other.speedTestTime == this.speedTestTime &&
          other.ping == this.ping &&
          other.pingTestTime == this.pingTestTime &&
          other.ok == this.ok &&
          other.serverIp == this.serverIp &&
          $driftBlobEquality.equals(other.config, this.config) &&
          other.support6 == this.support6 &&
          other.support6TestTime == this.support6TestTime &&
          other.subId == this.subId);
}

class OutboundHandlersCompanion extends UpdateCompanion<OutboundHandlersData> {
  final Value<int> id;
  final Value<bool> selected;
  final Value<String> countryCode;
  final Value<String> sni;
  final Value<double> speed;
  final Value<int> speedTestTime;
  final Value<int> ping;
  final Value<int> pingTestTime;
  final Value<int> ok;
  final Value<String> serverIp;
  final Value<Uint8List> config;
  final Value<int> support6;
  final Value<int> support6TestTime;
  final Value<int?> subId;
  const OutboundHandlersCompanion({
    this.id = const Value.absent(),
    this.selected = const Value.absent(),
    this.countryCode = const Value.absent(),
    this.sni = const Value.absent(),
    this.speed = const Value.absent(),
    this.speedTestTime = const Value.absent(),
    this.ping = const Value.absent(),
    this.pingTestTime = const Value.absent(),
    this.ok = const Value.absent(),
    this.serverIp = const Value.absent(),
    this.config = const Value.absent(),
    this.support6 = const Value.absent(),
    this.support6TestTime = const Value.absent(),
    this.subId = const Value.absent(),
  });
  OutboundHandlersCompanion.insert({
    this.id = const Value.absent(),
    required bool selected,
    required String countryCode,
    required String sni,
    this.speed = const Value.absent(),
    this.speedTestTime = const Value.absent(),
    this.ping = const Value.absent(),
    this.pingTestTime = const Value.absent(),
    this.ok = const Value.absent(),
    required String serverIp,
    required Uint8List config,
    this.support6 = const Value.absent(),
    this.support6TestTime = const Value.absent(),
    this.subId = const Value.absent(),
  })  : selected = Value(selected),
        countryCode = Value(countryCode),
        sni = Value(sni),
        serverIp = Value(serverIp),
        config = Value(config);
  static Insertable<OutboundHandlersData> custom({
    Expression<int>? id,
    Expression<bool>? selected,
    Expression<String>? countryCode,
    Expression<String>? sni,
    Expression<double>? speed,
    Expression<int>? speedTestTime,
    Expression<int>? ping,
    Expression<int>? pingTestTime,
    Expression<int>? ok,
    Expression<String>? serverIp,
    Expression<Uint8List>? config,
    Expression<int>? support6,
    Expression<int>? support6TestTime,
    Expression<int>? subId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (selected != null) 'selected': selected,
      if (countryCode != null) 'country_code': countryCode,
      if (sni != null) 'sni': sni,
      if (speed != null) 'speed': speed,
      if (speedTestTime != null) 'speed_test_time': speedTestTime,
      if (ping != null) 'ping': ping,
      if (pingTestTime != null) 'ping_test_time': pingTestTime,
      if (ok != null) 'ok': ok,
      if (serverIp != null) 'server_ip': serverIp,
      if (config != null) 'config': config,
      if (support6 != null) 'support6': support6,
      if (support6TestTime != null) 'support6_test_time': support6TestTime,
      if (subId != null) 'sub_id': subId,
    });
  }

  OutboundHandlersCompanion copyWith(
      {Value<int>? id,
      Value<bool>? selected,
      Value<String>? countryCode,
      Value<String>? sni,
      Value<double>? speed,
      Value<int>? speedTestTime,
      Value<int>? ping,
      Value<int>? pingTestTime,
      Value<int>? ok,
      Value<String>? serverIp,
      Value<Uint8List>? config,
      Value<int>? support6,
      Value<int>? support6TestTime,
      Value<int?>? subId}) {
    return OutboundHandlersCompanion(
      id: id ?? this.id,
      selected: selected ?? this.selected,
      countryCode: countryCode ?? this.countryCode,
      sni: sni ?? this.sni,
      speed: speed ?? this.speed,
      speedTestTime: speedTestTime ?? this.speedTestTime,
      ping: ping ?? this.ping,
      pingTestTime: pingTestTime ?? this.pingTestTime,
      ok: ok ?? this.ok,
      serverIp: serverIp ?? this.serverIp,
      config: config ?? this.config,
      support6: support6 ?? this.support6,
      support6TestTime: support6TestTime ?? this.support6TestTime,
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
    if (countryCode.present) {
      map['country_code'] = Variable<String>(countryCode.value);
    }
    if (sni.present) {
      map['sni'] = Variable<String>(sni.value);
    }
    if (speed.present) {
      map['speed'] = Variable<double>(speed.value);
    }
    if (speedTestTime.present) {
      map['speed_test_time'] = Variable<int>(speedTestTime.value);
    }
    if (ping.present) {
      map['ping'] = Variable<int>(ping.value);
    }
    if (pingTestTime.present) {
      map['ping_test_time'] = Variable<int>(pingTestTime.value);
    }
    if (ok.present) {
      map['ok'] = Variable<int>(ok.value);
    }
    if (serverIp.present) {
      map['server_ip'] = Variable<String>(serverIp.value);
    }
    if (config.present) {
      map['config'] = Variable<Uint8List>(config.value);
    }
    if (support6.present) {
      map['support6'] = Variable<int>(support6.value);
    }
    if (support6TestTime.present) {
      map['support6_test_time'] = Variable<int>(support6TestTime.value);
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
          ..write('countryCode: $countryCode, ')
          ..write('sni: $sni, ')
          ..write('speed: $speed, ')
          ..write('speedTestTime: $speedTestTime, ')
          ..write('ping: $ping, ')
          ..write('pingTestTime: $pingTestTime, ')
          ..write('ok: $ok, ')
          ..write('serverIp: $serverIp, ')
          ..write('config: $config, ')
          ..write('support6: $support6, ')
          ..write('support6TestTime: $support6TestTime, ')
          ..write('subId: $subId')
          ..write(')'))
        .toString();
  }
}

class OutboundHandlerGroups extends Table
    with TableInfo<OutboundHandlerGroups, OutboundHandlerGroupsData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  OutboundHandlerGroups(this.attachedDatabase, [this._alias]);
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [name];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'outbound_handler_groups';
  @override
  Set<GeneratedColumn> get $primaryKey => {name};
  @override
  OutboundHandlerGroupsData map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OutboundHandlerGroupsData(
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
    );
  }

  @override
  OutboundHandlerGroups createAlias(String alias) {
    return OutboundHandlerGroups(attachedDatabase, alias);
  }
}

class OutboundHandlerGroupsData extends DataClass
    implements Insertable<OutboundHandlerGroupsData> {
  final String name;
  const OutboundHandlerGroupsData({required this.name});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['name'] = Variable<String>(name);
    return map;
  }

  OutboundHandlerGroupsCompanion toCompanion(bool nullToAbsent) {
    return OutboundHandlerGroupsCompanion(
      name: Value(name),
    );
  }

  factory OutboundHandlerGroupsData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OutboundHandlerGroupsData(
      name: serializer.fromJson<String>(json['name']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'name': serializer.toJson<String>(name),
    };
  }

  OutboundHandlerGroupsData copyWith({String? name}) =>
      OutboundHandlerGroupsData(
        name: name ?? this.name,
      );
  OutboundHandlerGroupsData copyWithCompanion(
      OutboundHandlerGroupsCompanion data) {
    return OutboundHandlerGroupsData(
      name: data.name.present ? data.name.value : this.name,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OutboundHandlerGroupsData(')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => name.hashCode;
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OutboundHandlerGroupsData && other.name == this.name);
}

class OutboundHandlerGroupsCompanion
    extends UpdateCompanion<OutboundHandlerGroupsData> {
  final Value<String> name;
  final Value<int> rowid;
  const OutboundHandlerGroupsCompanion({
    this.name = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  OutboundHandlerGroupsCompanion.insert({
    required String name,
    this.rowid = const Value.absent(),
  }) : name = Value(name);
  static Insertable<OutboundHandlerGroupsData> custom({
    Expression<String>? name,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (name != null) 'name': name,
      if (rowid != null) 'rowid': rowid,
    });
  }

  OutboundHandlerGroupsCompanion copyWith(
      {Value<String>? name, Value<int>? rowid}) {
    return OutboundHandlerGroupsCompanion(
      name: name ?? this.name,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OutboundHandlerGroupsCompanion(')
          ..write('name: $name, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class OutboundHandlerGroupRelations extends Table
    with
        TableInfo<OutboundHandlerGroupRelations,
            OutboundHandlerGroupRelationsData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  OutboundHandlerGroupRelations(this.attachedDatabase, [this._alias]);
  late final GeneratedColumn<String> groupName = GeneratedColumn<String>(
      'group_name', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES outbound_handler_groups (name) ON DELETE CASCADE'));
  late final GeneratedColumn<int> handlerId = GeneratedColumn<int>(
      'handler_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES outbound_handlers (id) ON DELETE CASCADE'));
  @override
  List<GeneratedColumn> get $columns => [groupName, handlerId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'outbound_handler_group_relations';
  @override
  Set<GeneratedColumn> get $primaryKey => {groupName, handlerId};
  @override
  OutboundHandlerGroupRelationsData map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OutboundHandlerGroupRelationsData(
      groupName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}group_name'])!,
      handlerId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}handler_id'])!,
    );
  }

  @override
  OutboundHandlerGroupRelations createAlias(String alias) {
    return OutboundHandlerGroupRelations(attachedDatabase, alias);
  }
}

class OutboundHandlerGroupRelationsData extends DataClass
    implements Insertable<OutboundHandlerGroupRelationsData> {
  final String groupName;
  final int handlerId;
  const OutboundHandlerGroupRelationsData(
      {required this.groupName, required this.handlerId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['group_name'] = Variable<String>(groupName);
    map['handler_id'] = Variable<int>(handlerId);
    return map;
  }

  OutboundHandlerGroupRelationsCompanion toCompanion(bool nullToAbsent) {
    return OutboundHandlerGroupRelationsCompanion(
      groupName: Value(groupName),
      handlerId: Value(handlerId),
    );
  }

  factory OutboundHandlerGroupRelationsData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OutboundHandlerGroupRelationsData(
      groupName: serializer.fromJson<String>(json['groupName']),
      handlerId: serializer.fromJson<int>(json['handlerId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'groupName': serializer.toJson<String>(groupName),
      'handlerId': serializer.toJson<int>(handlerId),
    };
  }

  OutboundHandlerGroupRelationsData copyWith(
          {String? groupName, int? handlerId}) =>
      OutboundHandlerGroupRelationsData(
        groupName: groupName ?? this.groupName,
        handlerId: handlerId ?? this.handlerId,
      );
  OutboundHandlerGroupRelationsData copyWithCompanion(
      OutboundHandlerGroupRelationsCompanion data) {
    return OutboundHandlerGroupRelationsData(
      groupName: data.groupName.present ? data.groupName.value : this.groupName,
      handlerId: data.handlerId.present ? data.handlerId.value : this.handlerId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OutboundHandlerGroupRelationsData(')
          ..write('groupName: $groupName, ')
          ..write('handlerId: $handlerId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(groupName, handlerId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OutboundHandlerGroupRelationsData &&
          other.groupName == this.groupName &&
          other.handlerId == this.handlerId);
}

class OutboundHandlerGroupRelationsCompanion
    extends UpdateCompanion<OutboundHandlerGroupRelationsData> {
  final Value<String> groupName;
  final Value<int> handlerId;
  final Value<int> rowid;
  const OutboundHandlerGroupRelationsCompanion({
    this.groupName = const Value.absent(),
    this.handlerId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  OutboundHandlerGroupRelationsCompanion.insert({
    required String groupName,
    required int handlerId,
    this.rowid = const Value.absent(),
  })  : groupName = Value(groupName),
        handlerId = Value(handlerId);
  static Insertable<OutboundHandlerGroupRelationsData> custom({
    Expression<String>? groupName,
    Expression<int>? handlerId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (groupName != null) 'group_name': groupName,
      if (handlerId != null) 'handler_id': handlerId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  OutboundHandlerGroupRelationsCompanion copyWith(
      {Value<String>? groupName, Value<int>? handlerId, Value<int>? rowid}) {
    return OutboundHandlerGroupRelationsCompanion(
      groupName: groupName ?? this.groupName,
      handlerId: handlerId ?? this.handlerId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (groupName.present) {
      map['group_name'] = Variable<String>(groupName.value);
    }
    if (handlerId.present) {
      map['handler_id'] = Variable<int>(handlerId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OutboundHandlerGroupRelationsCompanion(')
          ..write('groupName: $groupName, ')
          ..write('handlerId: $handlerId, ')
          ..write('rowid: $rowid')
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

class AtomicDomainSets extends Table
    with TableInfo<AtomicDomainSets, AtomicDomainSetsData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  AtomicDomainSets(this.attachedDatabase, [this._alias]);
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  late final GeneratedColumn<Uint8List> geositeConfig =
      GeneratedColumn<Uint8List>('geosite_config', aliasedName, true,
          type: DriftSqlType.blob, requiredDuringInsert: false);
  late final GeneratedColumn<bool> useBloomFilter = GeneratedColumn<bool>(
      'use_bloom_filter', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("use_bloom_filter" IN (0, 1))'),
      defaultValue: const CustomExpression('0'));
  @override
  List<GeneratedColumn> get $columns => [name, geositeConfig, useBloomFilter];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'atomic_domain_sets';
  @override
  Set<GeneratedColumn> get $primaryKey => {name};
  @override
  AtomicDomainSetsData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AtomicDomainSetsData(
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      geositeConfig: attachedDatabase.typeMapping
          .read(DriftSqlType.blob, data['${effectivePrefix}geosite_config']),
      useBloomFilter: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}use_bloom_filter'])!,
    );
  }

  @override
  AtomicDomainSets createAlias(String alias) {
    return AtomicDomainSets(attachedDatabase, alias);
  }
}

class AtomicDomainSetsData extends DataClass
    implements Insertable<AtomicDomainSetsData> {
  final String name;
  final Uint8List? geositeConfig;
  final bool useBloomFilter;
  const AtomicDomainSetsData(
      {required this.name, this.geositeConfig, required this.useBloomFilter});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || geositeConfig != null) {
      map['geosite_config'] = Variable<Uint8List>(geositeConfig);
    }
    map['use_bloom_filter'] = Variable<bool>(useBloomFilter);
    return map;
  }

  AtomicDomainSetsCompanion toCompanion(bool nullToAbsent) {
    return AtomicDomainSetsCompanion(
      name: Value(name),
      geositeConfig: geositeConfig == null && nullToAbsent
          ? const Value.absent()
          : Value(geositeConfig),
      useBloomFilter: Value(useBloomFilter),
    );
  }

  factory AtomicDomainSetsData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AtomicDomainSetsData(
      name: serializer.fromJson<String>(json['name']),
      geositeConfig: serializer.fromJson<Uint8List?>(json['geositeConfig']),
      useBloomFilter: serializer.fromJson<bool>(json['useBloomFilter']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'name': serializer.toJson<String>(name),
      'geositeConfig': serializer.toJson<Uint8List?>(geositeConfig),
      'useBloomFilter': serializer.toJson<bool>(useBloomFilter),
    };
  }

  AtomicDomainSetsData copyWith(
          {String? name,
          Value<Uint8List?> geositeConfig = const Value.absent(),
          bool? useBloomFilter}) =>
      AtomicDomainSetsData(
        name: name ?? this.name,
        geositeConfig:
            geositeConfig.present ? geositeConfig.value : this.geositeConfig,
        useBloomFilter: useBloomFilter ?? this.useBloomFilter,
      );
  AtomicDomainSetsData copyWithCompanion(AtomicDomainSetsCompanion data) {
    return AtomicDomainSetsData(
      name: data.name.present ? data.name.value : this.name,
      geositeConfig: data.geositeConfig.present
          ? data.geositeConfig.value
          : this.geositeConfig,
      useBloomFilter: data.useBloomFilter.present
          ? data.useBloomFilter.value
          : this.useBloomFilter,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AtomicDomainSetsData(')
          ..write('name: $name, ')
          ..write('geositeConfig: $geositeConfig, ')
          ..write('useBloomFilter: $useBloomFilter')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(name, $driftBlobEquality.hash(geositeConfig), useBloomFilter);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AtomicDomainSetsData &&
          other.name == this.name &&
          $driftBlobEquality.equals(other.geositeConfig, this.geositeConfig) &&
          other.useBloomFilter == this.useBloomFilter);
}

class AtomicDomainSetsCompanion extends UpdateCompanion<AtomicDomainSetsData> {
  final Value<String> name;
  final Value<Uint8List?> geositeConfig;
  final Value<bool> useBloomFilter;
  final Value<int> rowid;
  const AtomicDomainSetsCompanion({
    this.name = const Value.absent(),
    this.geositeConfig = const Value.absent(),
    this.useBloomFilter = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AtomicDomainSetsCompanion.insert({
    required String name,
    this.geositeConfig = const Value.absent(),
    this.useBloomFilter = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : name = Value(name);
  static Insertable<AtomicDomainSetsData> custom({
    Expression<String>? name,
    Expression<Uint8List>? geositeConfig,
    Expression<bool>? useBloomFilter,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (name != null) 'name': name,
      if (geositeConfig != null) 'geosite_config': geositeConfig,
      if (useBloomFilter != null) 'use_bloom_filter': useBloomFilter,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AtomicDomainSetsCompanion copyWith(
      {Value<String>? name,
      Value<Uint8List?>? geositeConfig,
      Value<bool>? useBloomFilter,
      Value<int>? rowid}) {
    return AtomicDomainSetsCompanion(
      name: name ?? this.name,
      geositeConfig: geositeConfig ?? this.geositeConfig,
      useBloomFilter: useBloomFilter ?? this.useBloomFilter,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (geositeConfig.present) {
      map['geosite_config'] = Variable<Uint8List>(geositeConfig.value);
    }
    if (useBloomFilter.present) {
      map['use_bloom_filter'] = Variable<bool>(useBloomFilter.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AtomicDomainSetsCompanion(')
          ..write('name: $name, ')
          ..write('geositeConfig: $geositeConfig, ')
          ..write('useBloomFilter: $useBloomFilter, ')
          ..write('rowid: $rowid')
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
  late final GeneratedColumn<Uint8List> geoDomain = GeneratedColumn<Uint8List>(
      'geo_domain', aliasedName, false,
      type: DriftSqlType.blob, requiredDuringInsert: true);
  late final GeneratedColumn<String> domainSetName = GeneratedColumn<String>(
      'domain_set_name', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES atomic_domain_sets (name) ON UPDATE CASCADE ON DELETE CASCADE'));
  @override
  List<GeneratedColumn> get $columns => [id, geoDomain, domainSetName];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'geo_domains';
  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
        {geoDomain, domainSetName},
      ];
  @override
  GeoDomainsData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GeoDomainsData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      geoDomain: attachedDatabase.typeMapping
          .read(DriftSqlType.blob, data['${effectivePrefix}geo_domain'])!,
      domainSetName: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}domain_set_name'])!,
    );
  }

  @override
  GeoDomains createAlias(String alias) {
    return GeoDomains(attachedDatabase, alias);
  }
}

class GeoDomainsData extends DataClass implements Insertable<GeoDomainsData> {
  final int id;
  final Uint8List geoDomain;
  final String domainSetName;
  const GeoDomainsData(
      {required this.id, required this.geoDomain, required this.domainSetName});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['geo_domain'] = Variable<Uint8List>(geoDomain);
    map['domain_set_name'] = Variable<String>(domainSetName);
    return map;
  }

  GeoDomainsCompanion toCompanion(bool nullToAbsent) {
    return GeoDomainsCompanion(
      id: Value(id),
      geoDomain: Value(geoDomain),
      domainSetName: Value(domainSetName),
    );
  }

  factory GeoDomainsData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GeoDomainsData(
      id: serializer.fromJson<int>(json['id']),
      geoDomain: serializer.fromJson<Uint8List>(json['geoDomain']),
      domainSetName: serializer.fromJson<String>(json['domainSetName']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'geoDomain': serializer.toJson<Uint8List>(geoDomain),
      'domainSetName': serializer.toJson<String>(domainSetName),
    };
  }

  GeoDomainsData copyWith(
          {int? id, Uint8List? geoDomain, String? domainSetName}) =>
      GeoDomainsData(
        id: id ?? this.id,
        geoDomain: geoDomain ?? this.geoDomain,
        domainSetName: domainSetName ?? this.domainSetName,
      );
  GeoDomainsData copyWithCompanion(GeoDomainsCompanion data) {
    return GeoDomainsData(
      id: data.id.present ? data.id.value : this.id,
      geoDomain: data.geoDomain.present ? data.geoDomain.value : this.geoDomain,
      domainSetName: data.domainSetName.present
          ? data.domainSetName.value
          : this.domainSetName,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GeoDomainsData(')
          ..write('id: $id, ')
          ..write('geoDomain: $geoDomain, ')
          ..write('domainSetName: $domainSetName')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, $driftBlobEquality.hash(geoDomain), domainSetName);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GeoDomainsData &&
          other.id == this.id &&
          $driftBlobEquality.equals(other.geoDomain, this.geoDomain) &&
          other.domainSetName == this.domainSetName);
}

class GeoDomainsCompanion extends UpdateCompanion<GeoDomainsData> {
  final Value<int> id;
  final Value<Uint8List> geoDomain;
  final Value<String> domainSetName;
  const GeoDomainsCompanion({
    this.id = const Value.absent(),
    this.geoDomain = const Value.absent(),
    this.domainSetName = const Value.absent(),
  });
  GeoDomainsCompanion.insert({
    this.id = const Value.absent(),
    required Uint8List geoDomain,
    required String domainSetName,
  })  : geoDomain = Value(geoDomain),
        domainSetName = Value(domainSetName);
  static Insertable<GeoDomainsData> custom({
    Expression<int>? id,
    Expression<Uint8List>? geoDomain,
    Expression<String>? domainSetName,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (geoDomain != null) 'geo_domain': geoDomain,
      if (domainSetName != null) 'domain_set_name': domainSetName,
    });
  }

  GeoDomainsCompanion copyWith(
      {Value<int>? id,
      Value<Uint8List>? geoDomain,
      Value<String>? domainSetName}) {
    return GeoDomainsCompanion(
      id: id ?? this.id,
      geoDomain: geoDomain ?? this.geoDomain,
      domainSetName: domainSetName ?? this.domainSetName,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (geoDomain.present) {
      map['geo_domain'] = Variable<Uint8List>(geoDomain.value);
    }
    if (domainSetName.present) {
      map['domain_set_name'] = Variable<String>(domainSetName.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GeoDomainsCompanion(')
          ..write('id: $id, ')
          ..write('geoDomain: $geoDomain, ')
          ..write('domainSetName: $domainSetName')
          ..write(')'))
        .toString();
  }
}

class GreatDomainSets extends Table
    with TableInfo<GreatDomainSets, GreatDomainSetsData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  GreatDomainSets(this.attachedDatabase, [this._alias]);
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  late final GeneratedColumn<String> oppositeName = GeneratedColumn<String>(
      'opposite_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  late final GeneratedColumn<Uint8List> set = GeneratedColumn<Uint8List>(
      'set', aliasedName, false,
      type: DriftSqlType.blob, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [name, oppositeName, set];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'great_domain_sets';
  @override
  Set<GeneratedColumn> get $primaryKey => {name};
  @override
  GreatDomainSetsData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GreatDomainSetsData(
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      oppositeName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}opposite_name']),
      set: attachedDatabase.typeMapping
          .read(DriftSqlType.blob, data['${effectivePrefix}set'])!,
    );
  }

  @override
  GreatDomainSets createAlias(String alias) {
    return GreatDomainSets(attachedDatabase, alias);
  }
}

class GreatDomainSetsData extends DataClass
    implements Insertable<GreatDomainSetsData> {
  final String name;
  final String? oppositeName;
  final Uint8List set;
  const GreatDomainSetsData(
      {required this.name, this.oppositeName, required this.set});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || oppositeName != null) {
      map['opposite_name'] = Variable<String>(oppositeName);
    }
    map['set'] = Variable<Uint8List>(set);
    return map;
  }

  GreatDomainSetsCompanion toCompanion(bool nullToAbsent) {
    return GreatDomainSetsCompanion(
      name: Value(name),
      oppositeName: oppositeName == null && nullToAbsent
          ? const Value.absent()
          : Value(oppositeName),
      set: Value(set),
    );
  }

  factory GreatDomainSetsData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GreatDomainSetsData(
      name: serializer.fromJson<String>(json['name']),
      oppositeName: serializer.fromJson<String?>(json['oppositeName']),
      set: serializer.fromJson<Uint8List>(json['set']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'name': serializer.toJson<String>(name),
      'oppositeName': serializer.toJson<String?>(oppositeName),
      'set': serializer.toJson<Uint8List>(set),
    };
  }

  GreatDomainSetsData copyWith(
          {String? name,
          Value<String?> oppositeName = const Value.absent(),
          Uint8List? set}) =>
      GreatDomainSetsData(
        name: name ?? this.name,
        oppositeName:
            oppositeName.present ? oppositeName.value : this.oppositeName,
        set: set ?? this.set,
      );
  GreatDomainSetsData copyWithCompanion(GreatDomainSetsCompanion data) {
    return GreatDomainSetsData(
      name: data.name.present ? data.name.value : this.name,
      oppositeName: data.oppositeName.present
          ? data.oppositeName.value
          : this.oppositeName,
      set: data.set.present ? data.set.value : this.set,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GreatDomainSetsData(')
          ..write('name: $name, ')
          ..write('oppositeName: $oppositeName, ')
          ..write('set: $set')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(name, oppositeName, $driftBlobEquality.hash(set));
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GreatDomainSetsData &&
          other.name == this.name &&
          other.oppositeName == this.oppositeName &&
          $driftBlobEquality.equals(other.set, this.set));
}

class GreatDomainSetsCompanion extends UpdateCompanion<GreatDomainSetsData> {
  final Value<String> name;
  final Value<String?> oppositeName;
  final Value<Uint8List> set;
  final Value<int> rowid;
  const GreatDomainSetsCompanion({
    this.name = const Value.absent(),
    this.oppositeName = const Value.absent(),
    this.set = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GreatDomainSetsCompanion.insert({
    required String name,
    this.oppositeName = const Value.absent(),
    required Uint8List set,
    this.rowid = const Value.absent(),
  })  : name = Value(name),
        set = Value(set);
  static Insertable<GreatDomainSetsData> custom({
    Expression<String>? name,
    Expression<String>? oppositeName,
    Expression<Uint8List>? set,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (name != null) 'name': name,
      if (oppositeName != null) 'opposite_name': oppositeName,
      if (set != null) 'set': set,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GreatDomainSetsCompanion copyWith(
      {Value<String>? name,
      Value<String?>? oppositeName,
      Value<Uint8List>? set,
      Value<int>? rowid}) {
    return GreatDomainSetsCompanion(
      name: name ?? this.name,
      oppositeName: oppositeName ?? this.oppositeName,
      set: set ?? this.set,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (oppositeName.present) {
      map['opposite_name'] = Variable<String>(oppositeName.value);
    }
    if (set.present) {
      map['set'] = Variable<Uint8List>(set.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GreatDomainSetsCompanion(')
          ..write('name: $name, ')
          ..write('oppositeName: $oppositeName, ')
          ..write('set: $set, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class AtomicIpSets extends Table
    with TableInfo<AtomicIpSets, AtomicIpSetsData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  AtomicIpSets(this.attachedDatabase, [this._alias]);
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  late final GeneratedColumn<bool> inverse = GeneratedColumn<bool>(
      'inverse', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("inverse" IN (0, 1))'),
      defaultValue: const CustomExpression('0'));
  late final GeneratedColumn<Uint8List> geoIpConfig =
      GeneratedColumn<Uint8List>('geo_ip_config', aliasedName, true,
          type: DriftSqlType.blob, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [name, inverse, geoIpConfig];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'atomic_ip_sets';
  @override
  Set<GeneratedColumn> get $primaryKey => {name};
  @override
  AtomicIpSetsData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AtomicIpSetsData(
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      inverse: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}inverse'])!,
      geoIpConfig: attachedDatabase.typeMapping
          .read(DriftSqlType.blob, data['${effectivePrefix}geo_ip_config']),
    );
  }

  @override
  AtomicIpSets createAlias(String alias) {
    return AtomicIpSets(attachedDatabase, alias);
  }
}

class AtomicIpSetsData extends DataClass
    implements Insertable<AtomicIpSetsData> {
  final String name;
  final bool inverse;
  final Uint8List? geoIpConfig;
  const AtomicIpSetsData(
      {required this.name, required this.inverse, this.geoIpConfig});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['name'] = Variable<String>(name);
    map['inverse'] = Variable<bool>(inverse);
    if (!nullToAbsent || geoIpConfig != null) {
      map['geo_ip_config'] = Variable<Uint8List>(geoIpConfig);
    }
    return map;
  }

  AtomicIpSetsCompanion toCompanion(bool nullToAbsent) {
    return AtomicIpSetsCompanion(
      name: Value(name),
      inverse: Value(inverse),
      geoIpConfig: geoIpConfig == null && nullToAbsent
          ? const Value.absent()
          : Value(geoIpConfig),
    );
  }

  factory AtomicIpSetsData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AtomicIpSetsData(
      name: serializer.fromJson<String>(json['name']),
      inverse: serializer.fromJson<bool>(json['inverse']),
      geoIpConfig: serializer.fromJson<Uint8List?>(json['geoIpConfig']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'name': serializer.toJson<String>(name),
      'inverse': serializer.toJson<bool>(inverse),
      'geoIpConfig': serializer.toJson<Uint8List?>(geoIpConfig),
    };
  }

  AtomicIpSetsData copyWith(
          {String? name,
          bool? inverse,
          Value<Uint8List?> geoIpConfig = const Value.absent()}) =>
      AtomicIpSetsData(
        name: name ?? this.name,
        inverse: inverse ?? this.inverse,
        geoIpConfig: geoIpConfig.present ? geoIpConfig.value : this.geoIpConfig,
      );
  AtomicIpSetsData copyWithCompanion(AtomicIpSetsCompanion data) {
    return AtomicIpSetsData(
      name: data.name.present ? data.name.value : this.name,
      inverse: data.inverse.present ? data.inverse.value : this.inverse,
      geoIpConfig:
          data.geoIpConfig.present ? data.geoIpConfig.value : this.geoIpConfig,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AtomicIpSetsData(')
          ..write('name: $name, ')
          ..write('inverse: $inverse, ')
          ..write('geoIpConfig: $geoIpConfig')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(name, inverse, $driftBlobEquality.hash(geoIpConfig));
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AtomicIpSetsData &&
          other.name == this.name &&
          other.inverse == this.inverse &&
          $driftBlobEquality.equals(other.geoIpConfig, this.geoIpConfig));
}

class AtomicIpSetsCompanion extends UpdateCompanion<AtomicIpSetsData> {
  final Value<String> name;
  final Value<bool> inverse;
  final Value<Uint8List?> geoIpConfig;
  final Value<int> rowid;
  const AtomicIpSetsCompanion({
    this.name = const Value.absent(),
    this.inverse = const Value.absent(),
    this.geoIpConfig = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AtomicIpSetsCompanion.insert({
    required String name,
    this.inverse = const Value.absent(),
    this.geoIpConfig = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : name = Value(name);
  static Insertable<AtomicIpSetsData> custom({
    Expression<String>? name,
    Expression<bool>? inverse,
    Expression<Uint8List>? geoIpConfig,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (name != null) 'name': name,
      if (inverse != null) 'inverse': inverse,
      if (geoIpConfig != null) 'geo_ip_config': geoIpConfig,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AtomicIpSetsCompanion copyWith(
      {Value<String>? name,
      Value<bool>? inverse,
      Value<Uint8List?>? geoIpConfig,
      Value<int>? rowid}) {
    return AtomicIpSetsCompanion(
      name: name ?? this.name,
      inverse: inverse ?? this.inverse,
      geoIpConfig: geoIpConfig ?? this.geoIpConfig,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (inverse.present) {
      map['inverse'] = Variable<bool>(inverse.value);
    }
    if (geoIpConfig.present) {
      map['geo_ip_config'] = Variable<Uint8List>(geoIpConfig.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AtomicIpSetsCompanion(')
          ..write('name: $name, ')
          ..write('inverse: $inverse, ')
          ..write('geoIpConfig: $geoIpConfig, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class GreatIpSets extends Table with TableInfo<GreatIpSets, GreatIpSetsData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  GreatIpSets(this.attachedDatabase, [this._alias]);
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  late final GeneratedColumn<Uint8List> greatIpSetConfig =
      GeneratedColumn<Uint8List>('great_ip_set_config', aliasedName, false,
          type: DriftSqlType.blob, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [name, greatIpSetConfig];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'great_ip_sets';
  @override
  Set<GeneratedColumn> get $primaryKey => {name};
  @override
  GreatIpSetsData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GreatIpSetsData(
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      greatIpSetConfig: attachedDatabase.typeMapping.read(
          DriftSqlType.blob, data['${effectivePrefix}great_ip_set_config'])!,
    );
  }

  @override
  GreatIpSets createAlias(String alias) {
    return GreatIpSets(attachedDatabase, alias);
  }
}

class GreatIpSetsData extends DataClass implements Insertable<GreatIpSetsData> {
  final String name;
  final Uint8List greatIpSetConfig;
  const GreatIpSetsData({required this.name, required this.greatIpSetConfig});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['name'] = Variable<String>(name);
    map['great_ip_set_config'] = Variable<Uint8List>(greatIpSetConfig);
    return map;
  }

  GreatIpSetsCompanion toCompanion(bool nullToAbsent) {
    return GreatIpSetsCompanion(
      name: Value(name),
      greatIpSetConfig: Value(greatIpSetConfig),
    );
  }

  factory GreatIpSetsData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GreatIpSetsData(
      name: serializer.fromJson<String>(json['name']),
      greatIpSetConfig:
          serializer.fromJson<Uint8List>(json['greatIpSetConfig']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'name': serializer.toJson<String>(name),
      'greatIpSetConfig': serializer.toJson<Uint8List>(greatIpSetConfig),
    };
  }

  GreatIpSetsData copyWith({String? name, Uint8List? greatIpSetConfig}) =>
      GreatIpSetsData(
        name: name ?? this.name,
        greatIpSetConfig: greatIpSetConfig ?? this.greatIpSetConfig,
      );
  GreatIpSetsData copyWithCompanion(GreatIpSetsCompanion data) {
    return GreatIpSetsData(
      name: data.name.present ? data.name.value : this.name,
      greatIpSetConfig: data.greatIpSetConfig.present
          ? data.greatIpSetConfig.value
          : this.greatIpSetConfig,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GreatIpSetsData(')
          ..write('name: $name, ')
          ..write('greatIpSetConfig: $greatIpSetConfig')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(name, $driftBlobEquality.hash(greatIpSetConfig));
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GreatIpSetsData &&
          other.name == this.name &&
          $driftBlobEquality.equals(
              other.greatIpSetConfig, this.greatIpSetConfig));
}

class GreatIpSetsCompanion extends UpdateCompanion<GreatIpSetsData> {
  final Value<String> name;
  final Value<Uint8List> greatIpSetConfig;
  final Value<int> rowid;
  const GreatIpSetsCompanion({
    this.name = const Value.absent(),
    this.greatIpSetConfig = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GreatIpSetsCompanion.insert({
    required String name,
    required Uint8List greatIpSetConfig,
    this.rowid = const Value.absent(),
  })  : name = Value(name),
        greatIpSetConfig = Value(greatIpSetConfig);
  static Insertable<GreatIpSetsData> custom({
    Expression<String>? name,
    Expression<Uint8List>? greatIpSetConfig,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (name != null) 'name': name,
      if (greatIpSetConfig != null) 'great_ip_set_config': greatIpSetConfig,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GreatIpSetsCompanion copyWith(
      {Value<String>? name,
      Value<Uint8List>? greatIpSetConfig,
      Value<int>? rowid}) {
    return GreatIpSetsCompanion(
      name: name ?? this.name,
      greatIpSetConfig: greatIpSetConfig ?? this.greatIpSetConfig,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (greatIpSetConfig.present) {
      map['great_ip_set_config'] = Variable<Uint8List>(greatIpSetConfig.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GreatIpSetsCompanion(')
          ..write('name: $name, ')
          ..write('greatIpSetConfig: $greatIpSetConfig, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class AppSets extends Table with TableInfo<AppSets, AppSetsData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  AppSets(this.attachedDatabase, [this._alias]);
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [name];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_sets';
  @override
  Set<GeneratedColumn> get $primaryKey => {name};
  @override
  AppSetsData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSetsData(
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
    );
  }

  @override
  AppSets createAlias(String alias) {
    return AppSets(attachedDatabase, alias);
  }
}

class AppSetsData extends DataClass implements Insertable<AppSetsData> {
  final String name;
  const AppSetsData({required this.name});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['name'] = Variable<String>(name);
    return map;
  }

  AppSetsCompanion toCompanion(bool nullToAbsent) {
    return AppSetsCompanion(
      name: Value(name),
    );
  }

  factory AppSetsData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSetsData(
      name: serializer.fromJson<String>(json['name']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'name': serializer.toJson<String>(name),
    };
  }

  AppSetsData copyWith({String? name}) => AppSetsData(
        name: name ?? this.name,
      );
  AppSetsData copyWithCompanion(AppSetsCompanion data) {
    return AppSetsData(
      name: data.name.present ? data.name.value : this.name,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSetsData(')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => name.hashCode;
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSetsData && other.name == this.name);
}

class AppSetsCompanion extends UpdateCompanion<AppSetsData> {
  final Value<String> name;
  final Value<int> rowid;
  const AppSetsCompanion({
    this.name = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppSetsCompanion.insert({
    required String name,
    this.rowid = const Value.absent(),
  }) : name = Value(name);
  static Insertable<AppSetsData> custom({
    Expression<String>? name,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (name != null) 'name': name,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppSetsCompanion copyWith({Value<String>? name, Value<int>? rowid}) {
    return AppSetsCompanion(
      name: name ?? this.name,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSetsCompanion(')
          ..write('name: $name, ')
          ..write('rowid: $rowid')
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
  late final GeneratedColumn<String> appSetName = GeneratedColumn<String>(
      'app_set_name', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES app_sets (name) ON UPDATE CASCADE ON DELETE CASCADE'));
  late final GeneratedColumn<Uint8List> appId = GeneratedColumn<Uint8List>(
      'app_id', aliasedName, false,
      type: DriftSqlType.blob, requiredDuringInsert: true);
  late final GeneratedColumn<Uint8List> icon = GeneratedColumn<Uint8List>(
      'icon', aliasedName, true,
      type: DriftSqlType.blob, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [id, appSetName, appId, icon];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'apps';
  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
        {appId, appSetName},
      ];
  @override
  AppsData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppsData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      appSetName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}app_set_name'])!,
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
  final String appSetName;
  final Uint8List appId;
  final Uint8List? icon;
  const AppsData(
      {required this.id,
      required this.appSetName,
      required this.appId,
      this.icon});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['app_set_name'] = Variable<String>(appSetName);
    map['app_id'] = Variable<Uint8List>(appId);
    if (!nullToAbsent || icon != null) {
      map['icon'] = Variable<Uint8List>(icon);
    }
    return map;
  }

  AppsCompanion toCompanion(bool nullToAbsent) {
    return AppsCompanion(
      id: Value(id),
      appSetName: Value(appSetName),
      appId: Value(appId),
      icon: icon == null && nullToAbsent ? const Value.absent() : Value(icon),
    );
  }

  factory AppsData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppsData(
      id: serializer.fromJson<int>(json['id']),
      appSetName: serializer.fromJson<String>(json['appSetName']),
      appId: serializer.fromJson<Uint8List>(json['appId']),
      icon: serializer.fromJson<Uint8List?>(json['icon']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'appSetName': serializer.toJson<String>(appSetName),
      'appId': serializer.toJson<Uint8List>(appId),
      'icon': serializer.toJson<Uint8List?>(icon),
    };
  }

  AppsData copyWith(
          {int? id,
          String? appSetName,
          Uint8List? appId,
          Value<Uint8List?> icon = const Value.absent()}) =>
      AppsData(
        id: id ?? this.id,
        appSetName: appSetName ?? this.appSetName,
        appId: appId ?? this.appId,
        icon: icon.present ? icon.value : this.icon,
      );
  AppsData copyWithCompanion(AppsCompanion data) {
    return AppsData(
      id: data.id.present ? data.id.value : this.id,
      appSetName:
          data.appSetName.present ? data.appSetName.value : this.appSetName,
      appId: data.appId.present ? data.appId.value : this.appId,
      icon: data.icon.present ? data.icon.value : this.icon,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppsData(')
          ..write('id: $id, ')
          ..write('appSetName: $appSetName, ')
          ..write('appId: $appId, ')
          ..write('icon: $icon')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, appSetName,
      $driftBlobEquality.hash(appId), $driftBlobEquality.hash(icon));
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppsData &&
          other.id == this.id &&
          other.appSetName == this.appSetName &&
          $driftBlobEquality.equals(other.appId, this.appId) &&
          $driftBlobEquality.equals(other.icon, this.icon));
}

class AppsCompanion extends UpdateCompanion<AppsData> {
  final Value<int> id;
  final Value<String> appSetName;
  final Value<Uint8List> appId;
  final Value<Uint8List?> icon;
  const AppsCompanion({
    this.id = const Value.absent(),
    this.appSetName = const Value.absent(),
    this.appId = const Value.absent(),
    this.icon = const Value.absent(),
  });
  AppsCompanion.insert({
    this.id = const Value.absent(),
    required String appSetName,
    required Uint8List appId,
    this.icon = const Value.absent(),
  })  : appSetName = Value(appSetName),
        appId = Value(appId);
  static Insertable<AppsData> custom({
    Expression<int>? id,
    Expression<String>? appSetName,
    Expression<Uint8List>? appId,
    Expression<Uint8List>? icon,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (appSetName != null) 'app_set_name': appSetName,
      if (appId != null) 'app_id': appId,
      if (icon != null) 'icon': icon,
    });
  }

  AppsCompanion copyWith(
      {Value<int>? id,
      Value<String>? appSetName,
      Value<Uint8List>? appId,
      Value<Uint8List?>? icon}) {
    return AppsCompanion(
      id: id ?? this.id,
      appSetName: appSetName ?? this.appSetName,
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
    if (appSetName.present) {
      map['app_set_name'] = Variable<String>(appSetName.value);
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
          ..write('appSetName: $appSetName, ')
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
  late final GeneratedColumn<String> ipSetName = GeneratedColumn<String>(
      'ip_set_name', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES atomic_ip_sets (name) ON UPDATE CASCADE ON DELETE CASCADE'));
  late final GeneratedColumn<Uint8List> cidr = GeneratedColumn<Uint8List>(
      'cidr', aliasedName, false,
      type: DriftSqlType.blob, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, ipSetName, cidr];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cidrs';
  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
        {cidr, ipSetName},
      ];
  @override
  CidrsData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CidrsData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      ipSetName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}ip_set_name'])!,
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
  final String ipSetName;
  final Uint8List cidr;
  const CidrsData(
      {required this.id, required this.ipSetName, required this.cidr});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['ip_set_name'] = Variable<String>(ipSetName);
    map['cidr'] = Variable<Uint8List>(cidr);
    return map;
  }

  CidrsCompanion toCompanion(bool nullToAbsent) {
    return CidrsCompanion(
      id: Value(id),
      ipSetName: Value(ipSetName),
      cidr: Value(cidr),
    );
  }

  factory CidrsData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CidrsData(
      id: serializer.fromJson<int>(json['id']),
      ipSetName: serializer.fromJson<String>(json['ipSetName']),
      cidr: serializer.fromJson<Uint8List>(json['cidr']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'ipSetName': serializer.toJson<String>(ipSetName),
      'cidr': serializer.toJson<Uint8List>(cidr),
    };
  }

  CidrsData copyWith({int? id, String? ipSetName, Uint8List? cidr}) =>
      CidrsData(
        id: id ?? this.id,
        ipSetName: ipSetName ?? this.ipSetName,
        cidr: cidr ?? this.cidr,
      );
  CidrsData copyWithCompanion(CidrsCompanion data) {
    return CidrsData(
      id: data.id.present ? data.id.value : this.id,
      ipSetName: data.ipSetName.present ? data.ipSetName.value : this.ipSetName,
      cidr: data.cidr.present ? data.cidr.value : this.cidr,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CidrsData(')
          ..write('id: $id, ')
          ..write('ipSetName: $ipSetName, ')
          ..write('cidr: $cidr')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, ipSetName, $driftBlobEquality.hash(cidr));
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CidrsData &&
          other.id == this.id &&
          other.ipSetName == this.ipSetName &&
          $driftBlobEquality.equals(other.cidr, this.cidr));
}

class CidrsCompanion extends UpdateCompanion<CidrsData> {
  final Value<int> id;
  final Value<String> ipSetName;
  final Value<Uint8List> cidr;
  const CidrsCompanion({
    this.id = const Value.absent(),
    this.ipSetName = const Value.absent(),
    this.cidr = const Value.absent(),
  });
  CidrsCompanion.insert({
    this.id = const Value.absent(),
    required String ipSetName,
    required Uint8List cidr,
  })  : ipSetName = Value(ipSetName),
        cidr = Value(cidr);
  static Insertable<CidrsData> custom({
    Expression<int>? id,
    Expression<String>? ipSetName,
    Expression<Uint8List>? cidr,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ipSetName != null) 'ip_set_name': ipSetName,
      if (cidr != null) 'cidr': cidr,
    });
  }

  CidrsCompanion copyWith(
      {Value<int>? id, Value<String>? ipSetName, Value<Uint8List>? cidr}) {
    return CidrsCompanion(
      id: id ?? this.id,
      ipSetName: ipSetName ?? this.ipSetName,
      cidr: cidr ?? this.cidr,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (ipSetName.present) {
      map['ip_set_name'] = Variable<String>(ipSetName.value);
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
          ..write('ipSetName: $ipSetName, ')
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

class CustomRouteModes extends Table
    with TableInfo<CustomRouteModes, CustomRouteModesData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  CustomRouteModes(this.attachedDatabase, [this._alias]);
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
  late final GeneratedColumn<Uint8List> routerConfig =
      GeneratedColumn<Uint8List>('router_config', aliasedName, false,
          type: DriftSqlType.blob, requiredDuringInsert: true);
  late final GeneratedColumn<Uint8List> dnsRules = GeneratedColumn<Uint8List>(
      'dns_rules', aliasedName, false,
      type: DriftSqlType.blob,
      requiredDuringInsert: false,
      defaultValue: const CustomExpression('X\'\''));
  @override
  List<GeneratedColumn> get $columns => [id, name, routerConfig, dnsRules];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'custom_route_modes';
  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CustomRouteModesData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CustomRouteModesData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      routerConfig: attachedDatabase.typeMapping
          .read(DriftSqlType.blob, data['${effectivePrefix}router_config'])!,
      dnsRules: attachedDatabase.typeMapping
          .read(DriftSqlType.blob, data['${effectivePrefix}dns_rules'])!,
    );
  }

  @override
  CustomRouteModes createAlias(String alias) {
    return CustomRouteModes(attachedDatabase, alias);
  }
}

class CustomRouteModesData extends DataClass
    implements Insertable<CustomRouteModesData> {
  final int id;
  final String name;
  final Uint8List routerConfig;
  final Uint8List dnsRules;
  const CustomRouteModesData(
      {required this.id,
      required this.name,
      required this.routerConfig,
      required this.dnsRules});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['router_config'] = Variable<Uint8List>(routerConfig);
    map['dns_rules'] = Variable<Uint8List>(dnsRules);
    return map;
  }

  CustomRouteModesCompanion toCompanion(bool nullToAbsent) {
    return CustomRouteModesCompanion(
      id: Value(id),
      name: Value(name),
      routerConfig: Value(routerConfig),
      dnsRules: Value(dnsRules),
    );
  }

  factory CustomRouteModesData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CustomRouteModesData(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      routerConfig: serializer.fromJson<Uint8List>(json['routerConfig']),
      dnsRules: serializer.fromJson<Uint8List>(json['dnsRules']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'routerConfig': serializer.toJson<Uint8List>(routerConfig),
      'dnsRules': serializer.toJson<Uint8List>(dnsRules),
    };
  }

  CustomRouteModesData copyWith(
          {int? id,
          String? name,
          Uint8List? routerConfig,
          Uint8List? dnsRules}) =>
      CustomRouteModesData(
        id: id ?? this.id,
        name: name ?? this.name,
        routerConfig: routerConfig ?? this.routerConfig,
        dnsRules: dnsRules ?? this.dnsRules,
      );
  CustomRouteModesData copyWithCompanion(CustomRouteModesCompanion data) {
    return CustomRouteModesData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      routerConfig: data.routerConfig.present
          ? data.routerConfig.value
          : this.routerConfig,
      dnsRules: data.dnsRules.present ? data.dnsRules.value : this.dnsRules,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CustomRouteModesData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('routerConfig: $routerConfig, ')
          ..write('dnsRules: $dnsRules')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name,
      $driftBlobEquality.hash(routerConfig), $driftBlobEquality.hash(dnsRules));
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CustomRouteModesData &&
          other.id == this.id &&
          other.name == this.name &&
          $driftBlobEquality.equals(other.routerConfig, this.routerConfig) &&
          $driftBlobEquality.equals(other.dnsRules, this.dnsRules));
}

class CustomRouteModesCompanion extends UpdateCompanion<CustomRouteModesData> {
  final Value<int> id;
  final Value<String> name;
  final Value<Uint8List> routerConfig;
  final Value<Uint8List> dnsRules;
  const CustomRouteModesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.routerConfig = const Value.absent(),
    this.dnsRules = const Value.absent(),
  });
  CustomRouteModesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required Uint8List routerConfig,
    this.dnsRules = const Value.absent(),
  })  : name = Value(name),
        routerConfig = Value(routerConfig);
  static Insertable<CustomRouteModesData> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<Uint8List>? routerConfig,
    Expression<Uint8List>? dnsRules,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (routerConfig != null) 'router_config': routerConfig,
      if (dnsRules != null) 'dns_rules': dnsRules,
    });
  }

  CustomRouteModesCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<Uint8List>? routerConfig,
      Value<Uint8List>? dnsRules}) {
    return CustomRouteModesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      routerConfig: routerConfig ?? this.routerConfig,
      dnsRules: dnsRules ?? this.dnsRules,
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
    if (routerConfig.present) {
      map['router_config'] = Variable<Uint8List>(routerConfig.value);
    }
    if (dnsRules.present) {
      map['dns_rules'] = Variable<Uint8List>(dnsRules.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CustomRouteModesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('routerConfig: $routerConfig, ')
          ..write('dnsRules: $dnsRules')
          ..write(')'))
        .toString();
  }
}

class HandlerSelectors extends Table
    with TableInfo<HandlerSelectors, HandlerSelectorsData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  HandlerSelectors(this.attachedDatabase, [this._alias]);
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  late final GeneratedColumn<Uint8List> config = GeneratedColumn<Uint8List>(
      'config', aliasedName, false,
      type: DriftSqlType.blob, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [name, config];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'handler_selectors';
  @override
  Set<GeneratedColumn> get $primaryKey => {name};
  @override
  HandlerSelectorsData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HandlerSelectorsData(
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      config: attachedDatabase.typeMapping
          .read(DriftSqlType.blob, data['${effectivePrefix}config'])!,
    );
  }

  @override
  HandlerSelectors createAlias(String alias) {
    return HandlerSelectors(attachedDatabase, alias);
  }
}

class HandlerSelectorsData extends DataClass
    implements Insertable<HandlerSelectorsData> {
  final String name;
  final Uint8List config;
  const HandlerSelectorsData({required this.name, required this.config});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['name'] = Variable<String>(name);
    map['config'] = Variable<Uint8List>(config);
    return map;
  }

  HandlerSelectorsCompanion toCompanion(bool nullToAbsent) {
    return HandlerSelectorsCompanion(
      name: Value(name),
      config: Value(config),
    );
  }

  factory HandlerSelectorsData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HandlerSelectorsData(
      name: serializer.fromJson<String>(json['name']),
      config: serializer.fromJson<Uint8List>(json['config']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'name': serializer.toJson<String>(name),
      'config': serializer.toJson<Uint8List>(config),
    };
  }

  HandlerSelectorsData copyWith({String? name, Uint8List? config}) =>
      HandlerSelectorsData(
        name: name ?? this.name,
        config: config ?? this.config,
      );
  HandlerSelectorsData copyWithCompanion(HandlerSelectorsCompanion data) {
    return HandlerSelectorsData(
      name: data.name.present ? data.name.value : this.name,
      config: data.config.present ? data.config.value : this.config,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HandlerSelectorsData(')
          ..write('name: $name, ')
          ..write('config: $config')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(name, $driftBlobEquality.hash(config));
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HandlerSelectorsData &&
          other.name == this.name &&
          $driftBlobEquality.equals(other.config, this.config));
}

class HandlerSelectorsCompanion extends UpdateCompanion<HandlerSelectorsData> {
  final Value<String> name;
  final Value<Uint8List> config;
  final Value<int> rowid;
  const HandlerSelectorsCompanion({
    this.name = const Value.absent(),
    this.config = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  HandlerSelectorsCompanion.insert({
    required String name,
    required Uint8List config,
    this.rowid = const Value.absent(),
  })  : name = Value(name),
        config = Value(config);
  static Insertable<HandlerSelectorsData> custom({
    Expression<String>? name,
    Expression<Uint8List>? config,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (name != null) 'name': name,
      if (config != null) 'config': config,
      if (rowid != null) 'rowid': rowid,
    });
  }

  HandlerSelectorsCompanion copyWith(
      {Value<String>? name, Value<Uint8List>? config, Value<int>? rowid}) {
    return HandlerSelectorsCompanion(
      name: name ?? this.name,
      config: config ?? this.config,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (config.present) {
      map['config'] = Variable<Uint8List>(config.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HandlerSelectorsCompanion(')
          ..write('name: $name, ')
          ..write('config: $config, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class SelectorHandlerRelations extends Table
    with TableInfo<SelectorHandlerRelations, SelectorHandlerRelationsData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  SelectorHandlerRelations(this.attachedDatabase, [this._alias]);
  late final GeneratedColumn<String> selectorName = GeneratedColumn<String>(
      'selector_name', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES handler_selectors (name) ON DELETE CASCADE'));
  late final GeneratedColumn<int> handlerId = GeneratedColumn<int>(
      'handler_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES outbound_handlers (id) ON DELETE CASCADE'));
  @override
  List<GeneratedColumn> get $columns => [selectorName, handlerId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'selector_handler_relations';
  @override
  Set<GeneratedColumn> get $primaryKey => {selectorName, handlerId};
  @override
  SelectorHandlerRelationsData map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SelectorHandlerRelationsData(
      selectorName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}selector_name'])!,
      handlerId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}handler_id'])!,
    );
  }

  @override
  SelectorHandlerRelations createAlias(String alias) {
    return SelectorHandlerRelations(attachedDatabase, alias);
  }
}

class SelectorHandlerRelationsData extends DataClass
    implements Insertable<SelectorHandlerRelationsData> {
  final String selectorName;
  final int handlerId;
  const SelectorHandlerRelationsData(
      {required this.selectorName, required this.handlerId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['selector_name'] = Variable<String>(selectorName);
    map['handler_id'] = Variable<int>(handlerId);
    return map;
  }

  SelectorHandlerRelationsCompanion toCompanion(bool nullToAbsent) {
    return SelectorHandlerRelationsCompanion(
      selectorName: Value(selectorName),
      handlerId: Value(handlerId),
    );
  }

  factory SelectorHandlerRelationsData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SelectorHandlerRelationsData(
      selectorName: serializer.fromJson<String>(json['selectorName']),
      handlerId: serializer.fromJson<int>(json['handlerId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'selectorName': serializer.toJson<String>(selectorName),
      'handlerId': serializer.toJson<int>(handlerId),
    };
  }

  SelectorHandlerRelationsData copyWith(
          {String? selectorName, int? handlerId}) =>
      SelectorHandlerRelationsData(
        selectorName: selectorName ?? this.selectorName,
        handlerId: handlerId ?? this.handlerId,
      );
  SelectorHandlerRelationsData copyWithCompanion(
      SelectorHandlerRelationsCompanion data) {
    return SelectorHandlerRelationsData(
      selectorName: data.selectorName.present
          ? data.selectorName.value
          : this.selectorName,
      handlerId: data.handlerId.present ? data.handlerId.value : this.handlerId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SelectorHandlerRelationsData(')
          ..write('selectorName: $selectorName, ')
          ..write('handlerId: $handlerId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(selectorName, handlerId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SelectorHandlerRelationsData &&
          other.selectorName == this.selectorName &&
          other.handlerId == this.handlerId);
}

class SelectorHandlerRelationsCompanion
    extends UpdateCompanion<SelectorHandlerRelationsData> {
  final Value<String> selectorName;
  final Value<int> handlerId;
  final Value<int> rowid;
  const SelectorHandlerRelationsCompanion({
    this.selectorName = const Value.absent(),
    this.handlerId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SelectorHandlerRelationsCompanion.insert({
    required String selectorName,
    required int handlerId,
    this.rowid = const Value.absent(),
  })  : selectorName = Value(selectorName),
        handlerId = Value(handlerId);
  static Insertable<SelectorHandlerRelationsData> custom({
    Expression<String>? selectorName,
    Expression<int>? handlerId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (selectorName != null) 'selector_name': selectorName,
      if (handlerId != null) 'handler_id': handlerId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SelectorHandlerRelationsCompanion copyWith(
      {Value<String>? selectorName, Value<int>? handlerId, Value<int>? rowid}) {
    return SelectorHandlerRelationsCompanion(
      selectorName: selectorName ?? this.selectorName,
      handlerId: handlerId ?? this.handlerId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (selectorName.present) {
      map['selector_name'] = Variable<String>(selectorName.value);
    }
    if (handlerId.present) {
      map['handler_id'] = Variable<int>(handlerId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SelectorHandlerRelationsCompanion(')
          ..write('selectorName: $selectorName, ')
          ..write('handlerId: $handlerId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class SelectorHandlerGroupRelations extends Table
    with
        TableInfo<SelectorHandlerGroupRelations,
            SelectorHandlerGroupRelationsData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  SelectorHandlerGroupRelations(this.attachedDatabase, [this._alias]);
  late final GeneratedColumn<String> selectorName = GeneratedColumn<String>(
      'selector_name', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES handler_selectors (name) ON DELETE CASCADE'));
  late final GeneratedColumn<String> groupName = GeneratedColumn<String>(
      'group_name', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES outbound_handler_groups (name) ON DELETE CASCADE'));
  @override
  List<GeneratedColumn> get $columns => [selectorName, groupName];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'selector_handler_group_relations';
  @override
  Set<GeneratedColumn> get $primaryKey => {selectorName, groupName};
  @override
  SelectorHandlerGroupRelationsData map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SelectorHandlerGroupRelationsData(
      selectorName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}selector_name'])!,
      groupName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}group_name'])!,
    );
  }

  @override
  SelectorHandlerGroupRelations createAlias(String alias) {
    return SelectorHandlerGroupRelations(attachedDatabase, alias);
  }
}

class SelectorHandlerGroupRelationsData extends DataClass
    implements Insertable<SelectorHandlerGroupRelationsData> {
  final String selectorName;
  final String groupName;
  const SelectorHandlerGroupRelationsData(
      {required this.selectorName, required this.groupName});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['selector_name'] = Variable<String>(selectorName);
    map['group_name'] = Variable<String>(groupName);
    return map;
  }

  SelectorHandlerGroupRelationsCompanion toCompanion(bool nullToAbsent) {
    return SelectorHandlerGroupRelationsCompanion(
      selectorName: Value(selectorName),
      groupName: Value(groupName),
    );
  }

  factory SelectorHandlerGroupRelationsData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SelectorHandlerGroupRelationsData(
      selectorName: serializer.fromJson<String>(json['selectorName']),
      groupName: serializer.fromJson<String>(json['groupName']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'selectorName': serializer.toJson<String>(selectorName),
      'groupName': serializer.toJson<String>(groupName),
    };
  }

  SelectorHandlerGroupRelationsData copyWith(
          {String? selectorName, String? groupName}) =>
      SelectorHandlerGroupRelationsData(
        selectorName: selectorName ?? this.selectorName,
        groupName: groupName ?? this.groupName,
      );
  SelectorHandlerGroupRelationsData copyWithCompanion(
      SelectorHandlerGroupRelationsCompanion data) {
    return SelectorHandlerGroupRelationsData(
      selectorName: data.selectorName.present
          ? data.selectorName.value
          : this.selectorName,
      groupName: data.groupName.present ? data.groupName.value : this.groupName,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SelectorHandlerGroupRelationsData(')
          ..write('selectorName: $selectorName, ')
          ..write('groupName: $groupName')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(selectorName, groupName);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SelectorHandlerGroupRelationsData &&
          other.selectorName == this.selectorName &&
          other.groupName == this.groupName);
}

class SelectorHandlerGroupRelationsCompanion
    extends UpdateCompanion<SelectorHandlerGroupRelationsData> {
  final Value<String> selectorName;
  final Value<String> groupName;
  final Value<int> rowid;
  const SelectorHandlerGroupRelationsCompanion({
    this.selectorName = const Value.absent(),
    this.groupName = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SelectorHandlerGroupRelationsCompanion.insert({
    required String selectorName,
    required String groupName,
    this.rowid = const Value.absent(),
  })  : selectorName = Value(selectorName),
        groupName = Value(groupName);
  static Insertable<SelectorHandlerGroupRelationsData> custom({
    Expression<String>? selectorName,
    Expression<String>? groupName,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (selectorName != null) 'selector_name': selectorName,
      if (groupName != null) 'group_name': groupName,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SelectorHandlerGroupRelationsCompanion copyWith(
      {Value<String>? selectorName,
      Value<String>? groupName,
      Value<int>? rowid}) {
    return SelectorHandlerGroupRelationsCompanion(
      selectorName: selectorName ?? this.selectorName,
      groupName: groupName ?? this.groupName,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (selectorName.present) {
      map['selector_name'] = Variable<String>(selectorName.value);
    }
    if (groupName.present) {
      map['group_name'] = Variable<String>(groupName.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SelectorHandlerGroupRelationsCompanion(')
          ..write('selectorName: $selectorName, ')
          ..write('groupName: $groupName, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class SelectorSubscriptionRelations extends Table
    with
        TableInfo<SelectorSubscriptionRelations,
            SelectorSubscriptionRelationsData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  SelectorSubscriptionRelations(this.attachedDatabase, [this._alias]);
  late final GeneratedColumn<String> selectorName = GeneratedColumn<String>(
      'selector_name', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES handler_selectors (name) ON DELETE CASCADE'));
  late final GeneratedColumn<int> subscriptionId = GeneratedColumn<int>(
      'subscription_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES subscriptions (id) ON DELETE CASCADE'));
  @override
  List<GeneratedColumn> get $columns => [selectorName, subscriptionId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'selector_subscription_relations';
  @override
  Set<GeneratedColumn> get $primaryKey => {selectorName, subscriptionId};
  @override
  SelectorSubscriptionRelationsData map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SelectorSubscriptionRelationsData(
      selectorName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}selector_name'])!,
      subscriptionId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}subscription_id'])!,
    );
  }

  @override
  SelectorSubscriptionRelations createAlias(String alias) {
    return SelectorSubscriptionRelations(attachedDatabase, alias);
  }
}

class SelectorSubscriptionRelationsData extends DataClass
    implements Insertable<SelectorSubscriptionRelationsData> {
  final String selectorName;
  final int subscriptionId;
  const SelectorSubscriptionRelationsData(
      {required this.selectorName, required this.subscriptionId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['selector_name'] = Variable<String>(selectorName);
    map['subscription_id'] = Variable<int>(subscriptionId);
    return map;
  }

  SelectorSubscriptionRelationsCompanion toCompanion(bool nullToAbsent) {
    return SelectorSubscriptionRelationsCompanion(
      selectorName: Value(selectorName),
      subscriptionId: Value(subscriptionId),
    );
  }

  factory SelectorSubscriptionRelationsData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SelectorSubscriptionRelationsData(
      selectorName: serializer.fromJson<String>(json['selectorName']),
      subscriptionId: serializer.fromJson<int>(json['subscriptionId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'selectorName': serializer.toJson<String>(selectorName),
      'subscriptionId': serializer.toJson<int>(subscriptionId),
    };
  }

  SelectorSubscriptionRelationsData copyWith(
          {String? selectorName, int? subscriptionId}) =>
      SelectorSubscriptionRelationsData(
        selectorName: selectorName ?? this.selectorName,
        subscriptionId: subscriptionId ?? this.subscriptionId,
      );
  SelectorSubscriptionRelationsData copyWithCompanion(
      SelectorSubscriptionRelationsCompanion data) {
    return SelectorSubscriptionRelationsData(
      selectorName: data.selectorName.present
          ? data.selectorName.value
          : this.selectorName,
      subscriptionId: data.subscriptionId.present
          ? data.subscriptionId.value
          : this.subscriptionId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SelectorSubscriptionRelationsData(')
          ..write('selectorName: $selectorName, ')
          ..write('subscriptionId: $subscriptionId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(selectorName, subscriptionId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SelectorSubscriptionRelationsData &&
          other.selectorName == this.selectorName &&
          other.subscriptionId == this.subscriptionId);
}

class SelectorSubscriptionRelationsCompanion
    extends UpdateCompanion<SelectorSubscriptionRelationsData> {
  final Value<String> selectorName;
  final Value<int> subscriptionId;
  final Value<int> rowid;
  const SelectorSubscriptionRelationsCompanion({
    this.selectorName = const Value.absent(),
    this.subscriptionId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SelectorSubscriptionRelationsCompanion.insert({
    required String selectorName,
    required int subscriptionId,
    this.rowid = const Value.absent(),
  })  : selectorName = Value(selectorName),
        subscriptionId = Value(subscriptionId);
  static Insertable<SelectorSubscriptionRelationsData> custom({
    Expression<String>? selectorName,
    Expression<int>? subscriptionId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (selectorName != null) 'selector_name': selectorName,
      if (subscriptionId != null) 'subscription_id': subscriptionId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SelectorSubscriptionRelationsCompanion copyWith(
      {Value<String>? selectorName,
      Value<int>? subscriptionId,
      Value<int>? rowid}) {
    return SelectorSubscriptionRelationsCompanion(
      selectorName: selectorName ?? this.selectorName,
      subscriptionId: subscriptionId ?? this.subscriptionId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (selectorName.present) {
      map['selector_name'] = Variable<String>(selectorName.value);
    }
    if (subscriptionId.present) {
      map['subscription_id'] = Variable<int>(subscriptionId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SelectorSubscriptionRelationsCompanion(')
          ..write('selectorName: $selectorName, ')
          ..write('subscriptionId: $subscriptionId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class DnsServers extends Table with TableInfo<DnsServers, DnsServersData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  DnsServers(this.attachedDatabase, [this._alias]);
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
  late final GeneratedColumn<Uint8List> dnsServer = GeneratedColumn<Uint8List>(
      'dns_server', aliasedName, false,
      type: DriftSqlType.blob, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, name, dnsServer];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'dns_servers';
  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DnsServersData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DnsServersData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      dnsServer: attachedDatabase.typeMapping
          .read(DriftSqlType.blob, data['${effectivePrefix}dns_server'])!,
    );
  }

  @override
  DnsServers createAlias(String alias) {
    return DnsServers(attachedDatabase, alias);
  }
}

class DnsServersData extends DataClass implements Insertable<DnsServersData> {
  final int id;
  final String name;
  final Uint8List dnsServer;
  const DnsServersData(
      {required this.id, required this.name, required this.dnsServer});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['dns_server'] = Variable<Uint8List>(dnsServer);
    return map;
  }

  DnsServersCompanion toCompanion(bool nullToAbsent) {
    return DnsServersCompanion(
      id: Value(id),
      name: Value(name),
      dnsServer: Value(dnsServer),
    );
  }

  factory DnsServersData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DnsServersData(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      dnsServer: serializer.fromJson<Uint8List>(json['dnsServer']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'dnsServer': serializer.toJson<Uint8List>(dnsServer),
    };
  }

  DnsServersData copyWith({int? id, String? name, Uint8List? dnsServer}) =>
      DnsServersData(
        id: id ?? this.id,
        name: name ?? this.name,
        dnsServer: dnsServer ?? this.dnsServer,
      );
  DnsServersData copyWithCompanion(DnsServersCompanion data) {
    return DnsServersData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      dnsServer: data.dnsServer.present ? data.dnsServer.value : this.dnsServer,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DnsServersData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('dnsServer: $dnsServer')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, $driftBlobEquality.hash(dnsServer));
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DnsServersData &&
          other.id == this.id &&
          other.name == this.name &&
          $driftBlobEquality.equals(other.dnsServer, this.dnsServer));
}

class DnsServersCompanion extends UpdateCompanion<DnsServersData> {
  final Value<int> id;
  final Value<String> name;
  final Value<Uint8List> dnsServer;
  const DnsServersCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.dnsServer = const Value.absent(),
  });
  DnsServersCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required Uint8List dnsServer,
  })  : name = Value(name),
        dnsServer = Value(dnsServer);
  static Insertable<DnsServersData> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<Uint8List>? dnsServer,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (dnsServer != null) 'dns_server': dnsServer,
    });
  }

  DnsServersCompanion copyWith(
      {Value<int>? id, Value<String>? name, Value<Uint8List>? dnsServer}) {
    return DnsServersCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      dnsServer: dnsServer ?? this.dnsServer,
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
    if (dnsServer.present) {
      map['dns_server'] = Variable<Uint8List>(dnsServer.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DnsServersCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('dnsServer: $dnsServer')
          ..write(')'))
        .toString();
  }
}

class DatabaseAtV5 extends GeneratedDatabase {
  DatabaseAtV5(QueryExecutor e) : super(e);
  late final Subscriptions subscriptions = Subscriptions(this);
  late final OutboundHandlers outboundHandlers = OutboundHandlers(this);
  late final OutboundHandlerGroups outboundHandlerGroups =
      OutboundHandlerGroups(this);
  late final OutboundHandlerGroupRelations outboundHandlerGroupRelations =
      OutboundHandlerGroupRelations(this);
  late final DnsRecords dnsRecords = DnsRecords(this);
  late final AtomicDomainSets atomicDomainSets = AtomicDomainSets(this);
  late final GeoDomains geoDomains = GeoDomains(this);
  late final GreatDomainSets greatDomainSets = GreatDomainSets(this);
  late final AtomicIpSets atomicIpSets = AtomicIpSets(this);
  late final GreatIpSets greatIpSets = GreatIpSets(this);
  late final AppSets appSets = AppSets(this);
  late final Apps apps = Apps(this);
  late final Cidrs cidrs = Cidrs(this);
  late final SshServers sshServers = SshServers(this);
  late final CommonSshKeys commonSshKeys = CommonSshKeys(this);
  late final CustomRouteModes customRouteModes = CustomRouteModes(this);
  late final HandlerSelectors handlerSelectors = HandlerSelectors(this);
  late final SelectorHandlerRelations selectorHandlerRelations =
      SelectorHandlerRelations(this);
  late final SelectorHandlerGroupRelations selectorHandlerGroupRelations =
      SelectorHandlerGroupRelations(this);
  late final SelectorSubscriptionRelations selectorSubscriptionRelations =
      SelectorSubscriptionRelations(this);
  late final DnsServers dnsServers = DnsServers(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        subscriptions,
        outboundHandlers,
        outboundHandlerGroups,
        outboundHandlerGroupRelations,
        dnsRecords,
        atomicDomainSets,
        geoDomains,
        greatDomainSets,
        atomicIpSets,
        greatIpSets,
        appSets,
        apps,
        cidrs,
        sshServers,
        commonSshKeys,
        customRouteModes,
        handlerSelectors,
        selectorHandlerRelations,
        selectorHandlerGroupRelations,
        selectorSubscriptionRelations,
        dnsServers
      ];
  @override
  int get schemaVersion => 5;
}
