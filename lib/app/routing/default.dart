import 'dart:io';
import 'package:flutter/material.dart';
import 'package:tm/protos/protos/dns.pb.dart';
import 'package:tm/protos/protos/geo.pb.dart';
import 'package:tm/protos/protos/router.pb.dart';
import 'package:vx/app/routing/routing_page.dart';
import 'package:vx/app/routing/mode_widget.dart';
import 'package:vx/common/common.dart';
import 'package:vx/common/const.dart';
import 'package:vx/data/database.dart';
import 'package:vx/l10n/app_localizations.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:vx/xconfig_helper.dart';

const gfw = 'GFW';
const cn = 'CN';
// const cnGames = 'CN游戏';
// const private = '私有';
// const gfwWithoutCustomDirect = 'GFW(排除自定义直连)';
// // name of the great domain set and great ip set used in blacklist mode
// const gfwModeProxyDomains = 'GFW模式代理域名';
// const gfwModeProxyIps = 'GFW模式代理IP';
// const cnModeProxyDomains = 'CN模式代理域名';
// const cnModeDirectDomains = 'CN模式直连域名';
// const cnModeDirectIps = 'CN模式直连IP';
// const proxyAllModeProxyDomains = '全局模式代理域名';
// const proxyAllModeDirectDomains = '全局模式直连域名';
// const proxyAllModeDirectIps = '全局模式直连IP';
// const ruBlockModeProxyDomains = 'RU-Block模式代理域名';
// const ruBlockModeProxyIps = 'RU-Block模式代理IP';
// const ruBlockAllModeProxyDomains = 'RU-Block(All)模式代理域名';
// const ruBlockAllModeProxyIps = 'RU-Block(All)模式代理IP';

const ruBlock = 'RU Block';
const ruBlockAll = 'RU Block(All)';

const dnsServerFake = 'Fake DNS Server';

enum DefaultRouteMode {
  /// Only banned ip/domain will go through proxy
  @JsonValue('black')
  black(),

  /// Only ip/domain of cn will go through proxy
  @JsonValue('white')
  white(),

  /// All ip/domain will go through proxy
  @JsonValue('proxy_all')
  proxyAll(),
  /* auto */

  @JsonValue('ru_blocked')
  ruBlocked(),

  @JsonValue('ru_blocked_all')
  ruBlockedAll();

  const DefaultRouteMode();

  String toLocalString(AppLocalizations al) {
    switch (this) {
      case DefaultRouteMode.black:
        return 'GFW';
      case DefaultRouteMode.white:
        return 'CN';
      case DefaultRouteMode.proxyAll:
        return al.proxyAll;
      case DefaultRouteMode.ruBlocked:
        return al.ruBlocked;
      case DefaultRouteMode.ruBlockedAll:
        return al.ruBlockedAll;
    }
  }

  String description(BuildContext ctx) {
    switch (this) {
      case DefaultRouteMode.black:
        return AppLocalizations.of(ctx)!.gfwDesc;
      case DefaultRouteMode.white:
        return AppLocalizations.of(ctx)!.cnDesc;
      case DefaultRouteMode.proxyAll:
        return AppLocalizations.of(ctx)!.proxyAllDesc;
      case DefaultRouteMode.ruBlocked:
        return AppLocalizations.of(ctx)!.ruBlockedDesc;
      case DefaultRouteMode.ruBlockedAll:
        return AppLocalizations.of(ctx)!.ruBlockedAllDesc;
    }
  }

  static const _internalDnsProxy = 'internal-dns-proxy';
  static const _internalDnsDirect = 'internal-dns-direct';

  List<DnsServerConfig> getDnsServerConfigs({required AppLocalizations al}) {
    final country = getUserCountryFromLocale();
    return [
      DnsServerConfig(
        name: dnsServerFake,
        fakeDnsServer: FakeDnsServer(
          poolConfigs: XConfigHelper.fakednsPools,
        ),
      ),
      DnsServerConfig(
        name: al.dnsServerProxy,
        plainDnsServer: PlainDnsServer(
          addresses: ['1.1.1.1:53'],
        ),
        cacheDuration: 3600,
      ),
      DnsServerConfig(
        name: al.dnsServerDirect,
        plainDnsServer: PlainDnsServer(
            addresses: ['1.1.1.1:53', ...(countryDnsServers[country] ?? [])],
            useDefaultDns: true),
      )
    ];
  }

