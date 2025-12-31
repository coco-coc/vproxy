import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tm/protos/protos/router.pb.dart';
import 'package:tm/protos/protos/tun.pb.dart';
import 'package:vx/app/control.dart';
import 'package:vx/app/home/home.dart';
import 'package:vx/app/outbound/outbound_page.dart';
import 'package:vx/app/outbound/outbounds_bloc.dart';
import 'package:vx/app/routing/default.dart';
import 'package:vx/app/routing/mode_widget.dart';
import 'package:vx/app/routing/routing_page.dart';
import 'package:vx/app/blocs/proxy_selector/proxy_selector_bloc.dart';
import 'package:vx/common/common.dart';
import 'package:vx/data/database.dart';
import 'package:vx/utils/auto_update_service.dart';
import 'package:vx/utils/logger.dart';
import 'package:vx/xconfig_helper.dart';

class PrefHelper {
  PrefHelper({required SharedPreferences pref}) : _pref = pref;

  final SharedPreferences _pref;

  String get initialLocation {
    return _pref.getString('initialLocation') ?? '/node';
  }

  void setInitialLocation(String location) {
    _pref.setString('initialLocation', location);
  }

  bool get initialLaunch {
    return _pref.getBool('initialLaunch') ?? true;
  }

  void setInitialLaunch() {
    _pref.setBool('initialLaunch', false);
  }

  bool get welcomeShown {
    return _pref.getBool('welcomeShown') ?? false;
  }

  void setWelcomeShown(bool shown) {
    _pref.setBool('welcomeShown', shown);
  }

  bool get databaseInitialized {
    return _pref.getBool('databaseInitialized') ?? false;
  }

  void setDatabaseInitialized(bool initialized) {
    _pref.setBool('databaseInitialized', initialized);
  }

  InboundMode get inboundMode {
    final mode = _pref.getInt('inboundMode');
    if (mode == null) return InboundMode.tun;
    return InboundMode.values[mode];
  }

  void setInboundMode(InboundMode mode) {
    _pref.setInt('inboundMode', mode.index);
  }

  bool get sniff {
    return _pref.getBool('sniff') ?? true;
  }

  void setSniff(bool enable) {
    _pref.setBool('sniff', enable);
  }

  // return either a string or a RouteMode
  String? get routingMode {
    return _customRoutingMode;
  }

  void setRoutingMode(String? mode) {
    if (mode == null) {
      _pref.remove('customRoutingMode');
    } else {
      _pref.setString('customRoutingMode', mode);
    }
  }

  String? get _customRoutingMode {
    return _pref.getString('customRoutingMode');
  }

  void _setCustomRoutingMode(String? mode) {
    if (mode == null) {
      _pref.remove('customRoutingMode');
    } else {
      _pref.setString('customRoutingMode', mode);
    }
  }

  SelectorConfig get manualSelectorConfig {
    return SelectorConfig(
      strategy: SelectorConfig_SelectingStrategy.ALL,
      tag: defaultProxySelectorTag,
      balanceStrategy:
          proxySelectorManualMode == ProxySelectorManualNodeSelectionMode.single
              ? SelectorConfig_BalanceStrategy.RANDOM
              : proxySelectorManualMultipleBalanceStrategy,
      filter: SelectorConfig_Filter(
        selected: true,
      ),
      landHandlers: proxySelectorManualLandHandlers,
    );
  }

  ProxySelectorMode get proxySelectorMode {
    final mode = _pref.getInt('proxySelectorMode');
    if (mode == null) return ProxySelectorMode.manual;
    return ProxySelectorMode.values[mode];
  }

  void setProxySelectorMode(ProxySelectorMode mode) {
    _pref.setInt('proxySelectorMode', mode.index);
  }

  ProxySelectorManualNodeSelectionMode get proxySelectorManualMode {
    final mode = _pref.getInt('proxySelectorManualMode');
    if (mode == null) return ProxySelectorManualNodeSelectionMode.single;
    return ProxySelectorManualNodeSelectionMode.values[mode];
  }

  void setProxySelectorManualMode(ProxySelectorManualNodeSelectionMode mode) {
    _pref.setInt('proxySelectorManualMode', mode.index);
  }

