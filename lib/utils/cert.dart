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

import 'dart:async';
import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:tm/protos/protos/tls/certificate.pb.dart';
import 'package:vx/common/common.dart';
import 'package:vx/main.dart';
import 'package:vx/utils/path.dart';
import 'package:vx/utils/x_api_bindings_generated.dart';
import 'package:vx/utils/x_api_linux_bindings_generated.dart';

Future<Certificate> getCertificate() async {
  if (Platform.isWindows) {
    final dll = DynamicLibrary.open(getDllPath());
    final bindings = XApiBindings(dll);
    final ret = bindings.GenerateTls();
    final errStrPtr = ret.r2;
    final errStr = errStrPtr.cast<Utf8>().toDartString();
    bindings.FreeString(errStrPtr);
    if (errStr.isNotEmpty) {
      throw Exception(errStr);
    }
    final certificateBytesPointer = ret.r0;
    final certificateBytes =
        certificateBytesPointer.cast<Uint8>().asTypedList(ret.r1);
    final certificate = Certificate.fromBuffer(certificateBytes);
    bindings.FreeBytes(certificateBytesPointer);
    return certificate;
  } else if (Platform.isLinux) {
    final dll = DynamicLibrary.open(getSoPath());
    final bindings = XApiLinuxBindings(dll);
    final ret = bindings.GenerateTls();
    final errStrPtr = ret.r2;
    final errStr = errStrPtr.cast<Utf8>().toDartString();
    bindings.FreeString(errStrPtr);
    if (errStr.isNotEmpty) {
      throw Exception(errStr);
    }
    final certificateBytesPointer = ret.r0;
    final certificateBytes =
        certificateBytesPointer.cast<Uint8>().asTypedList(ret.r1);
    final certificate = Certificate.fromBuffer(certificateBytes);
    bindings.FreeBytes(certificateBytesPointer);
    return certificate;
  } else if (Platform.isMacOS || Platform.isIOS) {
    final ret = await darwinHostApi!.generateTls();
    final certificate = Certificate.fromBuffer(ret);
    return certificate;
  } else {
    final ret = await androidHostApi!.generateTls();
    final certificate = Certificate.fromBuffer(ret);
    return certificate;
  }
}
