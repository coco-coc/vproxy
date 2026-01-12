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

class _Route extends StatefulWidget {
  const _Route();

  @override
  State<_Route> createState() => _RouteState();
}

class _RouteState extends State<_Route> {
  List<CustomRouteMode> _configs = [];
  StreamSubscription<List<CustomRouteMode>>? _customRouteModesSubscription;

  @override
  void initState() {
    super.initState();
    _customRouteModesSubscription =
        Provider.of<RouteRepo>(context, listen: false)
            .getCustomRouteModesStream()
            .listen((value) {
      if (value.isNotEmpty) {
        setState(() {
          _configs = value;
        });
      }
    });
  }

  @override
  void dispose() {
    _customRouteModesSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<ProxySelectorBloc>();
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  Icons.alt_route_rounded,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                  size: 14,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  AppLocalizations.of(context)!.routing,
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.2,
                      ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const Gap(10),
          BlocSelector<ProxySelectorBloc, ProxySelectorState, String?>(
              selector: (state) => state.routeMode,
              builder: (context, routeModeIdx) {
                return Wrap(
                  crossAxisAlignment: WrapCrossAlignment.start,
                  spacing: 5,
                  runSpacing: 5,
                  children: [
                    ..._configs.map((e) => ChoiceChip(
                          tooltip: isDefaultRouteMode(e.name, context)
                              ? DefaultRouteMode.values
                                  .firstWhereOrNull((defaultMode) {
                                  return defaultMode.toLocalString(
                                          AppLocalizations.of(context)!) ==
                                      e.name;
                                })?.description(context)
                              : null,
                          label: Text(e.name),
                          selected: (routeModeIdx == e.name),
                          onSelected: (value) {
                            if (routeModeIdx == e.name) {
                              return;
                            }
                            bloc.add(RoutingModeSelectionChangeEvent(e));
                          },
                        )),
                  ],
                );
              }),
        ],
      ),
    );
  }
}
