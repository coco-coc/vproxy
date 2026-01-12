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

// import 'dart:io';

// import 'package:ffi/ffi.dart';
// import 'package:flutter/foundation.dart';
// import 'package:win32/win32.dart';

// const _hive = HKEY_CURRENT_USER;

// abstract class ProtocolHandler {
//   void register(String scheme, {String? executable, List<String>? arguments});

//   void unregister(String scheme);

//   List<String> getArguments(List<String>? arguments) {
//     if (arguments == null) return ['%s'];

//     if (arguments.isEmpty && !arguments.any((e) => e.contains('%s'))) {
//       throw ArgumentError('arguments must contain at least 1 instance of "%s"');
//     }

//     return arguments;
//   }
// }

// class WindowsProtocolHandler extends ProtocolHandler {
//   @override
//   void register(String scheme, {String? executable, List<String>? arguments}) {
//     if (defaultTargetPlatform != TargetPlatform.windows) return;

//     final prefix = _regPrefix(scheme);
//     final capitalized = scheme[0].toUpperCase() + scheme.substring(1);
//     final args = getArguments(arguments).map((a) => _sanitize(a));
//     final cmd =
//         '${executable ?? Platform.resolvedExecutable} ${args.join(' ')}';

//     _regCreateStringKey(_hive, prefix, '', 'URL:$capitalized');
//     _regCreateStringKey(_hive, prefix, 'URL Protocol', '');
//     _regCreateStringKey(_hive, '$prefix\\shell\\open\\command', '', cmd);
//   }

//   @override
//   void unregister(String scheme) {
//     if (defaultTargetPlatform != TargetPlatform.windows) return;

//     final txtKey = TEXT(_regPrefix(scheme));
//     try {
//       RegDeleteTree(HKEY_CURRENT_USER, txtKey);
//     } finally {
//       free(txtKey);
//     }
//   }

//   String _regPrefix(String scheme) => 'SOFTWARE\\Classes\\$scheme';

//   int _regCreateStringKey(int hKey, String key, String valueName, String data) {
//     final txtKey = TEXT(key);
//     final txtValue = TEXT(valueName);
//     final txtData = TEXT(data);
//     try {
//       return RegSetKeyValue(
//         hKey,
//         txtKey,
//         txtValue,
//         REG_SZ,
//         txtData,
//         txtData.length * 2 + 2,
//       );
//     } finally {
//       free(txtKey);
//       free(txtValue);
//       free(txtData);
//     }
//   }

//   String _sanitize(String value) {
//     value = value.replaceAll(r'%s', '%1').replaceAll(r'"', '\\"');
//     return '"$value"';
//   }
// }
