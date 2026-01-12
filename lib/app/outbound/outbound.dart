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

import 'package:tm/protos/app/api/api.pb.dart';
import 'package:vx/app/outbound/outbound_repo.dart';
import 'package:vx/utils/logger.dart';
import 'package:vx/data/database.dart';
import 'package:vx/main.dart';
import 'package:vx/utils/xapi_client.dart';

/// Test usability of [handler], update it if the result conflicts with
/// the current value, return the updated handler if successful
Future<OutboundHandler?> testHandler(XApiClient xApiClient,
    OutboundHandler handler, OutboundRepo outboundRepo) async {
  try {
    final res = await xApiClient
        .handlerUsable(HandlerUsableRequest(handler: handler.toConfig()));
    final ok = res.ping > 0;
    return outboundRepo.updateHandler(handler.id,
        ok: ok ? 1 : -1,
        speed: ok ? null : 0,
        ping: res.ping,
        pingTestTime: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        serverIp: res.ip);
  } catch (e) {
    logger.e("updateHandlerUsability error: $e");
    // await reportError(e, StackTrace.current);

    return null;
  }
}
