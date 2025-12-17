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