  // this is for displaying to users. and for copying when creating a custom route mode
  List<RuleConfig> displayRouterRules({required AppLocalizations al}) {
    final commonRules = [
      RuleConfig(
        ruleName: al.ruleNameInternalDnsProxyGoProxy,
        inboundTags: [_internalDnsProxy],
        selectorTag: defaultProxySelectorTag,
      ),
      RuleConfig(
        ruleName: al.ruleNameInternalDnsDirectGoDirect,
        inboundTags: [_internalDnsDirect],
        outboundTag: directHandlerTag,
      ),
      RuleConfig(
        ruleName: al.ruleNameProxyDnsServerGoProxy,
        inboundTags: [al.dnsServerProxy],
        selectorTag: defaultProxySelectorTag,
      ),
      RuleConfig(
        ruleName: al.ruleNameDirectDnsServerGoDirect,
        inboundTags: [al.dnsServerDirect],
        outboundTag: directHandlerTag,
      ),
      ...(getCommonAppRules(al: al)),
    ];
    switch (this) {
      case DefaultRouteMode.black:
        return [...commonRules, ...(getBlackListSpecificRules(al: al))];
      case DefaultRouteMode.white:
        return [...commonRules, ...(getWhiteListSpecificRules(al: al))];
      case DefaultRouteMode.proxyAll:
        return [...commonRules, ...(getProxyAllSpecificRules(al: al))];
      case DefaultRouteMode.ruBlocked:
        return [...commonRules, ...(getRuBlockSpecificRules(al: al))];
      case DefaultRouteMode.ruBlockedAll:
        return [...commonRules, ...(getRuBlockAllSpecificRules(al: al))];
    }
  }

  List<AtomicDomainSet> getAtomicDomainSets({required AppLocalizations al}) {
    final customDirectSet = AtomicDomainSet(
      name: al.customDirect,
      useBloomFilter: false,
    );
    final customProxySet = AtomicDomainSet(
      name: al.customProxy,
      useBloomFilter: false,
    );
    final privateSet = AtomicDomainSet(
      name: al.private,
      useBloomFilter: false,
      geositeConfig: GeositeConfig(codes: ['private']),
    );
    switch (this) {
      case DefaultRouteMode.black:
        return [
          customDirectSet,
          customProxySet,
          AtomicDomainSet(
              name: gfw,
              useBloomFilter: false,
              geositeConfig: GeositeConfig(codes: ['gfw']))
        ];
      case DefaultRouteMode.white:
        return [
          customDirectSet,
          customProxySet,
          privateSet,
          if (Platform.isIOS)
            AtomicDomainSet(
                name: gfw,
                useBloomFilter: false,
                geositeConfig: GeositeConfig(codes: ['gfw'])),
          AtomicDomainSet(
              name: cn,
              useBloomFilter: Platform.isIOS,
              geositeConfig:
                  GeositeConfig(codes: ['cn', 'apple-cn', 'tld-cn'])),
          AtomicDomainSet(
              name: al.cnGames,
              useBloomFilter: false,
              geositeConfig:
                  GeositeConfig(codes: ['category-games'], attributes: ['cn'])),
        ];
      case DefaultRouteMode.proxyAll:
        return [privateSet, customDirectSet, customProxySet];
      case DefaultRouteMode.ruBlocked:
        return [
          customDirectSet,
          customProxySet,
          privateSet,
          AtomicDomainSet(
              name: ruBlock,
              useBloomFilter: false,
              geoUrl: ruGeositeUrl,
              geositeConfig: GeositeConfig(codes: ['ru-blocked']))
        ];
      case DefaultRouteMode.ruBlockedAll:
        return [
          customDirectSet,
          customProxySet,
          privateSet,
          AtomicDomainSet(
              name: ruBlockAll,
              useBloomFilter: true,
              geoUrl: ruGeositeUrl,
              geositeConfig: GeositeConfig(codes: ['ru-blocked-all']))
        ];
    }
  }

