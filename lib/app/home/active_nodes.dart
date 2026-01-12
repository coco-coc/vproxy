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

part of 'home.dart';

class Nodes extends StatelessWidget {
  const Nodes({super.key});

  @override
  Widget build(BuildContext context) {
    final realtime = context.watch<RealtimeSpeedNotifier>();
    final mode = context.select<ProxySelectorBloc, ProxySelectorMode>(
        (b) => b.state.proxySelectorMode);
    final manual = mode == ProxySelectorMode.manual;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (realtime.nodeInfos.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 300),
                child: const ActiveNodes()),
          ),
        if (realtime.nodeInfos.isEmpty && manual) const CurrentNodes(),
        Expanded(
            child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 613),
                    child: const NodesHelper())))
      ],
    );
  }
}

class CurrentNodes extends StatelessWidget {
  const CurrentNodes({super.key});

  @override
  Widget build(BuildContext context) {
    // final proxySelectorState = context.watch<ProxySelectorBloc>().state;
    // if (proxySelectorState.proxySelectorMode == ProxySelectorMode.manual) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: HomeCard(
        title: AppLocalizations.of(context)!.currentNodes,
        icon: Icons.outbound_outlined,
        child: StreamBuilder(
            stream:
                context.watch<OutboundRepo>().getHandlersStream(selected: true),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                if (snapshot.data!.isEmpty) {
                  return Center(child: AddMenuAnchor(elevatedButton: true));
                }
                return ListView.separated(
                  physics: const ClampingScrollPhysics(),
                  shrinkWrap: true,
                  separatorBuilder: (context, index) => Divider(
                    height: 1,
                    color: Colors.grey.withOpacity(0.1),
                  ),
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: () {
                            context
                                .read<OutboundBloc>()
                                .add(SelectedGroupChangeEvent(allGroup));
                            context
                                .read<OutboundBloc>()
                                .add(const SortHandlersEvent((Col.active, -1)));
                            GoRouter.of(context).go('/node');
                            (outboundTableKey.currentState
                                    as OutboundTableState)
                                .scrollToTop();
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: SizedBox(
                                height: 54,
                                child: _NodeListItem(
                                    handler: snapshot.data![index])),
                          )),
                    );
                  },
                );
              }
              return SizedBox();
            }),
      ),
    );
    // } else {
    //   return SizedBox();
    // }
  }
}

class ActiveNodes extends StatelessWidget {
  const ActiveNodes({super.key});

  @override
  Widget build(BuildContext context) {
    final realtime = context.watch<RealtimeSpeedNotifier>();
    if (realtime.nodeInfos.isEmpty) {
      return SizedBox();
    }
    return HomeCard(
        title: AppLocalizations.of(context)!.activeNodes,
        icon: Icons.outbound,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: desktopPlatforms ? 227 : 235),
          child: ListView.separated(
              shrinkWrap: true,
              physics: const ClampingScrollPhysics(),
              separatorBuilder: (context, index) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Divider(
                      height: 1,
                      color: Colors.grey.withOpacity(0.1),
                    ),
                  ),
              itemCount: realtime.nodeInfos.length,
              itemBuilder: (context, index) {
                final nodeInfo = realtime.nodeInfos[index];
                return NodeCard(
                  nodeInfo: nodeInfo,
                );
              }),
        ));
  }
}

enum NodesHelperSegment {
  // recent,
  fastest,
  lowestLatency,
}

class NodesHelper extends StatefulWidget {
  const NodesHelper({super.key});

  @override
  State<NodesHelper> createState() => _NodesHelperState();
}

class _NodesHelperState extends State<NodesHelper> {
  late NodesHelperSegment _selectedSegment;
  List<OutboundHandler> _handlers = [];
  StreamSubscription<List<OutboundHandler>>? _handlerStream;
  late OutboundRepo outboundRepo;

  @override
  void initState() {
    super.initState();
    _selectedSegment = context.read<SharedPreferences>().nodesHelperSegment;
  }

