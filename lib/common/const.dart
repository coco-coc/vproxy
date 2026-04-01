// Copyright (C) 2026 5V Network LLC <5vnetwork@proton.me>
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

import 'package:flutter/widgets.dart';

const geoipUrls = [
  'https://cdn.jsdelivr.net/gh/Loyalsoldier/v2ray-rules-dat@release/geoip.dat',
  // 'https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geoip.dat',
];
const geositeUrls = [
  'https://cdn.jsdelivr.net/gh/Loyalsoldier/v2ray-rules-dat@release/geosite.dat',
  // 'https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geosite.dat',
];

const ruGeoIpUrl =
    'https://raw.githubusercontent.com/runetfreedom/russia-v2ray-rules-dat/release/geoip.dat';
const ruGeositeUrl =
    'https://raw.githubusercontent.com/runetfreedom/russia-v2ray-rules-dat/release/geosite.dat';
const ruGeoSiteSimplifiedUrl =
    'https://cdn.jsdelivr.net/gh/5VNetwork/process-geo@release/simplified_geosite_ru.dat';

const geoIPPathDebug = '../../../../temp/geoip.dat';
const geositePathDebug = '../../../../temp/geosite.dat';

const nsCfIp = '1.1.1.1';
const googleDnsIp = '8.8.8.8';
const ns223Ip = '223.5.5.5';
const oneFourFourDnsIp = '114.114.114.114';
const localhost = 'localhost';

const boxH4 = SizedBox(height: 4);

const boxH8 = SizedBox(height: 8);

const boxH10 = SizedBox(height: 10);

const boxW4 = SizedBox(width: 4);

const boxW10 = SizedBox(width: 10);

const boxW20 = SizedBox(width: 20);

// const outboundHandlerGroup = 'outboundHandlerGroup';
// const outboundHandlerConfig = 'outboundHandlerConfig';
// const dnsRecord = 'dnsRecord';
// const geoDomain = 'geoDomain';
// const geoCidr = 'geoCidr';
// const persistentAppState = 'persistentAppState';