  List<AtomicIpSet> getAtomicIpSets({required AppLocalizations al}) {
    final customDirectSet = AtomicIpSet(name: al.customDirect, inverse: false);
    final customProxySet = AtomicIpSet(name: al.customProxy, inverse: false);
    final privateSet = AtomicIpSet(
        name: al.private,
        inverse: false,
        geoIpConfig: GeoIPConfig(codes: ['private']));
    switch (this) {
      case DefaultRouteMode.black:
        return [
          AtomicIpSet(
              name: gfw,
              inverse: false,
              geoIpConfig: GeoIPConfig(
                  codes: ['telegram', 'google', 'facebook', 'twitter', "tor"]))
        ];
      case DefaultRouteMode.white:
        return [
          customDirectSet,
          customProxySet,
          privateSet,
          AtomicIpSet(
              name: cn, inverse: false, geoIpConfig: GeoIPConfig(codes: ['cn']))
        ];
      case DefaultRouteMode.proxyAll:
        return [
          privateSet,
          customDirectSet,
          customProxySet,
        ];
      case DefaultRouteMode.ruBlocked:
        return [
          customDirectSet,
          customProxySet,
          privateSet,
          AtomicIpSet(
              name: ruBlock,
              inverse: false,
              geoUrl: ruGeoIpUrl,
              geoIpConfig: GeoIPConfig(codes: ['ru-blocked']))
        ];
      case DefaultRouteMode.ruBlockedAll:
        return [
          customDirectSet,
          customProxySet,
          privateSet,
          AtomicIpSet(
              name: ruBlockAll,
              inverse: false,
              geoUrl: ruGeoIpUrl,
              geoIpConfig: GeoIPConfig(codes: ['ru-blocked']))
        ];
    }
  }

  List<GreatDomainSet> getGreatDomainSets({required AppLocalizations al}) {
    switch (this) {
      case DefaultRouteMode.black:
        return [
          GreatDomainSet(
              name: al.gfwModeProxyDomains,
              set: GreatDomainSetConfig(
                  name: al.gfwModeProxyDomains,
                  inNames: [gfw, al.customProxy],
                  exNames: [al.customDirect]))
        ];
      case DefaultRouteMode.ruBlocked:
        return [
          GreatDomainSet(
              name: al.ruBlockModeProxyDomains,
              set: GreatDomainSetConfig(
                  name: al.ruBlockModeProxyDomains,
                  inNames: [al.customProxy, ruBlock],
                  exNames: [al.customDirect]))
        ];
      case DefaultRouteMode.ruBlockedAll:
        return [
          GreatDomainSet(
              name: al.ruBlockAllModeProxyDomains,
              set: GreatDomainSetConfig(
                  name: al.ruBlockAllModeProxyDomains,
                  inNames: [al.customProxy, ruBlockAll],
                  exNames: [al.customDirect]))
        ];
      case DefaultRouteMode.white:
        return [
          GreatDomainSet(
              name: al.cnModeDirectDomains,
              oppositeName: al.cnModeProxyDomains,
              set: GreatDomainSetConfig(
                  name: al.cnModeDirectDomains,
                  oppositeName: al.cnModeProxyDomains,
                  inNames: [
                    al.private,
                    cn,
                    al.cnGames,
                    al.customDirect
                  ],
                  exNames: [
                    al.customProxy,
                    if (Platform.isIOS) al.gfwWithoutCustomDirect
                  ])),
          if (Platform.isIOS)
            GreatDomainSet(
                name: al.gfwWithoutCustomDirect,
                set: GreatDomainSetConfig(
                    name: al.gfwWithoutCustomDirect,
                    inNames: [gfw],
                    exNames: [al.customDirect]))
        ];
      case DefaultRouteMode.proxyAll:
        return [
          GreatDomainSet(
              name: al.proxyAllModeDirectDomains,
              oppositeName: al.proxyAllModeProxyDomains,
              set: GreatDomainSetConfig(
                  name: al.proxyAllModeDirectDomains,
                  oppositeName: al.proxyAllModeProxyDomains,
                  inNames: [al.private, al.customDirect],
                  exNames: [al.customProxy]))
        ];
    }
  }

