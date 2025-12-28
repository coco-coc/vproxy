import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path/path.dart' as path;
import 'package:vx/app/routing/default.dart';
import 'package:vx/app/blocs/proxy_selector/proxy_selector_bloc.dart';
import 'package:vx/app/x_controller.dart';
import 'package:vx/auth/auth_bloc.dart';
import 'package:vx/l10n/app_localizations.dart';
import 'package:vx/main.dart';
import 'package:vx/pref_helper.dart';
import 'package:vx/utils/logger.dart';
import 'package:vx/xconfig_helper.dart';

enum StartCloseButtonSize {
  small(24, 16),
  middle(32, 16),
  large(32, 16);

  const StartCloseButtonSize(this.iconSize, this.progressIndicatorSize);

  final double iconSize;
  final double progressIndicatorSize;
}

class StartCloseCubit extends Cubit<XStatus> {
  StartCloseCubit({
    required PrefHelper pref,
    required XController xController,
    required AuthBloc authBloc,
  })  : _pref = pref,
        _xController = xController,
        _authBloc = authBloc,
        super(XStatus.unknown) {
    _statusSubscription = xController.statusStream().listen((status) {
      emit(status);
    }, onError: (error, stackTrace) {
      logger.e("x state stream error", error: error, stackTrace: stackTrace);
      reportError("x state stream error", error);
      emit(XStatus.unknown);
    });
  }

  final PrefHelper _pref;
  final XController _xController;
  late final StreamSubscription<XStatus> _statusSubscription;
  final AuthBloc _authBloc;

  @override
  Future<void> close() async {
    _statusSubscription.cancel();
    await super.close();
    return;
  }

  /// returns a non-null string if cannot start
  String? _canStart() {
    if (_pref.routingMode == null) {
      return rootLocalizations()?.pleaseSelectARoutingMode;
    }
    if (rootNavigationKey.currentContext != null &&
        !_authBloc.state.pro &&
        !isDefaultRouteMode(
            _pref.routingMode!, rootNavigationKey.currentContext!)) {
      return rootLocalizations()?.freeUserCannotUseCustomRoutingMode;
    }
    return null;
  }

  Future<void> start() async {
    final canStartError = _canStart();
    if (canStartError != null) {
      snack(rootLocalizations()?.startFailedWithReason(canStartError),
          duration: Duration(seconds: 60));
      return;
    }

    _pref.setConnect(true);
    try {
      await _xController.start();
    } on ConfigException catch (e) {
      snack(rootLocalizations()?.startFailedWithReason(e.message));
    } catch (e) {
      logger.e('start error', error: e, stackTrace: StackTrace.current);
      snack(rootLocalizations()?.startFailedWithReason(e.toString()));
    }
  }

  Future<void> stop() async {
    _pref.setConnect(false);
    try {
      await _xController.stop();
    } catch (e) {
      rootScaffoldMessengerKey.currentState?.showSnackBar(SnackBar(
        content: Text(e.toString()),
      ));
    }
  }
}

class StartCloseButton extends StatelessWidget {
  const StartCloseButton(
      {super.key,
      this.floating = false,
      this.size = StartCloseButtonSize.middle});

  final StartCloseButtonSize size;
  final bool floating;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StartCloseCubit, XStatus>(
      builder: (ctx, state) {
        Widget icon;
        Text text;
        Function()? onPressed;
        Color? backgroundColor;
        final progressIndicator = Padding(
          padding: const EdgeInsets.all(8.0),
          child: SizedBox(
            width: size.progressIndicatorSize,
            height: size.progressIndicatorSize,
            child: const CircularProgressIndicator(
              strokeWidth: 3,
            ),
          ),
        );
        switch (state) {
          case XStatus.connected:
            icon = Icon(
              Icons.stop,
              color: Theme.of(context).colorScheme.onErrorContainer,
              size: size.iconSize,
            );
            text = Text(AppLocalizations.of(context)!.disconnect);
            onPressed = () {
              ctx.read<StartCloseCubit>().stop();
            };
            backgroundColor = Theme.of(context).colorScheme.errorContainer;
          case XStatus.disconnected:
            icon = Icon(
              Icons.play_arrow_rounded,
              size: size.iconSize,
            );
            text = Text(AppLocalizations.of(context)!.start);
            onPressed = () {
              ctx.read<StartCloseCubit>().start();
            };
          case XStatus.connecting:
            icon = progressIndicator;
            text = Text(AppLocalizations.of(context)!.connecting);
          case XStatus.disconnecting:
            icon = Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                width: size.progressIndicatorSize,
                height: size.progressIndicatorSize,
                child: CircularProgressIndicator(
                  color: Theme.of(context).colorScheme.onErrorContainer,
                  strokeWidth: 3,
                ),
              ),
            );
            text = Text(AppLocalizations.of(context)!.disconnecting);
            backgroundColor = Theme.of(context).colorScheme.errorContainer;
          case XStatus.reconnecting:
            icon = progressIndicator;
            text = Text(AppLocalizations.of(context)!.reconnecting);
          case XStatus.preparing:
            icon = progressIndicator;
            text = Text(AppLocalizations.of(context)!.preparing);
          case XStatus.unknown:
            icon = const Icon(Icons.play_arrow_rounded);
            text = Text(AppLocalizations.of(context)!.unknown);
            onPressed = () {
              ctx.read<StartCloseCubit>().start();
            };
        }
        if (size == StartCloseButtonSize.small) {
          return FloatingActionButton.small(
            splashColor: Colors.transparent,
            hoverElevation: 0,
            elevation: floating ? 1 : 0,
            backgroundColor: backgroundColor,
            onPressed: onPressed,
            child: icon,
          );
        } else if (size == StartCloseButtonSize.large) {
          return FloatingActionButton.extended(
            splashColor: Colors.transparent,
            hoverElevation: 0,
            elevation: floating ? 1 : 0,
            backgroundColor: backgroundColor,
            onPressed: onPressed,
            label: text,
            icon: icon,
          );
        } else {
          return FloatingActionButton(
            heroTag: null,
            splashColor: Colors.transparent,
            hoverElevation: 0,
            elevation: floating ? 1 : 0,
            backgroundColor: backgroundColor,
            onPressed: onPressed,
            child: icon,
          );
        }
      },
    );
  }
}
