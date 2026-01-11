import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:tm/protos/common/geo/geo.pb.dart';
import 'package:tm/protos/protos/dns.pb.dart';
import 'package:tm/protos/protos/geo.pb.dart';
import 'package:tm/protos/protos/router.pb.dart';
import 'package:vx/data/database.dart';
import 'package:vx/main.dart' hide App;
import 'package:vx/utils/random.dart';

abstract class SelectorRepo with ChangeNotifier {
  Future<void> addSelector(SelectorConfig selector);
  Future<void> removeSelector(String selectorName);
  Future<void> updateSelector(SelectorConfig selector);
  Future<void> addSubscriptionToSelector(
      String selectorName, int subscriptionId);
  Future<void> removeSubscriptionFromSelector(
      String selectorName, int subscriptionId);
  Future<void> addHandlerGroupToSelector(String selectorName, String groupName);
  Future<void> removeHandlerGroupFromSelector(
      String selectorName, String groupName);
  Future<void> addHandlerToSelector(String selectorName, int handlerId);
  Future<void> removeHandlerFromSelector(String selectorName, int handlerId);

  Future<List<SelectorConfig>> getAllSelectors();
  Stream<List<SelectorConfig>> getSelectorsStream();
}

abstract class RouteRepo with ChangeNotifier {
  Stream<List<CustomRouteMode>> getCustomRouteModesStream();
  Future<List<CustomRouteMode>> getAllCustomRouteModes();
  Future<void> updateCustomRouteMode(int id,
      {RouterConfig? routerConfig, DnsRules? dnsRules, String? name});
  Future<CustomRouteMode?> addCustomRouteMode(CustomRouteMode mode);
}

abstract class SetRepo with ChangeNotifier {
  Future<void> addGeoDomain(String domainSetName, Domain domain);
  Future<void> bulkAddGeoDomain(String domainSetName, List<Domain> domains);
  Stream<List<GeoDomain>> getGeoDomainsStream(String domainSetName);
  Future<void> removeGeoDomain(GeoDomain geoDomain);
  Future<void> removeGreatDomainSet(String domainSetName);
  Future<void> removeAtomicDomainSet(String domainSetName);
  Future<void> addGreatDomainSet(GreatDomainSetConfig greatDomainSet);
  Stream<List<GreatDomainSet>> getGreatDomainSetsStream();
  Stream<List<AtomicDomainSet>> getAtomicDomainSetsStream();
  Future<void> addAtomicDomainSet(AtomicDomainSet atomicDomainSet);
  Future<void> updateAtomicDomainSet(String name,
      {GeositeConfig? geositeConfig,
      List<String>? clashRuleUrls,
      bool? useBloomFilter,
      String? geoUrl});
  Future<void> updateGreateDomainSet(String name,
      {GreatDomainSetConfig? greatDomainSet});

  Future<void> addCidr(String ipSetName, CIDR cidr);
  Future<void> bulkAddCidr(String ipSetName, List<CIDR> cidrs);
  Stream<List<Cidr>> getCidrsStream(String ipSetName);
  Future<void> removeCidr(Cidr cidr);
  Future<void> addGreatIpSet(GreatIPSetConfig greatIpSet);
  Future<void> updateGreatIpSet(String name, {GreatIPSetConfig? greatIpSet});
  Future<void> removeGreatIpSet(String ipSetName);
  Future<void> addAtomicIpSet(AtomicIpSet atomicIpSet);
  Future<void> updateAtomicIpSet(String name,
      {GeoIPConfig? geoIpConfig, List<String>? clashRuleUrls, String? geoUrl});
  Future<void> removeAtomicIpSet(String ipSetName);
  Stream<List<GreatIpSet>> getGreatIpSetsStream();
  Stream<List<AtomicIpSet>> getAtomicIpSetsStream();

  Future<void> addApp(String appSetName, AppId app, {Uint8List? icon});
  Future<void> addApps(List<App> apps);
  Stream<List<App>> getAppsStream(String appSetName);
  Future<List<App>> getApps(String appSetName);
  Future<void> removeApp(List<int> ids);
  Future<void> addAppSet(AppSet appSet);
  Future<void> updateAppSet(String name, {List<String>? clashRuleUrls});
  Future<void> removeAppSet(String appSetName);
  Stream<List<AppSet>> getAppSetsStream();
}