  List<GreatIpSet> getGreatIpSets({required AppLocalizations al}) {
    switch (this) {
      case DefaultRouteMode.black:
        return [
          GreatIpSet(
              name: al.gfwModeProxyIps,
              greatIpSetConfig: GreatIPSetConfig(
                  name: al.gfwModeProxyIps,
                  inNames: [gfw, al.customProxy],
                  exNames: [al.customDirect]))
        ];
      case DefaultRouteMode.ruBlocked:
        return [
          GreatIpSet(
              name: al.ruBlockModeProxyIps,
              greatIpSetConfig: GreatIPSetConfig(
                  name: al.ruBlockModeProxyIps,
                  inNames: [al.customProxy, ruBlock],
                  exNames: [al.customDirect]))
        ];
      case DefaultRouteMode.ruBlockedAll:
        return [
          GreatIpSet(
              name: al.ruBlockAllModeProxyIps,
              greatIpSetConfig: GreatIPSetConfig(
                  name: al.ruBlockAllModeProxyIps,
                  inNames: [al.customProxy, ruBlock],
                  exNames: [al.customDirect]))
        ];
      case DefaultRouteMode.white:
        return [
          GreatIpSet(
              name: al.cnModeDirectIps,
              greatIpSetConfig:
                  GreatIPSetConfig(name: al.cnModeDirectIps, inNames: [
                al.private,
                cn,
                al.customDirect
              ], exNames: [
                al.customProxy,
              ]))
        ];
      case DefaultRouteMode.proxyAll:
        return [
          GreatIpSet(
              name: al.proxyAllModeDirectIps,
              greatIpSetConfig: GreatIPSetConfig(
                  name: al.proxyAllModeDirectIps,
                  inNames: [al.private, al.customDirect],
                  exNames: [al.customProxy]))
        ];
    }
  }

  List<RuleConfig> getProxyAllSpecificRules({required AppLocalizations al}) {
    final directIpGoDirectRule = RuleConfig(
      ruleName: al.ruleNameGlobalDirectIp,
      dstIpTags: [al.proxyAllModeDirectIps],
      outboundTag: directHandlerTag,
    );
    final goProxyRule = RuleConfig(
      ruleName: al.ruleNameDefaultProxy,
      selectorTag: defaultProxySelectorTag,
      matchAll: true,
    );
    final directDomainGoDirectRule = RuleConfig(
      ruleName: al.ruleNameGlobalDirectDomain,
      domainTags: [al.proxyAllModeDirectDomains],
      outboundTag: directHandlerTag,
    );
    return [
      directIpGoDirectRule,
      directDomainGoDirectRule, //TODO: This can be deleted
      goProxyRule
    ];
  }

  List<RuleConfig> getWhiteListSpecificRules({required AppLocalizations al}) {
    final directIpGoDirectRule = RuleConfig(
      ruleName: al.ruleNameCnDirectIp,
      dstIpTags: [al.cnModeDirectIps],
      outboundTag: directHandlerTag,
    );
    final goProxyRule = RuleConfig(
      ruleName: al.ruleNameDefaultProxy,
      selectorTag: defaultProxySelectorTag,
      matchAll: true,
    );
    final directDomainGoDirectRule = RuleConfig(
      ruleName: al.ruleNameCnDirectDomain,
      domainTags: [al.cnModeDirectDomains],
      outboundTag: directHandlerTag,
    );
    final _customProxyDomainGoProxyRule = RuleConfig(
      ruleName: al.ruleNameCustomProxyDomain,
      domainTags: [al.customProxy],
      selectorTag: defaultProxySelectorTag,
    );
    final _customProxyIpGoProxyRule = RuleConfig(
      ruleName: al.ruleNameCustomProxyIp,
      dstIpTags: [al.customProxy],
      selectorTag: defaultProxySelectorTag,
    );

    return [
      _customProxyDomainGoProxyRule,
      _customProxyIpGoProxyRule,
      directIpGoDirectRule,
      directDomainGoDirectRule, //TODO: This can be deleted
      goProxyRule
    ];
  }

  List<RuleConfig> getBlackListSpecificRules({required AppLocalizations al}) {
    final proxyDomainGoProxyRule = RuleConfig(
      ruleName: al.ruleNameGfwProxyDomain,
      domainTags: [al.gfwModeProxyDomains],
      selectorTag: defaultProxySelectorTag,
    );
    final proxyIpGoProxyRule = RuleConfig(
      ruleName: al.ruleNameGfwProxyIp,
      dstIpTags: [al.gfwModeProxyIps],
      selectorTag: defaultProxySelectorTag,
    );
    final goDirectRule = RuleConfig(
      ruleName: al.ruleNameDefaultDirect,
      outboundTag: directHandlerTag,
      matchAll: true,
    );
    final _customDirectDomainGoDirectRule = RuleConfig(
      ruleName: al.ruleNameCustomDirectDomain,
      domainTags: [al.customDirect],
      outboundTag: directHandlerTag,
    );
    final _customDirectIpGoDirectRule = RuleConfig(
      ruleName: al.ruleNameCustomDirectIp,
      dstIpTags: [al.customDirect],
      outboundTag: directHandlerTag,
    );
    return [
      _customDirectIpGoDirectRule,
      _customDirectDomainGoDirectRule,
      proxyIpGoProxyRule,
      proxyDomainGoProxyRule,
      goDirectRule
    ];
  }

