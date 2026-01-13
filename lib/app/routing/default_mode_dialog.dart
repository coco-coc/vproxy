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
import 'package:vx/app/routing/default.dart';
import 'package:vx/l10n/app_localizations.dart';

/// A dialog that allows users to select a default route mode.
/// Shows each mode with its name and description.
class DefaultRouteModeDialog extends StatefulWidget {
  const DefaultRouteModeDialog({
    super.key,
    this.initialSelection,
  });

  final DefaultRouteMode? initialSelection;

  @override
  State<DefaultRouteModeDialog> createState() => _DefaultRouteModeDialogState();
}

class _DefaultRouteModeDialogState extends State<DefaultRouteModeDialog> {
  DefaultRouteMode? _selectedMode;

  @override
  void initState() {
    super.initState();
    _selectedMode = widget.initialSelection;
  }

  @override
  Widget build(BuildContext context) {
    final al = AppLocalizations.of(context)!;
    
    return AlertDialog(
      title: Text(al.defaultRouteModes),
      scrollable: true,
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: DefaultRouteMode.values.map((mode) {
            final isSelected = _selectedMode == mode;
            return Card(
              elevation: isSelected ? 2 : 0,
              color: isSelected
                  ? Theme.of(context).colorScheme.primaryContainer
                  : Theme.of(context).colorScheme.surfaceContainerHighest,
              margin: const EdgeInsets.symmetric(vertical: 4),
              child: InkWell(
                onTap: () {
                  setState(() {
                    _selectedMode = mode;
                  });
                },
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Radio<DefaultRouteMode>(
                        value: mode,
                        groupValue: _selectedMode,
                        onChanged: (value) {
                          setState(() {
                            _selectedMode = value;
                          });
                        },
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              mode.toLocalString(AppLocalizations.of(context)!),
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: isSelected
                                        ? Theme.of(context)
                                            .colorScheme
                                            .onPrimaryContainer
                                        : null,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              mode.description(context),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: isSelected
                                        ? Theme.of(context)
                                            .colorScheme
                                            .onPrimaryContainer
                                            .withOpacity(0.8)
                                        : Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
      actions: [
        FilledButton.tonal(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(al.cancel),
        ),
        const SizedBox(width: 8),
        FilledButton(
          onPressed: _selectedMode != null
              ? () => Navigator.of(context).pop(_selectedMode)
              : null,
          child: Text(al.confirm),
        ),
      ],
    );
  }
}

/// Helper function to show the default route mode selection dialog.
/// Returns the selected [DefaultRouteMode] or null if cancelled.
Future<DefaultRouteMode?> showDefaultRouteModeDialog(
  BuildContext context, {
  DefaultRouteMode? initialSelection,
}) async {
  return await showDialog<DefaultRouteMode?>(
    context: context,
    builder: (context) => DefaultRouteModeDialog(
      initialSelection: initialSelection,
    ),
  );
}