  List<Int64> get proxySelectorManualLandHandlers {
    final ids = _pref.getStringList('proxySelectorManualLandHandlers');
    if (ids == null) return [];
    return ids.map((e) => Int64(int.parse(e))).toList();
  }

  void setProxySelectorLandHandlers(List<Int64> ids) {
    _pref.setStringList('proxySelectorManualLandHandlers',
        ids.map((e) => e.toString()).toList());
  }

  SelectorConfig_BalanceStrategy
      get proxySelectorManualMultipleBalanceStrategy {
    final strategy = _pref.getInt('proxySelectorManualMultipleBalanceStrategy');
    if (strategy == null) return SelectorConfig_BalanceStrategy.MEMORY;
    return SelectorConfig_BalanceStrategy.values[strategy];
  }

  void setProxySelectorManualMultipleBalanceStrategy(
      SelectorConfig_BalanceStrategy strategy) {
    _pref.setInt('proxySelectorManualMultipleBalanceStrategy', strategy.value);
  }

  // SelectorConfig get proxySelectorAutoConfig {
  //   final config = _pref.getString('proxySelectorAutoConfig');
  //   if (config == null) {
  //     return SelectorConfig(
  //       tag: defaultProxySelectorTag,
  //       filter: SelectorConfig_Filter(
  //         all: true,
  //       ),
  //       strategy: SelectorConfig_SelectingStrategy.ALL_OK,
  //       balanceStrategy: SelectorConfig_BalanceStrategy.MEMORY,
  //     );
  //   }
  //   return SelectorConfig.fromJson(config);
  // }

  // void setProxySelectorAutoConfig(SelectorConfig config) {
  //   if (config.tag != defaultProxySelectorTag) {
  //     config.tag = defaultProxySelectorTag;
  //   }
  //   print(config.tag);
  //   _pref.setString('proxySelectorAutoConfig', config.writeToJson());
  // }

  // SelectorConfig_SelectingStrategy get autoModeSelectingStrategy {
  //   final strategy = _pref.getInt('autoModeSelectingStrategy');
  //   if (strategy == null) {
  //     return SelectorConfig_SelectingStrategy.MOST_THROUGHPUT;
  //   }
  //   return SelectorConfig_SelectingStrategy.values[strategy];
  // }

  // void setAutoModeSelectingStrategy(SelectorConfig_SelectingStrategy strategy) {
  //   _pref.setInt('autoModeSelectingStrategy', strategy.value);
  // }

  // SelectorConfig_BalanceStrategy get autoModeBalanceStrategy {
  //   final strategy = _pref.getInt('autoModeBalanceStrategy');
  //   if (strategy == null) return SelectorConfig_BalanceStrategy.MEMORY;
  //   return SelectorConfig_BalanceStrategy.values[strategy];
  // }

  // void setAutoModeBalanceStrategy(SelectorConfig_BalanceStrategy strategy) {
  //   _pref.setInt('autoModeBalanceStrategy', strategy.value);
  // }

  // List<int> get autoModeFilterHandlerIds {
  //   final ids = _pref.getStringList('autoModeFilterHandlerIds');
  //   if (ids == null) return [];
  //   return ids.map((e) => int.parse(e)).toList();
  // }

  // void setAutoModeFilterHandlerIds(List<int> ids) {
  //   _pref.setStringList(
  //       'autoModeFilterHandlerIds', ids.map((e) => e.toString()).toList());
  // }

  // List<int> get autoModeFilterSubIds {
  //   final ids = _pref.getStringList('autoModeFilterSubIds');
  //   if (ids == null) return [];
  //   return ids.map((e) => int.parse(e)).toList();
  // }

  // void setAutoModeFilterSubIds(List<int> ids) {
  //   _pref.setStringList(
  //       'autoModeFilterSubIds', ids.map((e) => e.toString()).toList());
  // }

  // List<String> get autoModeFilterGroupTags {
  //   final tags = _pref.getStringList('autoModeFilterGroupTags');
  //   if (tags == null) return [];
  //   return tags;
  // }

  // void setAutoModeFilterGroupTags(List<String> tags) {
  //   _pref.setStringList('autoModeFilterGroupTags', tags);
  // }

  // enable user log
  bool get enableLog {
    return _pref.getBool('enableLog') ?? false;
  }

