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

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:grpc/grpc.dart';

class MyChannelCredentials extends ChannelCredentials {
  MyChannelCredentials.secure({
    this.clientCertBytes,
    this.clientCertPrivateKeyBytes,
    this.trustedServerCertBytes, //server CA or cert
    BadCertificateHandler? badCertificate,
    String? sni,
  }) : super.secure(
         certificates: trustedServerCertBytes,
         onBadCertificate: badCertificate,
         authority: sni,
       );

  final Uint8List? clientCertBytes;
  final Uint8List? clientCertPrivateKeyBytes;
  final Uint8List? trustedServerCertBytes;

  @override
  SecurityContext? get securityContext {
    final ctx = super.securityContext!;
    if (clientCertBytes != null && clientCertPrivateKeyBytes != null) {
      ctx.useCertificateChainBytes(clientCertBytes!);
      ctx.usePrivateKeyBytes(clientCertPrivateKeyBytes!);
    }
    return ctx;
  }
}