  @override
  void dispose() {
    _handlerStream?.cancel();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    outboundRepo = context.watch<OutboundRepo>();
    _loadHandlers();
  }

  void _loadHandlers() {
    _handlerStream?.cancel();
    if (_selectedSegment == NodesHelperSegment.fastest) {
      _handlerStream = outboundRepo
          .getHandlersStream(orderBySpeed1MBDesc: true, limit: 10, usable: true)
          .listen((handlers) {
        if (mounted) {
          setState(() {
            _handlers = handlers;
          });
        }
      });
    } else if (_selectedSegment == NodesHelperSegment.lowestLatency) {
      _handlerStream = outboundRepo
          .getHandlersStream(orderByPingAsc: true, limit: 10, usable: true)
          .listen((handlers) {
        if (mounted) {
          setState(() {
            _handlers = handlers;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return HomeCard(
        title: AppLocalizations.of(context)!.recommendedNodes,
        icon: Icons.recommend_outlined,
        child: Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Segmented control
              SegmentedButton<NodesHelperSegment>(
                segments: [
                  ButtonSegment(
                    value: NodesHelperSegment.fastest,
                    label: Text(
                      AppLocalizations.of(context)!.speed,
                    ),
                    icon: const Icon(Icons.speed, size: 16),
                  ),
                  ButtonSegment(
                    value: NodesHelperSegment.lowestLatency,
                    label: Text(AppLocalizations.of(context)!.latency),
                    icon: const Icon(Icons.network_check, size: 16),
                  ),
                ],
                selected: {_selectedSegment},
                onSelectionChanged: (Set<NodesHelperSegment> set) {
                  setState(() {
                    _selectedSegment = set.first;
                    _loadHandlers();
                  });
                },
              ),
              const SizedBox(height: 10),
              // Node list
              if (_handlers.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Text(
                      'No nodes available',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ),
                )
              else
                Expanded(
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const ClampingScrollPhysics(),
                    separatorBuilder: (context, index) => Divider(
                      height: 1,
                      color: Colors.grey.withOpacity(0.1),
                    ),
                    itemCount: context.read<MyLayout>().isCompact
                        ? min(3, _handlers.length)
                        : _handlers.length,
                    itemBuilder: (context, index) {
                      final manualSelect = context
                              .watch<ProxySelectorBloc>()
                              .state
                              .proxySelectorMode ==
                          ProxySelectorMode.manual;
                      return Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: manualSelect
                              ? () {
                                  context.read<OutboundBloc>().add(
                                        SwitchHandlerEvent(_handlers[index],
                                            !_handlers[index].selected),
                                      );
                                }
                              : null,
                          child: Row(
                            children: [
                              Expanded(
                                  child:
                                      _NodeListItem(handler: _handlers[index])),
                              const SizedBox(width: 4),
                              if (manualSelect)
                                Transform.scale(
                                  scale: 0.8,
                                  child: Switch(
                                      value: _handlers[index].selected,
                                      onChanged: (value) {
                                        context.read<OutboundBloc>().add(
                                            SwitchHandlerEvent(
                                                _handlers[index], value));
                                      }),
                                )
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ));
  }
}

class _NodeListItem extends StatelessWidget {
  const _NodeListItem({required this.handler});

  final OutboundHandler handler;

  @override
  Widget build(BuildContext context) {
    final speedText =
        handler.speed > 0 ? '${handler.speed.toStringAsFixed(1)} Mbps' : '--';
    final latencyText = handler.ping > 0 ? '${handler.ping}ms' : '--';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          // Country flag
          Container(
            padding: const EdgeInsets.all(4),
            child: handler.countryIcon,
          ),
          const SizedBox(width: 10),
          // Node info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AutoSizeText(handler.name, minFontSize: 10, maxLines: 1),
                Text(
                  handler.displayProtocol(),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                        fontSize: 10,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Stats
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.speed,
                    size: 14,
                    color: XBlue,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    speedText,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: XBlue,
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.network_check_rounded,
                    size: 14,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    latencyText,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontSize: 11,
                        ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
