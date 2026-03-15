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

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vx/app/server/vx_bloc.dart';
import 'package:vx/l10n/app_localizations.dart';
import 'package:vx/theme.dart';
import 'package:vx/utils/ui.dart';
import 'package:vx/widgets/circular_progress_indicator.dart';

class VXServiceStatus extends StatelessWidget {
  const VXServiceStatus({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias, // Ensures ink ripples are clipped
      child: BlocBuilder<VXBloc, VXState>(
        builder: (context, state) {
          final isRunning = state is VXInstalledState && state.uptime != null;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Name and Status Chip
              ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                title: Text(AppLocalizations.of(context)!.vxCore),
                subtitle: state is VXInstalledState
                    ? Text(state.version, maxLines: 1)
                    : null,
                trailing: BlocBuilder<VXBloc, VXState>(
                  builder: (context, state) {
                    final isInstalled = state is VXInstalledState;
                    final operationInProgress = isInstalled
                        ? state.operationInProgress
                        : null;
                    final isLoading = operationInProgress != null;

                    return MenuAnchor(
                      menuChildren: [
                        MenuItemButton(
                          leadingIcon: operationInProgress == 'restart'
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: Padding(
                                    padding: EdgeInsets.all(2.0),
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                )
                              : const Icon(Icons.restart_alt_outlined),
                          onPressed: isLoading
                              ? null
                              : () {
                                  context.read<VXBloc>().add(VXRestartEvent());
                                },
                          child: Text(AppLocalizations.of(context)!.restart),
                        ),
                        MenuItemButton(
                          leadingIcon: operationInProgress == 'stop'
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: Padding(
                                    padding: EdgeInsets.all(2.0),
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                )
                              : const Icon(Icons.stop_outlined),
                          onPressed: isLoading
                              ? null
                              : () {
                                  context.read<VXBloc>().add(VXStopEvent());
                                },
                          child: Text(AppLocalizations.of(context)!.stop),
                        ),
                        MenuItemButton(
                          leadingIcon: operationInProgress == 'start'
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: Padding(
                                    padding: EdgeInsets.all(2.0),
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                )
                              : const Icon(Icons.play_arrow_outlined),
                          onPressed: isLoading
                              ? null
                              : () {
                                  context.read<VXBloc>().add(VXStartEvent());
                                },
                          child: Text(AppLocalizations.of(context)!.start),
                        ),
                        MenuItemButton(
                          leadingIcon: operationInProgress == 'update'
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: Padding(
                                    padding: EdgeInsets.all(2.0),
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                )
                              : const Icon(Icons.update_outlined),
                          onPressed: isLoading
                              ? null
                              : () {
                                  context.read<VXBloc>().add(VXUpdateEvent());
                                },
                          child: Text(AppLocalizations.of(context)!.update),
                        ),
                        const Divider(),
                        MenuItemButton(
                          leadingIcon: operationInProgress == 'uninstall'
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: Padding(
                                    padding: EdgeInsets.all(2.0),
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                )
                              : const Icon(Icons.delete_outline),
                          onPressed: isLoading
                              ? null
                              : () {
                                  context.read<VXBloc>().add(
                                    VXUninstallEvent(),
                                  );
                                },
                          child: Text(AppLocalizations.of(context)!.uninstall),
                        ),
                      ],
                      builder: (context, controller, child) {
                        final currentState = state;
                        final isInstalled = currentState is VXInstalledState;
                        final operationInProgress = isInstalled
                            ? currentState.operationInProgress
                            : null;
                        final isLoading = operationInProgress != null;

                        return IconButton(
                          onPressed: isLoading
                              ? null
                              : () {
                                  controller.open();
                                },
                          icon: isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: Padding(
                                    padding: EdgeInsets.all(4.0),
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                )
                              : const Icon(Icons.more_vert),
                        );
                      },
                    );
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
                  child: Builder(
                    builder: (context) {
                      switch (state) {
                        case VXNotInstalledState():
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 24),
                            child: Text(
                              AppLocalizations.of(context)!.vxNotInstalled,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          );
                        case VXLoadingState():
                          return const Center(
                            child: mdCircularProgressIndicator,
                          );
                        case VXInstalledState():
                          if (state.operationInProgress != null) {
                            return Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  mdCircularProgressIndicator,
                                  const SizedBox(height: 16),
                                  Text(
                                    _getOperationText(
                                      context,
                                      state.operationInProgress!,
                                    ),
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }
                          if (state.lastError != null) {
                            return Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    color: colorScheme.error,
                                    size: 48,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Error',
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      color: colorScheme.error,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0,
                                    ),
                                    child: Text(
                                      state.lastError!,
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                            color: colorScheme.onSurfaceVariant,
                                          ),
                                      textAlign: TextAlign.center,
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }
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
                                  Icons.timer_outlined,
                                ),
                                const SizedBox(height: 12),
                                _buildDetailRow(
                                  context,
                                  AppLocalizations.of(context)!.memory,
                                  '${state.memory?.toStringAsFixed(2)}MB',
                                  Icons.memory,
                                ),
                              ],
                            ),
                          );
                        case VXErrorState():
                          return Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: IconButton(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    content: SizedBox(
                                      width: 300,
                                      height: 200,
                                      child: Text(state.error),
                                    ),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.error),
                            ),
                          );
                      }
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: colorScheme.onSurfaceVariant),
            const SizedBox(width: 8),
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
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

  String _getOperationText(BuildContext context, String operation) {
    final l10n = AppLocalizations.of(context);
    switch (operation) {
      case 'restart':
        return '${l10n?.restart ?? 'Restart'}...';
      case 'stop':
        return '${l10n?.stop ?? 'Stop'}...';
      case 'start':
        return '${l10n?.start ?? 'Start'}...';
      case 'update':
        return '${l10n?.update ?? 'Update'}...';
      case 'uninstall':
        return '${l10n?.uninstall ?? 'Uninstall'}...';
      default:
        return 'Processing...';
    }
  }
}
