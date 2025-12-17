import 'package:tm/protos/app/api/api.pb.dart';
import 'package:vx/app/outbound/outbound_repo.dart';
import 'package:vx/utils/logger.dart';
import 'package:vx/data/database.dart';
import 'package:vx/main.dart';

/// Test usability of [handler], update it if the result conflicts with
/// the current value, return the updated handler if successful
Future<OutboundHandler?> testHandler(
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
