import 'dart:io';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vx/app/layout_provider.dart';
import 'package:vx/app/x_controller.dart';
import 'package:vx/theme.dart';
import 'package:vx/widgets/ad.dart';
import 'package:vx/auth/auth_bloc.dart';
import 'package:vx/auth/auth_provider.dart';
import 'package:vx/data/sync.dart';
import 'package:vx/l10n/app_localizations.dart';
import 'package:vx/main.dart';
import 'package:vx/utils/debug.dart';
import 'package:vx/utils/logger.dart';
import 'package:vx/utils/path.dart';
import 'package:vx/utils/upload_log.dart';
import 'package:window_manager/window_manager.dart';

import 'package:vx/app/navigation.dart';
import 'package:vx/common/common.dart';

class GlobalQuicActionMenuAnchor extends StatelessWidget {
  const GlobalQuicActionMenuAnchor({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return MenuAnchor(
      menuChildren: [
        MenuItemButton(
          leadingIcon: const Icon(Icons.sync),
          child: Text(AppLocalizations.of(context)!.sync),
          onPressed: () {
            context.read<SyncService>().sync();
          },
        ),
      ],
      builder: (context, c, child) {
        return GestureDetector(
          onTapDown: (details) {
            c.open();
          },
          child: child,
        );
      },
      child: child,
    );
  }
}

class TopBar extends StatelessWidget {
  const TopBar({super.key});

  @override
  Widget build(BuildContext context) {
    late final Widget child;
    if (Platform.isMacOS || Platform.isIOS || Platform.isAndroid) {
      // final isPro = context.watch<AuthBloc>().state.pro;
      child = SizedBox(
        height: 50,
        child: Row(
          children: [
            if (!desktopPlatforms)
              GlobalQuicActionMenuAnchor(
                child: SizedBox(
                    width: 80,
                    child: Image.asset(
                      'assets/icons/V.png',
                      width: 24,
                      height: 24,
                    )),
              ),
            Expanded(child: SizedBox()),
            if (!isProduction())
              IconButton(
                  onPressed: () async {
                    final logUploadService = context.read<LogUploadService>();
                    await logUploadService.performUpload();
                    logUploadService.stopPeriodicUpload();
                  },
                  icon: const Icon(Icons.upload)),
            IconButton(
                onPressed: () {
                  Scaffold.of(context).openEndDrawer();
                },
                icon: const Icon(Icons.tune_rounded)),
            const Gap(10),
          ],
        ),
      );
    }
    if (Platform.isWindows || Platform.isLinux) {
      child = Row(
        children: [
          GlobalQuicActionMenuAnchor(
            child: SizedBox(
                width: 80,
                child: Image.asset(
                  'assets/icons/V.png',
                  width: 18,
                  height: 18,
                  color: Theme.of(context).colorScheme.primary,
                )),
          ),
          Expanded(
              child: MoveWindow(
            child: SizedBox(),
          )),
          if (!isProduction())
            TextButton(
              onPressed: () async {
                final logUploadService = context.read<LogUploadService>();
                await logUploadService.performUpload();
              },
              child: const Text("Upload"),
            ),
          if (context.read<MyLayout>().isCompact)
            IconButton(
                onPressed: () {
                  context.push('/setting');
                },
                icon: Icon(Icons.settings_rounded)),
          IconButton(
              onPressed: () {
                Scaffold.of(context).openEndDrawer();
              },
              icon: const Icon(Icons.tune_rounded)),
          const Gap(5),
          const WindowButtons(),
          const Gap(5),
        ],
      );
    }
    return SizedBox(height: 44, child: child);
  }
}

class MyMenuBar extends StatelessWidget {
  const MyMenuBar({super.key, required this.naviDestination});

  final NaviDestination? naviDestination;

  @override
  Widget build(BuildContext context) {
    return MenuBar(
        style: const MenuStyle(
            elevation: WidgetStatePropertyAll(0),
            backgroundColor: WidgetStatePropertyAll(Colors.transparent)),
        children: [
          SubmenuButton(
            menuChildren: [
              MenuItemButton(
                  leadingIcon: const Icon(Icons.content_paste),
                  child: const Text('From Clipboard'),
                  onPressed: () {}),
              MenuItemButton(
                  leadingIcon: const Icon(Icons.edit_outlined),
                  child: const Text('Input Manually'),
                  onPressed: () {}),
              MenuItemButton(
                  leadingIcon: const Icon(Icons.photo),
                  child: const Text('Select QR Code'),
                  onPressed: () {}),
            ],
            child: Center(
                child: Text(
              'Add',
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.primary),
            )),
          )
        ]);
  }
}

const borderColor = Color(0xFF805306);
const sidebarColor = Color(0xFFF6A00C);

const backgroundStartColor = Color(0xFFFFD500);
const backgroundEndColor = Color(0xFFF6A00C);

final buttonColors = WindowButtonColors(
    iconNormal: const Color(0xFF805306),
    mouseOver: const Color(0xFFF6A00C),
    mouseDown: const Color(0xFF805306),
    iconMouseOver: const Color(0xFF805306),
    iconMouseDown: const Color(0xFFFFD500));

final closeButtonColors = WindowButtonColors(
    mouseOver: const Color(0xFFD32F2F),
    mouseDown: const Color(0xFFB71C1C),
    iconNormal: const Color(0xFF805306),
    iconMouseOver: Colors.white);

class WindowButtons extends StatelessWidget {
  const WindowButtons({super.key});
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
            onPressed: appWindow.minimize,
            icon: const Icon(Icons.remove_rounded)),
        const SizedBox(width: 4),
        IconButton(
            onPressed: appWindow.maximizeOrRestore,
            icon: Icon(
                size: 20,
                appWindow.isMaximized
                    ? Icons.fullscreen_exit_rounded
                    : Icons.fullscreen_rounded)),
        const SizedBox(width: 4),
        IconButton(
            onPressed: () async {
              if (Platform.isLinux) {
                await exitCurrentApp(context.read<XController>());
              } else {
                await windowManager.hide();
              }
            },
            icon: const Icon(Icons.close_rounded)),
      ],
    );
  }
}

class MinimizeWindowButton extends WindowButton {
  MinimizeWindowButton(
      {super.key, super.colors, VoidCallback? onPressed, bool? animate})
      : super(
            animate: animate ?? false,
            iconBuilder: (buttonContext) =>
                MinimizeIcon(color: buttonContext.iconColor),
            onPressed: onPressed ?? () => appWindow.minimize());
}