abstract class DnsRepo with ChangeNotifier {
  Future<List<DnsServer>> getDnsServers();
  Future<DnsServer> addDnsServer(
      String dnsServerName, DnsServerConfig dnsServer);
  Future<void> updateDnsServer(DnsServer ds,
      {String? dnsServerName, DnsServerConfig? dnsServer});
  Future<void> removeDnsServer(DnsServer ds);
  Stream<List<DnsServer>> getDnsServersStream();
}

class DbHelper
    with ChangeNotifier
    implements SelectorRepo, RouteRepo, SetRepo, DnsRepo {
  DbHelper();

  reset() {
    notifyListeners();
  }

  Future<List<AtomicIpSet>> getAtomicIpSets() async {
    return await database.managers.atomicIpSets.get();
  }

  Future<List<AtomicDomainSet>> getAtomicDomainSets() async {
    return await database.managers.atomicDomainSets.get();
  }

  Future<List<GreatDomainSet>> getGreatDomainSets() async {
    return await database.managers.greatDomainSets.get();
  }

  Future<List<AppSet>> getAppSets() async {
    return await database.managers.appSets.get();
  }

  @override
  Stream<List<DnsServer>> getDnsServersStream() {
    return database.select(database.dnsServers).watch();
  }

  @override
  Stream<List<SelectorConfig>> getSelectorsStream() {
    return database.select(database.handlerSelectors).watch().asyncMap((q) {
      return Future.wait(q.map((e) {
        return database.selectorToConfig(e);
      }));
    });
  }

  @override
  Stream<List<CustomRouteMode>> getCustomRouteModesStream() {
    return database.select(database.customRouteModes).watch();
  }

  @override
  Stream<List<GreatDomainSet>> getGreatDomainSetsStream() {
    return database.select(database.greatDomainSets).watch();
  }

  @override
  Stream<List<AtomicDomainSet>> getAtomicDomainSetsStream() {
    return database.select(database.atomicDomainSets).watch();
  }

  @override
  Stream<List<AppSet>> getAppSetsStream() {
    return database.select(database.appSets).watch();
  }

  @override
  Future<void> removeSelector(String selectorName) async {
    await database.syncDeleteName(database.handlerSelectors, selectorName);
  }

  @override
  Future<void> updateSelector(SelectorConfig selector) async {
    await database.syncUpdateName(
      database.handlerSelectors,
      selector.tag,
      HandlerSelectorsCompanion(config: Value(selector)),
    );
  }

  @override
  Future<void> addGreatIpSet(GreatIPSetConfig greatIpSet) async {
    await database.syncInsertReturning(
        database.greatIpSets,
        GreatIpSetsCompanion(
            name: Value(greatIpSet.name), greatIpSetConfig: Value(greatIpSet)));
    // await database.managers.greatIpSets.create(
    //     (o) => o(name: greatIpSet.name, greatIpSetConfig: greatIpSet),
    //     mode: InsertMode.insert);
  }

  @override
  Future<void> updateGreatIpSet(String name,
      {GreatIPSetConfig? greatIpSet, String? newName}) async {
    await database.syncUpdateName(
        database.greatIpSets,
        name,
        GreatIpSetsCompanion(
            name: newName != null ? Value(newName) : const Value.absent(),
            greatIpSetConfig:
                greatIpSet != null ? Value(greatIpSet) : const Value.absent()));
    // await database.managers.greatIpSets
    //     .filter((f) => f.name.equals(name))
    //     .update((o) => o(
    //         name: newName != null ? Value(newName) : const Value.absent(),
    //         greatIpSetConfig:
    //             greatIpSet != null ? Value(greatIpSet) : const Value.absent()));
  }

  @override
  Future<void> removeGreatIpSet(String ipSetName) async {
    await database.syncDeleteName(database.greatIpSets, ipSetName);
    // await database.managers.greatIpSets
    //     .filter((f) => f.name.equals(ipSetName))
    //     .delete();
  }

  @override
  Future<void> addAtomicIpSet(AtomicIpSet config) async {
    await database.syncInsertReturning(
      database.atomicIpSets,
      AtomicIpSetsCompanion(
        name: Value(config.name),
        geoIpConfig: Value(config.geoIpConfig),
        clashRuleUrls: Value(config.clashRuleUrls),
        geoUrl: Value(config.geoUrl),
      ),
      mode: InsertMode.insertOrReplace,
    );
  }

  @override
  Future<void> updateAtomicIpSet(String name,
      {GeoIPConfig? geoIpConfig,
      List<String>? clashRuleUrls,
      String? newName,
      String? geoUrl}) async {
    await database.syncUpdateName(
      database.atomicIpSets,
      name,
      AtomicIpSetsCompanion(
        name: newName != null ? Value(newName) : const Value.absent(),
        geoIpConfig:
            geoIpConfig != null ? Value(geoIpConfig) : const Value.absent(),
        clashRuleUrls:
            clashRuleUrls != null ? Value(clashRuleUrls) : const Value.absent(),
        geoUrl: geoUrl != null ? Value(geoUrl) : const Value.absent(),
      ),
    );
  }

  @override
  Future<void> removeAtomicIpSet(String ipSetName) async {
    await database.syncDeleteName(database.atomicIpSets, ipSetName);
    // await database.managers.atomicIpSets
    //     .filter((f) => f.name.equals(ipSetName))
    //     .delete();
  }

  @override
  Future<void> addAppSet(AppSet appSet) async {
    // final data = AppSetsCompanion(
    //   name: Value(appSet.name),
    //   clashRuleUrls: Value(appSet.clashRuleUrls),
    // );
    // await database.into(database.appSets).insertOnConflictUpdate(data);
    await database.syncInsertReturning(
      database.appSets,
      AppSetsCompanion(
        name: Value(appSet.name),
        clashRuleUrls: Value(appSet.clashRuleUrls),
      ),
      mode: InsertMode.insertOrReplace,
    );
  }

  @override
  Future<void> updateAppSet(String name, {List<String>? clashRuleUrls}) async {
    await database.syncUpdateName(
        database.appSets,
        name,
        AppSetsCompanion(
            clashRuleUrls: clashRuleUrls != null
                ? Value(clashRuleUrls)
                : const Value.absent()));
  }

  @override
  Future<void> removeAppSet(String appSetName) async {
    await database.syncDeleteName(database.appSets, appSetName);
    // await database.managers.appSets
    //     .filter((f) => f.name.equals(appSetName))
    //     .delete();
  }

  @override
  Future<void> removeAtomicDomainSet(String domainSetName) async {
    await database.syncDeleteName(database.atomicDomainSets, domainSetName);
    // await database.managers.atomicDomainSets
    //     .filter((f) => f.name.equals(domainSetName))
    //     .delete();
  }

  @override
  Future<void> removeGreatDomainSet(String domainSetName) async {
    // await database.managers.greatDomainSets
    //     .filter((f) => f.name.equals(domainSetName))
    //     .delete();
    await database.syncDeleteName(database.greatDomainSets, domainSetName);
  }

  @override
  Future<void> addAtomicDomainSet(AtomicDomainSet config) async {
    await database.syncInsertReturning(
      database.atomicDomainSets,
      AtomicDomainSetsCompanion(
        name: Value(config.name),
        geositeConfig: Value(config.geositeConfig),
        clashRuleUrls: Value(config.clashRuleUrls),
        useBloomFilter: Value(config.useBloomFilter),
        geoUrl: Value(config.geoUrl),
      ),
    );
    // await database.managers.atomicDomainSets.create(
    //     (o) => o(
    //         name: config.name,
    //         geositeConfig: Value(config.geositeConfig),
    //         clashRuleUrls: Value(config.clashRuleUrls),
    //         useBloomFilter: Value(config.useBloomFilter)),
    //     mode: InsertMode.insert);
  }

  @override
  Future<void> updateAtomicDomainSet(String name,
      {GeositeConfig? geositeConfig,
      List<String>? clashRuleUrls,
      bool? useBloomFilter,
      String? geoUrl}) async {
    // await database.managers.atomicDomainSets
    //     .filter((f) => f.name.equals(name))
    //     .update((o) => o(
    //         name: newName != null ? Value(newName) : const Value.absent(),
    //         geositeConfig: geositeConfig != null
    //             ? Value(geositeConfig)
    //             : const Value.absent(),
    //         clashRuleUrls: clashRuleUrls != null
    //             ? Value(clashRuleUrls)
    //             : const Value.absent(),
    //         useBloomFilter: useBloomFilter != null
    //             ? Value(useBloomFilter)
    //             : const Value.absent()));
    await database.syncUpdateName(
      database.atomicDomainSets,
      name,
      AtomicDomainSetsCompanion(
        geositeConfig:
            geositeConfig != null ? Value(geositeConfig) : const Value.absent(),
        clashRuleUrls:
            clashRuleUrls != null ? Value(clashRuleUrls) : const Value.absent(),
        useBloomFilter: useBloomFilter != null
            ? Value(useBloomFilter)
            : const Value.absent(),
        geoUrl: geoUrl != null ? Value(geoUrl) : const Value.absent(),
      ),
    );
  }

  @override
  Future<void> addGreatDomainSet(GreatDomainSetConfig config) async {
    // await database.managers.greatDomainSets.create(
    //     (o) => o(
    //         name: config.name,
    //         set: config,
    //         oppositeName: Value(config.oppositeName)),
    //     mode: InsertMode.insert);
    await database.syncInsertReturning(
      database.greatDomainSets,
      GreatDomainSetsCompanion(
        name: Value(config.name),
        set: Value(config),
        oppositeName: Value(config.oppositeName),
      ),
    );
  }

  @override
  Future<void> updateGreateDomainSet(String name,
      {GreatDomainSetConfig? greatDomainSet}) async {
    // await database.managers.greatDomainSets
    //     .filter((f) => f.name.equals(name))
    //     .update((o) => o(
    //           name: newName != null ? Value(newName) : const Value.absent(),
    //           oppositeName: greatDomainSet != null
    //               ? Value(greatDomainSet.oppositeName)
    //               : const Value.absent(),
    //           set: greatDomainSet != null
    //               ? Value(greatDomainSet)
    //               : const Value.absent(),
    //         ));
    await database.syncUpdateName(
      database.greatDomainSets,
      name,
      GreatDomainSetsCompanion(
        oppositeName: greatDomainSet != null
            ? Value(greatDomainSet.oppositeName)
            : const Value.absent(),
        set: greatDomainSet != null
            ? Value(greatDomainSet)
            : const Value.absent(),
      ),
    );
  }

  // RouteRepo
  @override
  Future<List<CustomRouteMode>> getAllCustomRouteModes() async {
    return await database.managers.customRouteModes.get();
  }

  @override
  Future<CustomRouteMode?> addCustomRouteMode(CustomRouteMode mode) async {
    // final data = CustomRouteModesCompanion(
    //   id: Value(mode.id),
    //   name: Value(mode.name),
    //   routerConfig: Value(mode.routerConfig),
    //   dnsRules: Value(mode.dnsRules),
    // );
    // final ret = await database
    //     .into(database.customRouteModes)
    //     .insertReturningOrNull(data, mode: InsertMode.insertOrIgnore);
    final ret = await database.syncInsertReturning(
      database.customRouteModes,
      CustomRouteModesCompanion(
        id: Value(mode.id),
        name: Value(mode.name),
        routerConfig: Value(mode.routerConfig),
        dnsRules: Value(mode.dnsRules),
      ),
    );
    return ret;
  }

  @override
  Future<void> updateCustomRouteMode(
    int id, {
    RouterConfig? routerConfig,
    DnsRules? dnsRules,
    String? name,
  }) async {
    // await database.managers.customRouteModes
    //     .filter((e) => e.id(id))
    //     .update((o) => o(
    //           routerConfig: routerConfig != null
    //               ? Value(routerConfig)
    //               : const Value.absent(),
    //           dnsRules:
    //               dnsRules != null ? Value(dnsRules) : const Value.absent(),
    //           name: name != null ? Value(name) : const Value.absent(),
    //         ));
    await database.syncUpdateId(
      database.customRouteModes,
      id,
      CustomRouteModesCompanion(
        routerConfig:
            routerConfig != null ? Value(routerConfig) : const Value.absent(),
        dnsRules: dnsRules != null ? Value(dnsRules) : const Value.absent(),
        name: name != null ? Value(name) : const Value.absent(),
      ),
    );
  }

  // DnsRepo
  @override
  Future<List<DnsServer>> getDnsServers() async {
    return await database.managers.dnsServers.get();
  }

  @override
  Future<void> updateDnsServer(DnsServer ds,
      {String? dnsServerName, DnsServerConfig? dnsServer}) async {
    // await database.managers.dnsServers.filter((f) => f.id(ds.id)).update((o) =>
    //     o(
    //         name: dnsServerName != null
    //             ? Value(dnsServerName)
    //             : const Value.absent(),
    //         dnsServer:
    //             dnsServer != null ? Value(dnsServer) : const Value.absent()));
    await database.syncUpdateId(
      database.dnsServers,
      ds.id,
      DnsServersCompanion(
        name:
            dnsServerName != null ? Value(dnsServerName) : const Value.absent(),
        dnsServer: dnsServer != null ? Value(dnsServer) : const Value.absent(),
      ),
    );
  }

  @override
  Future<DnsServer> addDnsServer(
      String dnsServerName, DnsServerConfig dnsServer) async {
    // final data = DnsServersCompanion(
    //   name: Value(dnsServerName),
    //   dnsServer: Value(dnsServer),
    // );
    // return await database.into(database.dnsServers).insertReturning(data);
    return await database.syncInsertReturning(
      database.dnsServers,
      DnsServersCompanion(
        id: Value(SnowflakeId.generate()),
        name: Value(dnsServerName),
        dnsServer: Value(dnsServer),
      ),
    );
  }

  @override
  Future<void> removeDnsServer(DnsServer ds) async {
    // await database.managers.dnsServers.filter((f) => f.name(ds.name)).delete();
    await database.syncDeleteName(database.dnsServers, ds.name);
  }

  // GeoRepo
  @override
  Future<void> addGeoDomain(String setName, Domain d) async {
    await database.syncInsertReturning(
      database.geoDomains,
      GeoDomainsCompanion(
        geoDomain: Value(d),
        domainSetName: Value(setName),
      ),
    );
    // final data =
    //     GeoDomainsCompanion(geoDomain: Value(d), domainSetName: Value(setName));
    // await database
    //     .into(database.geoDomains)
    //     .insert(data, mode: InsertMode.insertOrIgnore);
    // } on DriftRemoteException catch (e) {
    //                       if (e.remoteCause is SqliteException &&
    //                           (e.remoteCause as SqliteException)
    //                                   .extendedResultCode ==
    //                               2067) {
    //                         snack(
    //                             rootLocalizations()?.addFailedUniqueConstraint);
    //                       }
    //                     } catch (e) {
  }

  @override
  Stream<List<GeoDomain>> getGeoDomainsStream(String domainSetName) {
    return (database.select(database.geoDomains)
          ..where((t) => t.domainSetName.equals(domainSetName)))
        .watch();
  }

  @override
  Future<void> bulkAddGeoDomain(
      String domainSetName, List<Domain> domains) async {
    await database.transactionInsertSync(
        database.geoDomains,
        domains
            .map((e) => GeoDomainsCompanion(
                  geoDomain: Value(e),
                  domainSetName: Value(domainSetName),
                ))
            .toList());
    // await database.managers.geoDomains.bulkCreate((o) => [
    //       ...domains.map((e) => o(
    //             geoDomain: e,
    //             domainSetName: domainSetName,
    //           )),
    //     ]);
  }

  @override
  Future<void> removeGeoDomain(GeoDomain geoDomain) async {
    // await (database.delete(database.geoDomains)
    //       ..where((t) => t.id.equals(geoDomain.id)))
    //     .go();
    await database.syncDeleteId(database.geoDomains, [geoDomain.id]);
  }

  @override
  Future<void> addCidr(String ipSetName, CIDR cidr) async {
    // final data = CidrsCompanion(
    //   cidr: Value(cidr),
    //   ipSetName: Value(ipSetName),
    // );
    // await database
    //     .into(database.cidrs)
    //     .insert(data, mode: InsertMode.insertOrIgnore);
    await database.syncInsertReturning(
      database.cidrs,
      CidrsCompanion(
        cidr: Value(cidr),
        ipSetName: Value(ipSetName),
      ),
    );
  }

  @override
  Future<void> bulkAddCidr(String ipSetName, List<CIDR> cidrs) async {
    // await database.transaction(() async {
    //   for (var cidr in cidrs) {
    //     final data = CidrsCompanion(
    //       ipSetName: Value(ipSetName),
    //       cidr: Value(cidr),
    //     );
    //     await database
    //         .into(database.cidrs)
    //         .insert(data, mode: InsertMode.insertOrIgnore);
    //   }
    // });
    await database.transactionInsertSync(
        database.cidrs,
        cidrs
            .map((e) => CidrsCompanion(
                  ipSetName: Value(ipSetName),
                  cidr: Value(e),
                ))
            .toList());
  }

  @override
  Future<void> removeCidr(Cidr cidr) async {
    // await (database.delete(database.cidrs)..where((t) => t.id.equals(cidr.id)))
    //     .go();
    await database.syncDeleteId(database.cidrs, [cidr.id]);
  }

  @override
  Stream<List<Cidr>> getCidrsStream(String ipSetName) {
    return (database.select(database.cidrs)
          ..where((t) => t.ipSetName.equals(ipSetName)))
        .watch();
  }

  @override
  Future<void> addApp(String appSetName, AppId app, {Uint8List? icon}) async {
    // only keyword type is synced
    if (app.type == AppId_Type.Keyword) {
      await database.syncInsertReturning(
        database.apps,
        AppsCompanion(
          appId: Value(app),
          appSetName: Value(appSetName),
          icon: icon != null ? Value(icon) : const Value.absent(),
        ),
      );
    } else {
      final data = AppsCompanion(
          appId: Value(app),
          appSetName: Value(appSetName),
          icon: icon != null ? Value(icon) : const Value.absent());
      await database
          .into(database.apps)
          .insert(data, mode: InsertMode.insertOrIgnore);
    }
  }

  @override
  Future<void> addApps(List<App> apps) async {
    // await database.managers.apps.bulkCreate((o) => [
    //       ...apps.map((e) => o(
    //             appSetName: e.appSetName,
    //             appId: e.appId,
    //             icon: e.icon != null ? Value(e.icon!) : const Value.absent(),
    //           )),
    //     ]);
    await database.transactionInsertSync(
        database.apps,
        apps
            .map((e) => AppsCompanion(
                  appSetName: Value(e.appSetName),
                  appId: Value(e.appId),
                  icon: e.icon != null ? Value(e.icon!) : const Value.absent(),
                ))
            .toList());
  }

  @override
  Stream<List<App>> getAppsStream(String appSetName) {
    return (database.select(database.apps)
          ..where((t) => t.appSetName.equals(appSetName)))
        .watch()
        .map((query) => query.toList());
  }

  @override
  Future<List<App>> getApps(String appSetName) async {
    return await (database.select(database.apps)
          ..where((t) => t.appSetName.equals(appSetName)))
        .get();
  }

  @override
  Future<void> removeApp(List<int> ids) async {
    // await (database.delete(database.apps)..where((t) => t.id.equals(id))).go();
    await database.syncDeleteId(database.apps, ids);
  }

  // SelectorRepo
  @override
  Future<List<SelectorConfig>> getAllSelectors() async {
    final selectors = await database.managers.handlerSelectors.get();
    final configs = <SelectorConfig>[];
    for (var selector in selectors) {
      configs.add(await database.selectorToConfig(selector));
    }
    return configs;
  }

  @override
  Future<void> addSubscriptionToSelector(
      String selectorName, int subscriptionId) async {
    await database.syncInsertReturning(
        database.selectorSubscriptionRelations,
        SelectorSubscriptionRelationsCompanion(
          id: Value(SnowflakeId.generate()),
          selectorName: Value(selectorName),
          subscriptionId: Value(subscriptionId),
        ));
  }

  @override
  Future<void> removeSubscriptionFromSelector(
      String selectorName, int subscriptionId) async {
    final relation =
        await ((database.select(database.selectorSubscriptionRelations))
              ..where((f) =>
                  f.selectorName.equals(selectorName) &
                  f.subscriptionId.equals(subscriptionId)))
            .getSingleOrNull();
    if (relation != null) {
      await database
          .syncDeleteId(database.selectorSubscriptionRelations, [relation.id]);
    }
    // await (database.delete(database.selectorSubscriptionRelations)
    //       ..where((f) =>
    //           f.selectorName.equals(selectorName) &
    //           f.subscriptionId.equals(subscriptionId)))
    //     .go();
  }

  @override
  Future<void> addHandlerGroupToSelector(
      String selectorName, String groupName) async {
    // await database
    //     .into(database.selectorHandlerGroupRelations)
    //     .insert(SelectorHandlerGroupRelationsCompanion(
    //       selectorName: Value(selectorName),
    //       groupName: Value(groupName),
    //     ));
    await database.syncInsertReturning(
      database.selectorHandlerGroupRelations,
      SelectorHandlerGroupRelationsCompanion(
        id: Value(SnowflakeId.generate()),
        selectorName: Value(selectorName),
        groupName: Value(groupName),
      ),
    );
  }

  @override
  Future<void> removeHandlerGroupFromSelector(
      String selectorName, String groupName) async {
    final relation =
        await ((database.select(database.selectorHandlerGroupRelations))
              ..where((f) =>
                  f.selectorName.equals(selectorName) &
                  f.groupName.equals(groupName)))
            .getSingleOrNull();
    if (relation != null) {
      await database
          .syncDeleteId(database.selectorHandlerGroupRelations, [relation.id]);
    }
    // await (database.delete(database.selectorHandlerGroupRelations)
    //       ..where((f) =>
    //           f.selectorName.equals(selectorName) &
    //           f.groupName.equals(groupName)))
    //     .go();
  }

  @override
  Future<void> addHandlerToSelector(String selectorName, int handlerId) async {
    await database.syncInsertReturning(
      database.selectorHandlerRelations,
      SelectorHandlerRelationsCompanion(
        id: Value(SnowflakeId.generate()),
        selectorName: Value(selectorName),
        handlerId: Value(handlerId),
      ),
    );
    // await database
    //     .into(database.selectorHandlerRelations)
    //     .insert(SelectorHandlerRelationsCompanion(
    //       selectorName: Value(selectorName),
    //       handlerId: Value(handlerId),
    //     ));
  }

  @override
  Future<void> removeHandlerFromSelector(
      String selectorName, int handlerId) async {
    // await (database.delete(database.selectorHandlerRelations)
    //       ..where((f) =>
    //           f.selectorName.equals(selectorName) &
    //           f.handlerId.equals(handlerId)))
    //     .go();
    final relation = await ((database.select(database.selectorHandlerRelations))
          ..where((f) =>
              f.selectorName.equals(selectorName) &
              f.handlerId.equals(handlerId)))
        .getSingleOrNull();
    if (relation != null) {
      await database
          .syncDeleteId(database.selectorHandlerRelations, [relation.id]);
    }
  }

  @override
  Future<void> addSelector(SelectorConfig selector) async {
    await database.syncInsertReturning(
      database.handlerSelectors,
      HandlerSelectorsCompanion(
          name: Value(selector.tag), config: Value(selector)),
    );
  }

  @override
  Stream<List<GreatIpSet>> getGreatIpSetsStream() {
    return database.select(database.greatIpSets).watch();
  }

  @override
  Stream<List<AtomicIpSet>> getAtomicIpSetsStream() {
    return database.select(database.atomicIpSets).watch();
  }
}
