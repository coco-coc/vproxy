part of 'outbound_page.dart';

class ActionMenuAnchor extends StatelessWidget {
  const ActionMenuAnchor({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<OutboundBloc, OutboundState,
            (bool, OutboundTableSmallScreenPreference, OutboundViewMode)>(
        selector: (state) =>
            (state.multiSelect, state.smallScreenPreference, state.viewMode),
        builder: (context, r3) {
          final (multiSelect, smallScreenPreference, viewMode) = r3;
          final bloc = context.read<OutboundBloc>();
          return MenuAnchor(
              menuChildren: [
                MenuItemButton(
                    leadingIcon: const Icon(Icons.place_rounded),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: Text(AppLocalizations.of(context)!.testArea),
                    ),
                    onPressed: () async {
                      context.read<OutboundBloc>().add(PopulateCountryEvent());
                    }),
                MenuItemButton(
                    leadingIcon: Icon(multiSelect
                        ? Icons.check_box_rounded
                        : Icons.check_box_outline_blank_rounded),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: Text(AppLocalizations.of(context)!.multiSelect),
                    ),
                    onPressed: () async {
                      context
                          .read<OutboundBloc>()
                          .add(MultiSelectEvent(!multiSelect));
                    }),
                SubmenuButton(
                  menuChildren: [
                    MenuItemButton(
                      onPressed: () async {
                        final t = await showStringForm(context,
                            title: AppLocalizations.of(context)!.addGroup);
                        if (t != null) {
                          context.read<OutboundBloc>().add(AddGroupEvent(t));
                        }
                      },
                      child: Text(AppLocalizations.of(context)!.addGroup),
                    ),
                    BlocSelector<OutboundBloc, OutboundState, List<NodeGroup>>(
                        selector: (state) => state.groups,
                        builder: (context, groups) {
                          final bloc = context.read<OutboundBloc>();
                          return SubmenuButton(
                              menuStyle: MenuStyle(
                                backgroundColor: WidgetStateProperty.all(
                                    Theme.of(context)
                                        .colorScheme
                                        .surfaceContainerLowest),
                              ),
                              menuChildren: groups
                                  .whereType<OutboundHandlerGroup>()
                                  .where((e) => e.name != defaultGroupName)
                                  .map((e) => MenuItemButton(
                                      leadingIcon: const Icon(
                                          Icons.delete_outline_rounded),
                                      child: Text(groupNametoLocalizedName(
                                          context, e.name)),
                                      onPressed: () {
                                        bloc.add(DeleteGroupEvent(e));
                                      }))
                                  .toList(),
                              child: Text(
                                  AppLocalizations.of(context)!.deleteGroup));
                        }),
                    BlocSelector<OutboundBloc, OutboundState, List<NodeGroup>>(
                        selector: (state) => state.groups,
                        builder: (context, groups) {
                          final bloc = context.read<OutboundBloc>();
                          return SubmenuButton(
                              menuStyle: MenuStyle(
                                backgroundColor: WidgetStateProperty.all(
                                    Theme.of(context)
                                        .colorScheme
                                        .surfaceContainerLowest),
                              ),
                              menuChildren: groups
                                  .whereType<OutboundHandlerGroup>()
                                  .where((e) => e.name != defaultGroupName)
                                  .map((e) => MenuItemButton(
                                      leadingIcon: Checkbox(
                                          value: e.placeOnTop,
                                          onChanged: (value) {
                                            bloc.add(
                                                OutboundHandlerGroupPlaceOnTopEvent(
                                                    e));
                                          }),
                                      child: Text(groupNametoLocalizedName(
                                          context, e.name)),
                                      onPressed: () {
                                        bloc.add(
                                            OutboundHandlerGroupPlaceOnTopEvent(
                                                e));
                                      }))
                                  .toList(),
                              child: Text(
                                  AppLocalizations.of(context)!.placeOnTop));
                        }),
                  ],
                  leadingIcon: const Icon(Icons.group_work_outlined),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: Text(AppLocalizations.of(context)!.group),
                  ),
                ),
                SubmenuButton(
                    leadingIcon: const Icon(Icons.bolt_rounded),
                    menuChildren: [
                      MenuItemButton(
                          leadingIcon: const Icon(Icons.delete_outline_rounded),
                          child: Text(
                              AppLocalizations.of(context)!.deleteUnusable),
                          onPressed: () async {
                            context
                                .read<OutboundBloc>()
                                .add(DeleteUnusableEvent());
                          }),
                    ],
                    child: Text(AppLocalizations.of(context)!.quickAction)),
                SubmenuButton(
                    leadingIcon: const Icon(Icons.tune_outlined),
                    menuChildren: [
                      MenuItemButton(
                          leadingIcon: Checkbox(
                              value: smallScreenPreference.showProtocol,
                              onChanged: (value) {
                                bloc.add(SmallScreenPreferenceEvent(
                                    protocol: value ?? false));
                              }),
                          child: Text(AppLocalizations.of(context)!.protocol),
                          onPressed: () {
                            bloc.add(SmallScreenPreferenceEvent(
                                protocol: !smallScreenPreference.showProtocol));
                          }),
                      MenuItemButton(
                          leadingIcon: Checkbox(
                              value: smallScreenPreference.showPing,
                              onChanged: (value) {
                                bloc.add(SmallScreenPreferenceEvent(
                                    ping: value ?? false));
                              }),
                          child: Text(AppLocalizations.of(context)!.latency),
                          onPressed: () {
                            bloc.add(SmallScreenPreferenceEvent(
                                ping: !smallScreenPreference.showPing));
                          }),
                      MenuItemButton(
                          leadingIcon: Checkbox(
                              value: smallScreenPreference.showUsable,
                              onChanged: (value) {
                                bloc.add(SmallScreenPreferenceEvent(
                                    usable: value ?? false));
                              }),
                          child: Text(AppLocalizations.of(context)!.usable),
                          onPressed: () {
                            bloc.add(SmallScreenPreferenceEvent(
                                usable: !smallScreenPreference.showUsable));
                          }),
                      MenuItemButton(
                          leadingIcon: Checkbox(
                              value: smallScreenPreference.showSpeed,
                              onChanged: (value) {
                                bloc.add(SmallScreenPreferenceEvent(
                                    speed: value ?? false));
                              }),
                          child: Text(AppLocalizations.of(context)!.speed),
                          onPressed: () {
                            bloc.add(SmallScreenPreferenceEvent(
                                speed: !smallScreenPreference.showSpeed));
                          }),
                      MenuItemButton(
                          leadingIcon: Checkbox(
                              value: smallScreenPreference.showActive,
                              onChanged: (value) {
                                bloc.add(SmallScreenPreferenceEvent(
                                    active: value ?? false));
                              }),
                          child: Text(
                              AppLocalizations.of(context)!.selectOneOutbound),
                          onPressed: () {
                            bloc.add(SmallScreenPreferenceEvent(
                                active: !smallScreenPreference.showActive));
                          }),
                    ],
                    child: Text(
                        AppLocalizations.of(context)!.smallScreenPreference)),
                MenuItemButton(
                  leadingIcon: Icon(viewMode == OutboundViewMode.list
                      ? Icons.grid_view_rounded
                      : Icons.view_list_rounded),
                  child: Text(viewMode == OutboundViewMode.list
                      ? AppLocalizations.of(context)!.gridView
                      : AppLocalizations.of(context)!.listView),
                  onPressed: () => bloc.add(const ToggleViewModeEvent()),
                ),
              ],
              builder: (context, controller, child) {
                return IconButton(
                    onPressed: () {
                      if (controller.isOpen) {
                        controller.close();
                      } else {
                        controller.open();
                      }
                    },
                    icon: const Icon(Icons.more_vert_rounded));
              });
        });
  }
}
