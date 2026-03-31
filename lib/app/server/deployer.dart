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
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:tm/protos/app/api/api.pb.dart';
import 'package:tm/protos/vx/common/net/net.pb.dart';
import 'package:protobuf/well_known_types/google/protobuf/any.pb.dart';
import 'package:tm/protos/vx/inbound/inbound.pb.dart';
import 'package:tm/protos/vx/outbound/outbound.pb.dart';
import 'package:tm/protos/vx/proxy/anytls/anytls.pb.dart';
import 'package:tm/protos/vx/proxy/hysteria/hysteria.pb.dart';
import 'package:tm/protos/vx/proxy/shadowsocks/shadowsocks.pb.dart';
import 'package:tm/protos/vx/proxy/trojan/trojan.pb.dart';
import 'package:tm/protos/vx/proxy/vless/vless.pb.dart';
import 'package:tm/protos/vx/proxy/vmess/vmess.pb.dart';
import 'package:tm/protos/vx/server.pb.dart';
import 'package:tm/protos/vx/transport/security/tls/certificate.pb.dart';
import 'package:tm/protos/vx/transport/security/tls/tls.pb.dart';
import 'package:tm/protos/vx/transport/transport.pb.dart';
import 'package:tm/protos/vx/user/user.pb.dart';
import 'package:tm/protos/vx/transport/protocols/grpc/config.pb.dart';
import 'package:tm/protos/vx/transport/protocols/splithttp/config.pb.dart';
import 'package:tm/protos/vx/transport/protocols/websocket/config.pb.dart';
import 'package:tm/protos/vx/transport/security/reality/config.pb.dart';
import 'package:uuid/uuid.dart';
import 'package:vx/common/common.dart';
import 'package:vx/common/config.dart';
import 'package:vx/common/domain.dart';
import 'package:flutter_common/util/net.dart';
import 'package:vx/data/database.dart';
import 'package:vx/data/ssh_server.dart';
import 'package:vx/l10n/app_localizations.dart';
import 'package:vx/main.dart';
import 'package:vx/utils/geoip.dart';
import 'package:vx/utils/logger.dart';
import 'package:vx/utils/xapi_client.dart';
import 'package:vx/widgets/circular_progress_indicator.dart';

part 'deploy.dart';

class Deployer with ChangeNotifier {
  late XApiClient xApiClient;
  Deployer({required this.xApiClient});

  /// Set of servers that are under deployment
  final deploying = <int>{};

  Future<DeployResult> deploy(
    SshServer server,
    QuickDeployOption option,
  ) async {
    if (deploying.contains(server.id)) {
      throw Exception('Server is under deployment');
    }
    deploying.add(server.id);
    notifyListeners();

    try {
      return await option.deploy(server);
    } catch (e) {
      logger.e('Failed to deploy', error: e);
      // await reportError(e, StackTrace.current);

      rethrow;
    } finally {
      deploying.remove(server.id);
      notifyListeners();
    }
  }
}

extension SshServerX on SshServer {
  Future<SshServerSecureStorage> secureStorage(
    FlutterSecureStorage storage,
  ) async {
    final json = await storage.read(key: storageKey);
    if (json == null) {
      throw Exception('Storage not found');
    }
    return SshServerSecureStorage.fromJson(jsonDecode(json));
  }
}