  set enableLog(bool enable) {
    _pref.setBool('enableLog', enable);
  }

  bool get enableDebugLog {
    return _pref.getBool('enableDebugLog') ?? false;
  }

  void setEnableDebugLog(bool enable) {
    _pref.setBool('enableDebugLog', enable);
  }

  bool get showApp {
    return _pref.getBool('showApp') ?? false;
  }

  void setShowApp(bool show) {
    _pref.setBool('showApp', show);
  }

  bool get showHandler {
    return _pref.getBool('showHandler') ?? false;
  }

  void setShowHandler(bool show) {
    _pref.setBool('showHandler', show);
  }

  DateTime? get lastGeoUpdate {
    final time = _pref.getInt('lastGeoUpdate');
    if (time == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(time);
  }

  void setLastGeoUpdate(DateTime time) {
    _pref.setInt('lastGeoUpdate', time.millisecondsSinceEpoch);
  }

  // fake dns
  bool get fakeDns {
    return _pref.getBool('fakeDns') ?? true;
  }

  void setFakeDns(bool enable) {
    _pref.setBool('fakeDns', enable);
  }

  bool get autoUpdate {
    return _pref.getBool('autoUpdate') ?? true;
  }

  void setAutoUpdate(bool enable) {
    _pref.setBool('autoUpdate', enable);
  }

  // minutes
  int get updateInterval {
    return _pref.getInt('updateInterval') ?? 300;
  }

  void setUpdateInterval(int interval) {
    _pref.setInt('updateInterval', interval);
  }

  /// Last time the app checked for updates (stored as milliseconds since epoch)
  int? get lastUpdateCheckTime {
    return _pref.getInt('lastUpdateCheckTime');
  }

  void setLastUpdateCheckTime(int timestamp) {
    _pref.setInt('lastUpdateCheckTime', timestamp);
  }

  DownloadedInstaller? get downloadedInstaller {
    final json = _pref.getString('downloadedInstaller');
    if (json == null) return null;
    return DownloadedInstaller.fromJson(jsonDecode(json));
  }

  void setDownloadedInstallerPath(DownloadedInstaller? installer) {
    if (installer == null) {
      _pref.remove('downloadedInstaller');
    } else {
      _pref.setString('downloadedInstaller', jsonEncode(installer.toJson()));
    }
  }

  String? get skipVersion {
    return _pref.getString('skipVersion');
  }

  void setSkipVersion(String version) {
    _pref.setString('skipVersion', version);
  }

  Language? get language {
    final i = _pref.getInt('language');
    if (i == null) return null;
    return Language.values[i];
  }

  void setLanguage(Language? language) {
    if (language == null) {
      _pref.remove('language');
    } else {
      _pref.setInt('language', language.index);
    }
  }

  bool get hasShownOnce {
    return _pref.getBool('hasShownOnce') ?? false;
  }

  void setHasShownOnce(bool show) {
    _pref.setBool('hasShownOnce', show);
  }

  bool get proxyShare {
    return _pref.getBool('proxyShare') ?? false;
  }

  void setProxyShare(bool enabled) {
    _pref.setBool('proxyShare', enabled);
  }

  String get proxyShareListenAddress {
    return _pref.getString('proxyShareListenAddress') ?? '0.0.0.0';
  }

  void setProxyShareListenAddress(String address) {
    _pref.setString('proxyShareListenAddress', address);
  }

  int get proxyShareListenPort {
    return _pref.getInt('proxyShareListenPort') ??
        (Platform.isIOS ? 10800 : 1080);
  }

  void setProxyShareListenPort(int port) {
    _pref.setInt('proxyShareListenPort', port);
  }

  String get socksUdpAssociateAddress {
    return _pref.getString('socksUdpAccociateAddress') ?? '';
  }

  void setSocksUdpaccociateAddress(String addr) {
    _pref.setString('socksUdpAccociateAddress', addr);
  }

  double? get windowX {
    return _pref.getDouble('windowX');
  }

  void setWindowX(double x) {
    _pref.setDouble('windowX', x);
  }

  double? get windowY {
    return _pref.getDouble('windowY');
  }

  void setWindowY(double x) {
    _pref.setDouble('windowY', x);
  }

  double get windowWidth {
    return _pref.getDouble('windowWidth') ?? 800;
  }

  void setWindowWidth(double x) {
    _pref.setDouble('windowWidth', x);
  }

  double get windowHeight {
    return _pref.getDouble('windowHeight') ?? 600;
  }

  void setWindowHeight(double x) {
    _pref.setDouble('windowHeight', x);
  }

  bool get smScreenShowProtocol {
    return _pref.getBool('smScreenShowProtocol') ?? false;
  }

  void setSmScreenShowProtocol(bool show) {
    _pref.setBool('smScreenShowProtocol', show);
  }

  bool get smScreenShowOk {
    return _pref.getBool('smScreenShowOk') ?? true;
  }

  void setSmScreenShowOk(bool show) {
    _pref.setBool('smScreenShowOk', show);
  }

  bool get smScreenShowSpeed {
    return _pref.getBool('smScreenShowSpeed') ?? true;
  }

  void setSmScreenShowSpeed(bool show) {
    _pref.setBool('smScreenShowSpeed', show);
  }

  bool get smScreenShowLatency {
    return _pref.getBool('smScreenShowLatency') ?? false;
  }

  bool get smScreenShowActive {
    return _pref.getBool('smScreenShowActive') ?? true;
  }

  void setSmScreenShowActive(bool show) {
    _pref.setBool('smScreenShowActive', show);
  }

  void setSmScreenShowLatency(bool show) {
    _pref.setBool('smScreenShowLatency', show);
  }

  bool get smScreenShowAddress {
    return _pref.getBool('smScreenShowAddress') ?? false;
  }

  void setSmScreenShowAddress(bool show) {
    _pref.setBool('smScreenShowAddress', show);
  }

  String get outboundViewMode {
    return _pref.getString('outboundViewMode') ?? 'list';
  }

  void setOutboundViewMode(OutboundViewMode mode) {
    _pref.setString('outboundViewMode', mode.name);
  }

  OutboundTableSmallScreenPreference get outboundTableSmallScreenPreference {
    return OutboundTableSmallScreenPreference(
      showProtocol: smScreenShowProtocol,
      showUsable: smScreenShowOk,
      showPing: smScreenShowLatency,
      showSpeed: smScreenShowSpeed,
      showAddress: smScreenShowAddress,
      showActive: smScreenShowActive,
    );
  }

  bool get shareLog {
    if (isPkg) {
      return false;
    }
    return _pref.getBool('shareLog') ?? isProduction();
  }

  void setShareLog(bool enable) {
    _pref.setBool('shareLog', enable);
  }

  DateTime? get lastUploadTime {
    final time = _pref.getInt('lastLogUploadTime');
    if (time == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(time);
  }

  void setLastUploadTime(DateTime time) {
    _pref.setInt('lastLogUploadTime', time.millisecondsSinceEpoch);
  }

  (Col, SortOrder)? get sortCol {
    final col = _pref.getInt('sortCol');
    if (col == null) return null;
    final order = _pref.getInt('sortOrder');
    if (order == null) return null;
    if (col < 0 || col >= Col.values.length) return null;
    return (Col.values[col], order);
  }

  void setSortCol((Col, SortOrder)? col) {
    if (col == null) {
      _pref.remove('sortCol');
      _pref.remove('sortOrder');
    } else {
      _pref.setInt('sortCol', col.$1.index);
      _pref.setInt('sortOrder', col.$2);
    }
  }

  String? get nodeGroup {
    return _pref.getString('nodeGroup');
  }

  void setNodeGroup(String? group) {
    if (group == null) {
      _pref.remove('nodeGroup');
    } else {
      _pref.setString('nodeGroup', group);
    }
  }

  bool get advanceRouteMode {
    return _pref.getBool('advanceRouteMode') ?? false;
  }

  void setAdvanceRouteMode(bool enable) {
    _pref.setBool('advanceRouteMode', enable);
  }

  // bool get tunAlwaysEnableIpv6 {
  //   return _pref.getBool('tunAlwaysEnableIpv6') ?? false;
  // }

  // void setTunAlwaysEnableIpv6(bool enable) {
  //   _pref.setBool('tunAlwaysEnableIpv6', enable);
  // }

  TunConfig_TUN46Setting get tun46Setting {
    final setting = _pref.getInt('tun46Setting');
    if (setting == null) {
      return ((Platform.isWindows || Platform.isLinux)
          ? TunConfig_TUN46Setting.DYNAMIC
          : TunConfig_TUN46Setting.FOUR_ONLY);
    }
    return TunConfig_TUN46Setting.values[setting];
  }

  void setTun46Setting(TunConfig_TUN46Setting setting) {
    _pref.setInt('tun46Setting', setting.value);
  }

  ThemeMode get themeMode {
    final mode = _pref.getInt('themeMode');
    if (mode == null) return ThemeMode.system;
    return ThemeMode.values[mode];
  }

  void setThemeMode(ThemeMode mode) {
    _pref.setInt('themeMode', mode.index);
  }

  bool get windowsServiceInstalled {
    return _pref.getBool('windowsServiceInstalled') ?? false;
  }

  void setWindowsServiceInstalled(bool installed) {
    _pref.setBool('windowsServiceInstalled', installed);
  }

  bool get fallbackToProxy {
    return _pref.getBool('fallbackToProxy') ?? false;
  }

  void setFallbackToProxy(bool enable) {
    _pref.setBool('fallbackToProxy', enable);
  }

  bool get fallbackRetryDomain {
    return _pref.getBool('fallbackRetryDomain') ?? false;
  }

  void setFallbackRetryDomain(bool enable) {
    _pref.setBool('fallbackRetryDomain', enable);
  }

  PingMode get pingMode {
    final mode = _pref.getInt('pingMode');
    if (mode == null) return PingMode.Real;
    return PingMode.values[mode];
  }

  void setPingMode(PingMode mode) {
    _pref.setInt('pingMode', mode.index);
  }

  bool get alwaysOn {
    if (Platform.isMacOS || Platform.isAndroid || Platform.isIOS) {
      return false;
    }
    return _pref.getBool('alwaysOn') ?? false;
  }

  void setAlwaysOn(bool enable) {
    _pref.setBool('alwaysOn', enable);
  }

  bool get startOnBoot {
    return _pref.getBool('startOnBoot') ?? false;
  }

  void setStartOnBoot(bool enable) {
    _pref.setBool('startOnBoot', enable);
  }

  // if a user clicks connect, set this to true.
  // if a user clicks disconnect, set this to false.
  bool get connect {
    return _pref.getBool('connect') ?? false;
  }

  void setConnect(bool enable) {
    _pref.setBool('connect', enable);
  }

  int get socksPort {
    return _pref.getInt('socksPort') ?? 10800;
  }

  void setSocksPort(int port) {
    _pref.setInt('socksPort', port);
  }

  int get httpPort {
    return _pref.getInt('httpPort') ?? 10801;
  }

  void setHttpPort(int port) {
    _pref.setInt('httpPort', port);
  }

  bool get dynamicSystemProxyPorts {
    return _pref.getBool('dynamicSystemProxyPorts') ?? false;
  }

  void setDynamicSystemProxyPorts(bool enable) {
    _pref.setBool('dynamicSystemProxyPorts', enable);
  }

  bool get rejectQuicHysteria {
    return _pref.getBool('rejectQuicHysteria') ?? true;
  }

  void setRejectQuicHysteria(bool enable) {
    _pref.setBool('rejectQuicHysteria', enable);
  }

  bool get cloudSync {
    return _pref.getBool('cloudSync') ?? true;
  }

  void setCloudSync(bool enable) {
    _pref.setBool('cloudSync', enable);
  }

  bool get syncNodeSub {
    return _pref.getBool('syncNodeSub') ?? false;
  }

  void setSyncNodeSub(bool enable) {
    _pref.setBool('syncNodeSub', enable);
  }

  bool get syncRoute {
    return _pref.getBool('syncRoute') ?? false;
  }

  void setSyncRuleDnsSet(bool enable) {
    _pref.setBool('syncRoute', enable);
  }

  void setSyncSelectorSetting(bool enable) {
    _pref.setBool('syncSelectorSetting', enable);
  }

  bool get syncSelectorSetting {
    return _pref.getBool('syncSelectorSetting') ?? false;
  }

  bool get syncServer {
    return _pref.getBool('syncServer') ?? false;
  }

  void setSyncServer(bool enable) {
    _pref.setBool('syncServer', enable);
  }

  DateTime? get deviceIdRefreshTime {
    final time = _pref.getInt('deviceIdRefreshTime');
    if (time == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(time);
  }

  void setDeviceIdUpdateTime(DateTime time) {
    _pref.setInt('deviceIdRefreshTime', time.millisecondsSinceEpoch);
  }

  String? get fcmToken {
    return _pref.getString('fcmToken');
  }

  void setFcmToken(String? token) {
    if (token == null) {
      _pref.remove('fcmToken');
    } else {
      _pref.setString('fcmToken', token);
    }
  }

  int get machineId {
    final id = _pref.getInt('machineId');
    if (id == null) {
      final newId = Random().nextInt(1023);
      _pref.setInt('machineId', newId);
      return newId;
    }
    return id;
  }

  bool get autoBackup {
    return _pref.getBool('autoBackup') ?? false;
  }

  void setAutoBackup(bool enable) {
    _pref.setBool('autoBackup', enable);
  }

  String get dbName {
    if (Platform.isWindows) {
      return _pref.getString('dbName') ?? 'x_database.sqlite';
    }
    return 'x_database.sqlite';
  }

  void setDbName(String name) {
    _pref.setString('dbName', name);
  }

  bool get storeSudoPasswordInMemory {
    return _pref.getBool('storeSudoPasswordInMemory') ?? false;
  }

  void setStoreSudoPasswordInMemory(bool enable) {
    _pref.setBool('storeSudoPasswordInMemory', enable);
  }

  bool get showRpmNotice {
    return _pref.getBool('showRpmNotice') ?? true;
  }

  void setShowRpmNotice(bool show) {
    _pref.setBool('showRpmNotice', show);
  }

  // Auto node testing settings
  bool get autoTestNodes {
    return _pref.getBool('autoTestNodes') ?? false;
  }

  void setAutoTestNodes(bool enable) {
    _pref.setBool('autoTestNodes', enable);
  }

  // Test interval in minutes (default: 60 minutes = 1 hour)
  int get nodeTestInterval {
    return _pref.getInt('nodeTestInterval') ?? 300;
  }

  void setNodeTestInterval(int minutes) {
    _pref.setInt('nodeTestInterval', minutes);
  }

  DateTime? get lastNodeTestTime {
    final time = _pref.getInt('lastNodeTestTime');
    if (time == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(time);
  }

  void setLastNodeTestTime(DateTime time) {
    _pref.setInt('lastNodeTestTime', time.millisecondsSinceEpoch);
  }

  NodesHelperSegment get nodesHelperSegment {
    final segment = _pref.getInt('nodesHelperSegment');
    if (segment == null) return NodesHelperSegment.fastest;
    return NodesHelperSegment.values[segment];
  }

  void setNodesHelperSegment(NodesHelperSegment segment) {
    _pref.setInt('nodesHelperSegment', segment.index);
  }

  List<String> getSelectorSubString() {
    final subString = _pref.getStringList('selectorSubString');
    if (subString == null) return [];
    return subString;
  }

  void setSelectorSubString(List<String> subString) {
    _pref.setStringList('selectorSubString', subString);
  }

  List<String> getSelectorPrefix() {
    final prefix = _pref.getStringList('selectorPrefix');
    if (prefix == null) return [];
    return prefix;
  }

  void setSelectorPrefix(List<String> prefix) {
    _pref.setStringList('selectorPrefix', prefix);
  }
}

enum PingMode {
  Real,
  Rtt;
}

enum Language {
  zh(Locale('zh', 'CN'), '简体中文(中国)', aiTranslated: false),
  en(Locale('en'), 'English(United States)', aiTranslated: false),
  ru(Locale('ru'), 'русский');

  final Locale locale;
  final String localText;
  final bool aiTranslated;

  static Language? fromCode(String code) {
    if (code == 'zh') return zh;
    if (code == 'en') return en;
    if (code == 'ru') return ru;
    return null;
  }

  const Language(
    this.locale,
    this.localText, {
    this.aiTranslated = true,
  });
}
