import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vx/app/layout_provider.dart';

void showAdaptiveDialog(BuildContext context, Widget child) {
  if (context.read<MyLayout>().isCompact) {
    showModalBottomSheet(
        useRootNavigator: true, context: context, builder: (context) => child);
  } else {
    showDialog(context: context, builder: (context) => child);
  }
}
