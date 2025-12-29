import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:tm/protos/app/clientgrpc/grpc.pbgrpc.dart';
import 'package:vx/app/blocs/inbound.dart';
import 'package:vx/app/control.dart';
import 'package:vx/app/layout_provider.dart';
import 'package:vx/app/outbound/add.dart';
import 'package:vx/app/outbound/outbound_page.dart';
import 'package:vx/app/outbound/subscription.dart';
import 'package:vx/app/outbound/subscription_bloc.dart';
import 'package:vx/app/outbound/subscription_page.dart';
import 'package:vx/app/routing/default.dart';
import 'package:vx/app/routing/repo.dart';
import 'package:vx/app/blocs/proxy_selector/proxy_selector_bloc.dart';
import 'package:vx/app/x_controller.dart';
import 'package:vx/auth/auth_bloc.dart';
import 'package:vx/common/circuler_buffer.dart';
import 'package:vx/common/common.dart';
import 'package:vx/common/extension.dart';
import 'package:vx/common/net.dart';
import 'package:vx/l10n/app_localizations.dart';
import 'package:vx/pref_helper.dart';
import 'package:vx/theme.dart';
import 'package:vx/app/outbound/outbound_repo.dart';
import 'package:vx/app/outbound/outbounds_bloc.dart';
import 'package:vx/data/database.dart';
import 'package:vx/main.dart';
import 'package:collection/collection.dart';
import 'package:vx/utils/logger.dart';
import 'package:vx/widgets/home_card.dart';
import 'package:vx/widgets/no_node.dart';

part 'realtime_speed.dart';
part 'route.dart';
part 'active_nodes.dart';
part 'proxy_selector.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 300),
              child: const Stats()),
          const Gap(10),
          Expanded(
            child: Builder(builder: (ctx) {
              final hasActiveNodes =
                  ctx.watch<RealtimeSpeedNotifier>().nodeInfos.isNotEmpty;
              final mode = ctx.select<ProxySelectorBloc, ProxySelectorMode>(
                  (b) => b.state.proxySelectorMode);
              final size = MediaQuery.of(context).size;
              if (size.isCompact) {
                return ListView(
                  children: [
                    if (hasActiveNodes)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: ConstrainedBox(
                            constraints: const BoxConstraints(maxHeight: 310),
                            child: const ActiveNodes()),
                      ),
                    if (!hasActiveNodes && mode == ProxySelectorMode.manual)
                      const CurrentNodes(),
                    if (mode == ProxySelectorMode.manual)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: ConstrainedBox(
                            constraints: const BoxConstraints(maxHeight: 284),
                            child: const NodesHelper()),
                      ),
                    const _Route(),
                    const Gap(10),
                    const ProxySelector(home: true),
                    if (desktopPlatforms)
                      const Padding(
                        padding: EdgeInsets.only(top: 10),
                        child: _Inbound(),
                      ),
                    const Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: _Subscription(),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: BlocBuilder<AuthBloc, AuthState>(
                          builder: (context, state) {
                        if (state.pro) {
                          return const SizedBox.shrink();
                        }
                        return const Promotion();
                      }),
                    ),
                  ],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: LayoutBuilder(builder: (ctx, c) {
                    return ScrollConfiguration(
                      behavior: ScrollConfiguration.of(context)
                          .copyWith(scrollbars: false),
                      child: ListView(
                        children: [
                          const _Route(),
                          const Gap(10),
                          const ProxySelector(home: true),
                          if (desktopPlatforms)
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: const _Inbound(),
                            ),
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: const _Subscription(),
                          ),
                          BlocBuilder<AuthBloc, AuthState>(
                              builder: (context, state) {
                            if (state.pro) {
                              return const SizedBox.shrink();
                            }
                            return Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: ConstrainedBox(
                                  constraints:
                                      BoxConstraints(maxHeight: c.maxHeight),
                                  child: Promotion(maxHeight: c.maxHeight)),
                            );
                          })
                        ],
                      ),
                    );
                  })),
                  const Gap(10),
                  const Expanded(child: Nodes())
                ],
              );
            }),
          )
        ],
      ),
    );
  }
}

class _Subscription extends StatefulWidget {
  const _Subscription({super.key});

  @override
  State<_Subscription> createState() => _SubscriptionState();
}

class _SubscriptionState extends State<_Subscription> {
  Subscription? subscription;
  StreamSubscription<List<MySubscription>>? _subscriptionStream;

