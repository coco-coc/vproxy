import 'dart:async';

import 'package:drift/drift.dart' hide Column;
import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:tm/protos/app/api/api.pbgrpc.dart';
import 'package:tm/protos/protos/outbound.pb.dart';
import 'package:tm/tm.dart';
import 'package:vx/app/outbound/outbound_repo.dart';
import 'package:vx/app/outbound/outbounds_bloc.dart';
import 'package:vx/main.dart';
import 'package:vx/utils/logger.dart';
import 'package:vx/data/database.dart';
import 'package:vx/pref_helper.dart';
import 'package:vx/utils/xapi_client.dart';
import 'package:vx/l10n/app_localizations.dart';
import 'package:vx/xconfig_helper.dart';

class MySubscription extends Subscription implements NodeGroup {
  MySubscription({
    required super.id,
    required super.name,
    required super.link,
    super.remainingData,
    super.endTime,
    super.website = '',
    super.description = '',
    required super.lastUpdate,
    required super.lastSuccessUpdate,
    required super.placeOnTop,
  });
}

/// Notify its liseners when subscriptions are updated
class AutoSubscriptionUpdater with ChangeNotifier {
  AutoSubscriptionUpdater(
      {required PrefHelper pref,
      required XApiClient api,
      required OutboundRepo outboundRepo})
      : _pref = pref,
        _apiClient = api,
        _outRepo = outboundRepo {
    if (_pref.autoUpdate && Tm.instance.state == TmStatus.disconnected) {
      startAutoUpdate();
    }
    Tm.instance.stateStream.listen((state) {
      // when vpn is on, auto update is done in golang
      if (state.status == TmStatus.connected) {
        stopAutoUpdate();
      } else if (state.status == TmStatus.disconnected && _pref.autoUpdate) {
        startAutoUpdate();
      }
    });
  }

  final PrefHelper _pref;
  final XApiClient _apiClient;
  final OutboundRepo _outRepo;

  Timer? timer;

  Future<DateTime> _getLastUpdate() async {
    // get the subscription with the smallest lastUpdate
    final sub = await ((database.select(database.subscriptions)
          ..orderBy([(t) => OrderingTerm(expression: t.lastUpdate)])
          ..limit(1))
        .get());
    if (sub.isEmpty) {
      return DateTime.now();
    }
    return DateTime.fromMillisecondsSinceEpoch(sub[0].lastUpdate);
  }

  void startAutoUpdate() {
    if (!running) {
      _scheduleUpdate();
    }
  }

  void stopAutoUpdate() {
    _stopTimer();
  }

  bool get running => timer != null;

  void onIntervalChange(int interval) {
    if (running) {
      _stopTimer();
      _scheduleUpdate();
    }
  }

  void _scheduleUpdate() async {
    final lastUpdate = await _getLastUpdate();
    final updateInterval = Duration(minutes: _pref.updateInterval);
    DateTime nextUpdate = lastUpdate.add(updateInterval);
    late final Duration initialDelay;
    if (nextUpdate.isBefore(DateTime.now())) {
      initialDelay = const Duration();
    } else {
      initialDelay = nextUpdate.difference(DateTime.now());
    }
    logger.d("next update in ${initialDelay.inMinutes} minutes");
    timer = Timer(initialDelay, () async {
      await updateAllSubs();
    });
  }

  Future<void> updateSub(int id) async {
    await _updateSub(false, id);
  }

  /// notify users about the result
  /// TODO: improve update experience
  Future<void> _updateSub(bool all, int id) async {
    final request = UpdateSubscriptionRequest();
    if (all) {
      request.all = true;
    } else {
      request.id = Int64(id);
    }
    final handlers = <HandlerConfig>[freedomHandlerConfig];
    handlers.addAll((await _outRepo.getHandlers(
            usable: true, limit: 10, orderBySpeed1MBDesc: true))
        .map((e) => e.toConfig()));
    request.handlers.addAll(handlers);

    final res = await _apiClient.updateSubscriptions(request);

    rootScaffoldMessengerKey.currentState?.showSnackBar(SnackBar(
        action: res.failedNodes.isNotEmpty ||
                res.errorReasons.entries.isNotEmpty
            ? SnackBarAction(
                label: rootLocalizations()?.failureDetail ?? '',
                onPressed: () {
                  showDialog(
                      context: rootNavigationKey.currentContext!,
                      builder: (context) => AlertDialog(
                            title:
                                Text(rootLocalizations()?.failureDetail ?? ''),
                            content: Column(
                              children: [
                                if (res.errorReasons.entries.isNotEmpty)
                                  Column(
                                    children: [
                                      Text(rootLocalizations()?.failedSub ?? '',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium),
                                      const Gap(10),
                                      ...res.errorReasons.entries.indexed
                                          .map((e) => ListTile(
                                                leading:
                                                    Text((e.$1 + 1).toString()),
                                                title: Text(e.$2.key),
                                                subtitle: Text(e.$2.value),
                                              )),
                                      const Gap(10),
                                    ],
                                  ),
                                Text(rootLocalizations()?.failedNodes ?? '',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium),
                                const Gap(10),
                                ...res.failedNodes.indexed.map((e) => ListTile(
                                      leading: Text((e.$1 + 1).toString()),
                                      title: Text(e.$2),
                                    )),
                              ],
                            ),
                          ));
                })
            : null,
        content: Text(rootLocalizations()?.updateSubResult(res.success,
                res.fail, res.successNodes, res.failedNodes.length) ??
            '')));
    onSubscriptionUpdated();
  }

  void onSubscriptionUpdated() {
    notifyListeners();
    // since write to database happens on the golang side. Without this,
    // watch stream on the subscriptions table will not be updated.
    database.notifyUpdates(
        {TableUpdate.onTable(database.subscriptions, kind: UpdateKind.update)});
  }

  /// update all subscriptons and schedule the next update
  Future<void> updateAllSubs() async {
    logger.d("update subscriptions");
    try {
      await _updateSub(true, 0);
    } catch (e) {
      logger.d("update subscirptions failed", error: e);
    }
    final updateInterval = Duration(minutes: _pref.updateInterval);
    logger.d("next update in ${updateInterval.inMinutes} minutes");
    _stopTimer();
    timer = Timer.periodic(updateInterval, (_) {
      updateAllSubs();
    });
  }

  void _stopTimer() {
    timer?.cancel();
    timer = null;
  }
}
