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
import 'package:vx/common/extension.dart';
import 'package:vx/l10n/app_localizations.dart';

bool isCompact(BuildContext context) {
  return MediaQuery.of(context).size.isCompact;
}

String formatDuration(BuildContext context, Duration duration) {
  final l10n = AppLocalizations.of(context);
  if (duration.inDays > 0) {
    return '${duration.inDays} ${l10n!.days} ${duration.inHours % 24} ${l10n.hours}';
  } else if (duration.inHours > 0) {
    return '${duration.inHours} ${l10n!.hours} ${duration.inMinutes % 60} ${l10n.minutes}';
  } else if (duration.inMinutes > 0) {
    return '${duration.inMinutes} ${l10n!.minutes}';
  } else {
    return '${duration.inSeconds} ${l10n!.seconds}';
  }
}
