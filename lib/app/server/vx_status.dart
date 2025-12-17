import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tm/protos/app/api/api.pb.dart';
import 'package:vx/app/server/vx_bloc.dart';
import 'package:vx/l10n/app_localizations.dart';
import 'package:vx/theme.dart';
import 'package:vx/utils/ui.dart';
import 'package:vx/widgets/circular_progress_indicator.dart';

class VXServiceStatus extends StatelessWidget {
  const VXServiceStatus({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: colorScheme.outlineVariant)),
      clipBehavior: Clip.antiAlias, // Ensures ink ripples are clipped
      child: BlocBuilder<VXBloc, VXState>(builder: (context, state) {
        final isRunning = state is VXInstalledState && state.uptime != null;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Name and Status Chip
            ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(
                AppLocalizations.of(context)!.vxCore,
              ),
              subtitle: state is VXInstalledState
                  ? Text(
                      state.version,
                      maxLines: 1,
                    )
                  : null,
              trailing: MenuAnchor(
                menuChildren: [
                  MenuItemButton(
                    leadingIcon: Icon(Icons.restart_alt_outlined),
                    onPressed: () {
                      context.read<VXBloc>().add(VXRestartEvent());
                    },
                    child: Text(AppLocalizations.of(context)!.restart),
                  ),
                  MenuItemButton(
                    leadingIcon: Icon(Icons.stop_outlined),
                    onPressed: () {
                      context.read<VXBloc>().add(VXStopEvent());
                    },
                    child: Text(AppLocalizations.of(context)!.stop),
                  ),
                  MenuItemButton(
                    leadingIcon: Icon(Icons.play_arrow_outlined),
                    onPressed: () {
                      context.read<VXBloc>().add(VXStartEvent());
                    },
                    child: Text(AppLocalizations.of(context)!.start),
                  ),
                  MenuItemButton(
                    leadingIcon: Icon(Icons.update_outlined),
                    onPressed: () {
                      context.read<VXBloc>().add(VXUpdateEvent());
                    },
                    child: Text(AppLocalizations.of(context)!.update),
                  ),
                  Divider(),
                  MenuItemButton(
                    leadingIcon: Icon(Icons.delete_outline),
                    onPressed: () {
                      context.read<VXBloc>().add(VXUninstallEvent());
                    },
                    child: Text(AppLocalizations.of(context)!.uninstall),
                  ),
                ],
                builder: (context, controller, child) {
                  return IconButton(
                      onPressed: () {
                        controller.open();
                      },
                      icon: Icon(Icons.more_vert));
                },
              ),
              contentPadding: const EdgeInsets.only(left: 16, right: 16),
              leading: Image.asset(
                'assets/icons/V.png',
                width: 18,
                height: 18,
                color: VioletBlue,
              ),
            ),
            Expanded(
              child: Center(
                child: Builder(builder: (context) {
                  switch (state) {
                    case VXNotInstalledState():
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 24),
                        child: Text(
                          AppLocalizations.of(context)!.vxNotInstalled,
                          style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              fontStyle: FontStyle.italic),
                        ),
                      );
                    case VXLoadingState():
                      return const Center(
                        child: mdCircularProgressIndicator,
                      );
                    case VXInstalledState():
                      if (!isRunning) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 24),
                          child: Text(
                            AppLocalizations.of(context)!.vxNotRunning,
                          ),
                        );
                      }
                      return Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildDetailRow(
                                context,
                                AppLocalizations.of(context)!.uptime,
                                formatDuration(context, state.uptime!),
                                Icons.timer_outlined),
                            const SizedBox(height: 12),
                            _buildDetailRow(
                                context,
                                AppLocalizations.of(context)!.memory,
                                '${state.memory?.toStringAsFixed(2)}MB',
                                Icons.memory),
                          ],
                        ),
                      );
                  }
                }),
              ),
            )
          ],
        );
      }),
    );
  }

  Widget _buildDetailRow(
      BuildContext context, String label, String value, IconData icon) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: colorScheme.onSurfaceVariant),
            const SizedBox(width: 8),
            Text(label,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: colorScheme.onSurfaceVariant)),
          ],
        ),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w500,
            fontFamily: 'Roboto Mono', // Monospace for data looks technical
          ),
        ),
      ],
    );
  }
}