  List<RuleConfig> getRuBlockSpecificRules({required AppLocalizations al}) {
    final proxyDomainGoProxyRule = RuleConfig(
      ruleName: al.ruleNameRuBlockProxyDomain,
      domainTags: [al.ruBlockModeProxyDomains],
      selectorTag: defaultProxySelectorTag,
    );
    final proxyIpGoProxyRule = RuleConfig(
      ruleName: al.ruleNameRuBlockProxyIp,
      dstIpTags: [al.ruBlockModeProxyIps],
      selectorTag: defaultProxySelectorTag,
    );
    final goDirectRule = RuleConfig(
      ruleName: al.ruleNameDefaultDirect,
      outboundTag: directHandlerTag,
      matchAll: true,
    );
    final _customDirectDomainGoDirectRule = RuleConfig(
      ruleName: al.ruleNameCustomDirectDomain,
      domainTags: [al.customDirect],
      outboundTag: directHandlerTag,
    );
    final _customDirectIpGoDirectRule = RuleConfig(
      ruleName: al.ruleNameCustomDirectIp,
      dstIpTags: [al.customDirect],
      outboundTag: directHandlerTag,
    );
    return [
      _customDirectIpGoDirectRule,
      _customDirectDomainGoDirectRule,
      proxyIpGoProxyRule,
      proxyDomainGoProxyRule,
      goDirectRule
    ];
  }

  List<RuleConfig> getRuBlockAllSpecificRules({required AppLocalizations al}) {
    final proxyDomainGoProxyRule = RuleConfig(
      ruleName: al.ruleNameRuBlockAllProxyDomain,
      domainTags: [al.ruBlockAllModeProxyDomains],
      selectorTag: defaultProxySelectorTag,
    );
    final proxyIpGoProxyRule = RuleConfig(
      ruleName: al.ruleNameRuBlockAllProxyIp,
      dstIpTags: [al.ruBlockAllModeProxyIps],
      selectorTag: defaultProxySelectorTag,
    );
    final goDirectRule = RuleConfig(
      ruleName: al.ruleNameDefaultDirect,
      outboundTag: directHandlerTag,
      matchAll: true,
    );
    final _customDirectDomainGoDirectRule = RuleConfig(
      ruleName: al.ruleNameCustomDirectDomain,
      domainTags: [al.customDirect],
      outboundTag: directHandlerTag,
    );
    final _customDirectIpGoDirectRule = RuleConfig(
      ruleName: al.ruleNameCustomDirectIp,
      dstIpTags: [al.customDirect],
      outboundTag: directHandlerTag,
    );
    return [
      _customDirectIpGoDirectRule,
      _customDirectDomainGoDirectRule,
      proxyIpGoProxyRule,
      proxyDomainGoProxyRule,
      goDirectRule
    ];
  }

  List<RuleConfig> getCommonAppRules({required AppLocalizations al}) {
    final appRules = <RuleConfig>[];
    if (Platform.isAndroid || Platform.isWindows) {
      appRules.add(RuleConfig(
        ruleName: al.ruleNameVXTestNodes,
        allTags: [node],
        appIds: [
          if (Platform.isAndroid)
            AppId(type: AppId_Type.Exact, value: androidPackageNme),
          if (Platform.isWindows)
            AppId(type: AppId_Type.Keyword, value: 'vx.exe')
        ],
        outboundTag: directHandlerTag,
      ));
    }
    appRules.add(RuleConfig(
      ruleName: al.ruleNameProxyApp,
      appTags: [al.proxy],
      selectorTag: defaultProxySelectorTag,
    ));
    appRules.add(RuleConfig(
      ruleName: al.ruleNameDirectApp,
      appTags: [al.direct],
      outboundTag: directHandlerTag,
    ));
    return appRules;
  }

