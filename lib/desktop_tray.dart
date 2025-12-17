part of 'main.dart';

class DesktopTray extends StatefulWidget {
  const DesktopTray({super.key, required this.child});
  final Widget child;

  @override
  State<DesktopTray> createState() => _DesktopTrayState();
}

class _DesktopTrayState extends State<DesktopTray>
    with TrayListener, WindowListener {
  @override
  void initState() {
    super.initState();
    _initTray();
    trayManager.addListener(this);
    windowManager.addListener(this);
  }

  @override
  void dispose() {
    trayManager.removeListener(this);
    windowManager.removeListener(this);
    super.dispose();
  }

  @override
  void onTrayIconMouseDown() async {
    if (Platform.isWindows) {
      await windowManager.show();
    } else {
      trayManager.popUpContextMenu();
    }
  }

  @override
  void onTrayIconRightMouseDown() {
    trayManager.popUpContextMenu(bringAppToFront: true);
  }

  @override
  void onTrayMenuItemClick(MenuItem menuItem) {
    if (kDebugMode) {
      print(menuItem.toJson());
    }
  }

  // on mac this is called when the window is closed
  // on windows this seems to be called when the app is exited
  @override
  void onWindowClose() async {
    print('onWindowClose');
    if (Platform.isWindows) {
      await beforeExitCleanup();
    } else if (Platform.isLinux) {
      await exitCurrentApp();
      return;
    }
    await windowManager.hide();
    if (Platform.isMacOS) {
      await windowManager.setSkipTaskbar(true);
    }
  }

  @override
  void onWindowMove() async {
    final position = await windowManager.getPosition();
    logger.d('window move x: ${position.dx}, y: ${position.dy}');
    persistentStateRepo.setWindowX(position.dx);
    persistentStateRepo.setWindowY(position.dy);
  }

  @override
  void onWindowResize() async {
    final size = await windowManager.getSize();
    // logger.d('window resize width: ${size.width}, height: ${size.height}');
    persistentStateRepo.setWindowWidth(size.width);
    persistentStateRepo.setWindowHeight(size.height);
  }

  Future<void> _setIcon(XStatus status) async {
    late String iconPath;
    if (Platform.isWindows) {
      if (status == XStatus.connected ||
          status == XStatus.connecting ||
          status == XStatus.preparing) {
        iconPath = 'assets/icons/windows_icon.ico';
      } else {
        iconPath = 'assets/icons/windows_icon_outline.ico';
      }
    } else {
      if (status == XStatus.connected ||
          status == XStatus.connecting ||
          status == XStatus.preparing) {
        iconPath = 'assets/icons/V.png';
      } else {
        iconPath = 'assets/icons/V_outline.png';
      }
    }
    await trayManager.setIcon(iconPath,
        isTemplate: true, iconSize: Platform.isWindows ? 12 : 14);
    if (!Platform.isLinux) {
      await trayManager.setToolTip('VX');
    }
  }

  void _initTray() async {
    // await _setIcon();
    xController.statusStream().listen((status) async {
      await _setIcon(status);
      await _updateMenu(status);
    });
    await windowManager.setPreventClose(true);
    logger.d('tray manager initialized');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateMenu(xController.status);
  }

  Future<void> _updateMenu(XStatus status) async {
    logger.d('update menu status: $status');
    late MenuItem? connectMenuItem;
    switch (status) {
      case XStatus.connected:
        connectMenuItem = MenuItem(
            key: 'toggle_connection',
            label: AppLocalizations.of(context)!.disconnect,
            onClick: (menuItem) {
              Provider.of<StartCloseCubit>(context, listen: false).stop();
            });
      case XStatus.disconnected:
        connectMenuItem = MenuItem(
          key: 'toggle_connection',
          label: AppLocalizations.of(context)!.connect,
          onClick: (menuItem) {
            Provider.of<StartCloseCubit>(context, listen: false).start();
          },
        );
      case XStatus.connecting || XStatus.preparing:
        connectMenuItem = MenuItem(
            key: 'toggle_connection',
            label: AppLocalizations.of(context)!.connecting,
            disabled: true);
      case XStatus.disconnecting:
        connectMenuItem = MenuItem(
            key: 'toggle_connection',
            label: AppLocalizations.of(context)!.disconnecting,
            disabled: true);
      case XStatus.reconnecting:
        connectMenuItem = MenuItem(
            key: 'toggle_connection',
            label: AppLocalizations.of(context)!.reconnecting,
            disabled: true);
      case XStatus.unknown:
        connectMenuItem = MenuItem(
            key: 'unknown',
            label: AppLocalizations.of(context)!.unknown,
            disabled: true);
      default:
        connectMenuItem = null;
    }

    await trayManager.setContextMenu(
      Menu(
        items: [
          if (connectMenuItem != null) connectMenuItem,
          MenuItem.separator(),
          if (!Platform.isWindows)
            MenuItem(
              key: 'show_window',
              label: AppLocalizations.of(context)!.showClient,
              onClick: (menuItem) async {
                await windowManager.show();
                if (Platform.isMacOS) {
                  await windowManager.setSkipTaskbar(false);
                }
              },
            ),
          MenuItem(
            key: 'quit',
            label: AppLocalizations.of(context)!.quit,
            onClick: (menuItem) async {
              await exitCurrentApp();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

Future<void> exitCurrentApp() async {
  if (desktopPlatforms) {
    await beforeExitCleanup();
    await trayManager.destroy();
    await windowManager.destroy();
  } else {
    exit(0);
  }
}