  @override
  void initState() {
    super.initState();
    _subscriptionStream =
        context.read<OutboundRepo>().getStreamOfSubs(limit: 1).listen((value) {
      if (mounted) {
        setState(() {
          subscription = value.firstOrNull;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (subscription == null) {
      return const SizedBox();
    }

    final parsedData = SubscriptionData.parse(subscription!.description);
    final hasUpdateError =
        subscription!.lastSuccessUpdate != subscription!.lastUpdate;
    final colorScheme = Theme.of(context).colorScheme;

    // Check if subscription is expiring soon (within 7 days)
    final isExpiringSoon = parsedData?.expirationDate != null &&
        parsedData!.expirationDate!.difference(DateTime.now()).inDays <= 7 &&
        parsedData.expirationDate!.isAfter(DateTime.now());

    // Check if expired
    final isExpired = parsedData?.expirationDate != null &&
        parsedData!.expirationDate!.isBefore(DateTime.now());

    return SizedBox(
      height: 120,
      child: GestureDetector(
        onTap: () {
          context
              .read<SubscriptionBloc>()
              .add(UpdateSubscriptionEvent(subscription!));
        },
        child: HomeCard(
            title: subscription!.name,
            icon: Icons.subscriptions_rounded,
            button: BlocBuilder<SubscriptionBloc, SubscriptionState>(
                builder: (ctx, satte) {
              return satte.updatingSubs.contains(subscription!.id)
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.refresh_rounded);
            }),
            child: Expanded(
              child: Column(
                children: [
                  Spacer(),
                  // Show parsed data if available
                  if (parsedData?.expirationDate != null ||
                      parsedData?.remainingData != null) ...[
                    // Data usage section
                    if (parsedData?.remainingData != null) ...[
                      Row(
                        children: [
                          Icon(
                            Icons.data_usage_rounded,
                            size: 16,
                            color: colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            parsedData!.totalData != null
                                ? '${parsedData.remainingData} / ${parsedData.totalData}'
                                : parsedData.remainingData!,
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: colorScheme.onSurface,
                                    ),
                          ),
                          const Spacer(),
                          if (parsedData.expirationDate != null)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isExpired
                                      ? Icons.error
                                      : isExpiringSoon
                                          ? Icons.warning_amber_rounded
                                          : Icons.calendar_month,
                                  size: 16,
                                  color: isExpired
                                      ? colorScheme.error
                                      : colorScheme.primary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  DateFormat('yyyy-MM-dd')
                                      .format(parsedData.expirationDate!),
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: colorScheme.onSurface,
                                      ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ],
                  ]
                  // Show description if no parsed data available
                  else if (subscription!.description.isNotEmpty) ...[
                    AutoSizeText(
                      subscription!.description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                      maxLines: 1,
                      minFontSize: 10,
                    ),
                  ],
                  // Push content to bottom
                  const Spacer(),
                  Row(
                    children: [
                      Icon(
                        hasUpdateError ? Icons.error_outline : Icons.schedule,
                        size: 12,
                        color: hasUpdateError
                            ? colorScheme.error
                            : colorScheme.onSurfaceVariant.withOpacity(0.7),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          hasUpdateError
                              ? AppLocalizations.of(context)!.failure
                              : '${AppLocalizations.of(context)!.updatedAt} ${DateFormat(
                                  'MM-dd HH:mm',
                                  Localizations.localeOf(context).toString(),
                                ).format(DateTime.fromMillisecondsSinceEpoch(subscription!.lastSuccessUpdate))}',
                          style:
                              Theme.of(context).textTheme.labelSmall?.copyWith(
                                    fontSize: 10,
                                    color: hasUpdateError
                                        ? colorScheme.error
                                        : colorScheme.onSurfaceVariant
                                            .withOpacity(0.7),
                                  ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )),
      ),
    );
  }
}

class _Inbound extends StatelessWidget {
  const _Inbound({super.key});

  @override
  Widget build(BuildContext context) {
    final disableTun = Platform.isWindows && !isRunningAsAdmin && isStore;
    return HomeCard(
        title: AppLocalizations.of(context)!.inbound,
        icon: Icons.keyboard_double_arrow_right_rounded,
        child: BlocBuilder<InboundCubit, InboundMode>(builder: (ctx, mode) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 5,
                runSpacing: 5,
                children: [
                  ChoiceChip(
                    label: Text(InboundMode.tun.toLocalString(context)),
                    selected: mode == InboundMode.tun,
                    onSelected: disableTun
                        ? null
                        : (value) => context
                            .read<InboundCubit>()
                            .setInboundMode(InboundMode.tun),
                  ),
                  ChoiceChip(
                    label: Text(InboundMode.systemProxy.toLocalString(context)),
                    selected: mode == InboundMode.systemProxy,
                    onSelected: (value) => context
                        .read<InboundCubit>()
                        .setInboundMode(InboundMode.systemProxy),
                  ),
                ],
              ),
              if (disableTun)
                Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: Text(AppLocalizations.of(context)!.tunNeedAdmin,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          )),
                ),
            ],
          );
        }));
  }
}