  List<DnsRuleConfig> dnsRules({required AppLocalizations al}) {
    switch (this) {
      case DefaultRouteMode.black:
        return [
          DnsRuleConfig(
              dnsServerName: dnsServerFake,
              ruleName: al.dnsRuleNameGfwProxyFake,
              includedTypes: [DnsType.DnsType_A, DnsType.DnsType_AAAA],
              domainTags: [al.gfwModeProxyDomains]),
          DnsRuleConfig(
              ruleName: al.dnsRuleNameGfwProxy,
              domainTags: [al.gfwModeProxyDomains],
              dnsServerName: al.dnsServerProxy),
          DnsRuleConfig(
              ruleName: al.dnsRuleNameDefaultDirect,
              dnsServerName: al.dnsServerDirect),
        ];
      case DefaultRouteMode.ruBlocked:
        return [
          DnsRuleConfig(
              dnsServerName: dnsServerFake,
              ruleName: al.dnsRuleNameRuBlockProxyFake,
              includedTypes: [DnsType.DnsType_A, DnsType.DnsType_AAAA],
              domainTags: [al.ruBlockModeProxyDomains]),
          DnsRuleConfig(
              ruleName: al.dnsRuleNameRuBlockProxy,
              domainTags: [al.ruBlockModeProxyDomains],
              dnsServerName: al.dnsServerProxy),
          DnsRuleConfig(
              ruleName: al.dnsRuleNameDefaultDirect,
              dnsServerName: al.dnsServerDirect),
        ];
      case DefaultRouteMode.ruBlockedAll:
        return [
          DnsRuleConfig(
              dnsServerName: dnsServerFake,
              ruleName: al.dnsRuleNameRuBlockAllProxyFake,
              includedTypes: [DnsType.DnsType_A, DnsType.DnsType_AAAA],
              domainTags: [al.ruBlockAllModeProxyDomains]),
          DnsRuleConfig(
              ruleName: al.dnsRuleNameRuBlockAllProxy,
              domainTags: [al.ruBlockAllModeProxyDomains],
              dnsServerName: al.dnsServerProxy),
          DnsRuleConfig(
              ruleName: al.dnsRuleNameDefaultDirect,
              dnsServerName: al.dnsServerDirect),
        ];
      case DefaultRouteMode.white:
        return [
          DnsRuleConfig(
              dnsServerName: dnsServerFake,
              ruleName: al.dnsRuleNameCnProxyFake,
              includedTypes: [DnsType.DnsType_A, DnsType.DnsType_AAAA],
              domainTags: [al.cnModeProxyDomains]),
          DnsRuleConfig(
              ruleName: al.dnsRuleNameCnProxy,
              domainTags: [al.cnModeProxyDomains],
              dnsServerName: al.dnsServerProxy),
          DnsRuleConfig(
              ruleName: al.dnsRuleNameDefaultDirect,
              dnsServerName: al.dnsServerDirect),
        ];
      case DefaultRouteMode.proxyAll:
        return [
          DnsRuleConfig(
              dnsServerName: dnsServerFake,
              ruleName: al.dnsRuleNameProxyAllProxyFake,
              includedTypes: [DnsType.DnsType_A, DnsType.DnsType_AAAA],
              domainTags: [al.proxyAllModeProxyDomains]),
          DnsRuleConfig(
              ruleName: al.dnsRuleNameProxyAllProxy,
              domainTags: [al.proxyAllModeProxyDomains],
              dnsServerName: al.dnsServerProxy),
          DnsRuleConfig(
              ruleName: al.dnsRuleNameDefaultDirect,
              dnsServerName: al.dnsServerDirect),
        ];
    }
  }
}

bool isDefaultRouteMode(String routeMode, BuildContext ctx) {
  for (var mode in DefaultRouteMode.values) {
    if (mode.toLocalString(AppLocalizations.of(ctx)!) == routeMode) {
      return true;
    }
  }
  return false;
}

String getCustomDirect(BuildContext ctx) {
  return AppLocalizations.of(ctx)!.customDirect;
}

String getCustomProxy(BuildContext ctx) {
  return AppLocalizations.of(ctx)!.customProxy;
}

String getProxySetName(BuildContext ctx) {
  return AppLocalizations.of(ctx)!.proxy;
}

String getDirectSetName(BuildContext ctx) {
  return AppLocalizations.of(ctx)!.direct;
}

const countryDnsServers = {
  'CN': ['223.5.5.5:53'],
  'RU': ['77.88.8.8:53']
};
