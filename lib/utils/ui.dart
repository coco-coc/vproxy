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
