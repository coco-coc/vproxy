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

import 'dart:math';

String generateRealisticDomain() {
  final random = Random();

  // Common domain prefixes
  final prefixes = [
    'my',
    'the',
    'get',
    'go',
    'find',
    'search',
    'buy',
    'shop',
    'best',
    'top',
    'new',
    'free',
    'pro',
    'online',
    'web',
    'net',
    'tech',
    'info',
    'data',
    'cloud',
    'app',
    'dev',
    'code',
    'soft'
  ];

  // Common domain suffixes
  final suffixes = [
    'hub',
    'zone',
    'spot',
    'place',
    'space',
    'site',
    'store',
    'shop',
    'market',
    'center',
    'point',
    'base',
    'lab',
    'pro',
    'plus',
    'max',
    'prime',
    'premium',
    'elite',
    'pro',
    'expert'
  ];

  // Randomly decide the structure
  final structure = random.nextInt(3);

  switch (structure) {
    case 0:
      // prefix-suffix.com
      return '${prefixes[random.nextInt(prefixes.length)]}-${suffixes[random.nextInt(suffixes.length)]}.com';
    case 1:
      // prefixsuffix.com
      return '${prefixes[random.nextInt(prefixes.length)]}${suffixes[random.nextInt(suffixes.length)]}.com';
    case 2:
      // prefix123.com
      return '${prefixes[random.nextInt(prefixes.length)]}${random.nextInt(999)}.com';
    default:
      return 'example.com';
  }
}

String getRootDomain(String domain) {
  final parts = domain.split('.');
  if (parts.length > 2) {
    return parts.sublist(parts.length - 2).join('.');
  }
  return domain;
}
