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

import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tm/protos/app/api/api.pbgrpc.dart';
import 'package:tm/protos/common/log/log.pbenum.dart';
import 'package:tm/protos/protos/inbound.pb.dart';
import 'package:tm/protos/protos/logger.pb.dart';
import 'package:tm/protos/protos/outbound.pb.dart';
import 'package:vx/app/outbound/outbound_repo.dart';
import 'package:vx/app/outbound/outbounds_bloc.dart';
import 'package:vx/data/database.dart';
import 'package:vx/l10n/app_localizations.dart';
import 'package:vx/main.dart';
import 'package:vx/utils/logger.dart';
import 'package:vx/utils/ui.dart';
import 'package:vx/utils/xapi_client.dart';
import 'package:tm/protos/protos/server/server.pb.dart';

abstract class VXEvent {}

class VXBlocInitialEvent extends VXEvent {}

class VXRestartEvent extends VXEvent {}

class VXStopEvent extends VXEvent {}

class VXStartEvent extends VXEvent {}

class VXUpdateEvent extends VXEvent {}

class VXUninstallEvent extends VXEvent {}

class VXAddInboundEvent extends VXEvent {
  final ProxyInboundConfig inbound;
  VXAddInboundEvent(this.inbound);
}

class VXAddMultiInboundEvent extends VXEvent {
  final MultiProxyInboundConfig multiInbound;
  VXAddMultiInboundEvent(this.multiInbound);
}

class VXEditInboundEvent extends VXEvent {
  final int index;
  final ProxyInboundConfig inbound;
  VXEditInboundEvent(this.index, this.inbound);
}

class VXEditMultiInboundEvent extends VXEvent {
  final int index;
  final MultiProxyInboundConfig multiInbound;
  VXEditMultiInboundEvent(this.index, this.multiInbound);
}

class VXRemoveInboundEvent extends VXEvent {
  final String tag;
  VXRemoveInboundEvent(this.tag);
}

class VXRemoveMultiInboundEvent extends VXEvent {
  final String tag;
  VXRemoveMultiInboundEvent(this.tag);
}

class VXAddToNodesEvent extends VXEvent {
  final ProxyInboundConfig? inbound;
  final MultiProxyInboundConfig? multiInbound;
  VXAddToNodesEvent({this.inbound, this.multiInbound});
}

class VXSaveConfigEvent extends VXEvent {}

class VXReloadConfigEvent extends VXEvent {}

class VXDiscardChangesEvent extends VXEvent {}

class _RefreshVXStatusEvent extends VXEvent {
  _RefreshVXStatusEvent();
}

class VXSetLogLevelEvent extends VXEvent {
  final Level logLevel;
  VXSetLogLevelEvent(this.logLevel);
}

sealed class VXState extends Equatable {
  @override
  List<Object?> get props => [];
}

class VXLoadingState extends VXState {
  VXLoadingState();
}

class VXErrorState extends VXState {
  final String error;
  VXErrorState(this.error);
  @override
  List<Object?> get props => [error];
}

class VXNotInstalledState extends VXState {
  VXNotInstalledState();
}

class VXInstalledState extends VXState {
  final String version;
  final Duration? uptime;
  final double? memory;
  final ServerConfig? config;
  final bool configUnsaved;
  final bool isSavingConfig;

  VXInstalledState(
      {required this.version,
      this.uptime,
      this.memory,
      this.config,
      this.isSavingConfig = false,
      this.configUnsaved = false});

  @override
  List<Object?> get props =>
      [version, uptime, memory, config, configUnsaved, isSavingConfig];

  VXInstalledState copyWith({
    String? version,
    Duration? uptime,
    double? memory,
    ValueGetter<ServerConfig?>? config,
    bool? configUnsaved,
    bool? isSavingConfig,
  }) {
    return VXInstalledState(
        version: version ?? this.version,
        uptime: uptime ?? this.uptime,
        memory: memory ?? this.memory,
        config: config != null ? config() : this.config,
        configUnsaved: configUnsaved ?? this.configUnsaved,
        isSavingConfig: isSavingConfig ?? this.isSavingConfig);
  }

  @override
  String toString() {
    return 'VproxyInstalledState(version: $version, uptime: $uptime, memory: $memory, configUnsaved: $configUnsaved, config: ${config != null ? '<ServerConfig>' : 'null'})';
  }
}

class VXBloc extends Bloc<VXEvent, VXState> {
  VXBloc({
    required XApiClient xapiClient,
    required SshServer server,
    required OutboundBloc outboundBloc,
  })  : _xapiClient = xapiClient,
        _server = server,
        _outboundBloc = outboundBloc,
        super(VXLoadingState()) {
    on<VXBlocInitialEvent>(_onVproxyBlocInitialEvent);
    on<_RefreshVXStatusEvent>(_onRefreshVXStatusEvent);
    on<VXRestartEvent>(_onVproxyRestartEvent);
    on<VXStopEvent>(_onVproxyStopEvent);
    on<VXStartEvent>(_onVproxyStartEvent);
    on<VXUpdateEvent>(_onVproxyUpdateEvent);
    on<VXUninstallEvent>(_onVproxyUninstallEvent);
    on<VXAddInboundEvent>(_onVproxyAddInboundEvent);
    on<VXAddMultiInboundEvent>(_onVproxyAddMultiInboundEvent);
    on<VXEditInboundEvent>(_onVproxyEditInboundEvent);
    on<VXEditMultiInboundEvent>(_onVproxyEditMultiInboundEvent);
    on<VXRemoveInboundEvent>(_onVproxyRemoveInboundEvent);
    on<VXRemoveMultiInboundEvent>(_onVproxyRemoveMultiInboundEvent);
    on<VXSaveConfigEvent>(_onVproxySaveConfigEvent);
    on<VXReloadConfigEvent>(_onVproxyReloadConfigEvent);
    on<VXDiscardChangesEvent>(_onVproxyDiscardChangesEvent);
    on<VXAddToNodesEvent>(_onVproxyAddToNodesEvent);
    on<VXSetLogLevelEvent>(_onVproxySetLogLevelEvent);
  }

  @override
  void onTransition(Transition<VXEvent, VXState> transition) {
    if (transition.event is _RefreshVXStatusEvent) {
      return;
    }
    super.onTransition(transition);
  }

  final XApiClient _xapiClient;
  final SshServer _server;
  final OutboundBloc _outboundBloc;
  ServerConfig? _originalConfig;
  Timer? _timer;
  bool _isRunning = true;

  @override
  Future<void> close() {
    _isRunning = false;
    _timer?.cancel();
    return super.close();
  }

  Future<void> _onVproxyBlocInitialEvent(
      VXBlocInitialEvent event, Emitter<VXState> emit) async {
    // periodically fetch vx status
    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 10), (timer) async {
      add(_RefreshVXStatusEvent());
    });
    add(_RefreshVXStatusEvent());
  }

  Future<void> _onRefreshVXStatusEvent(
      _RefreshVXStatusEvent event, Emitter<VXState> emit) async {
    late VproxyStatusResponse status;
    try {
      status = await _xapiClient.vproxyStatus(_server);
      if (!_isRunning) {
        return;
      }
    } catch (e) {
      emit(VXErrorState(e.toString()));
    }

    if (status.installed) {
      VXInstalledState s = state is VXInstalledState
          ? (state as VXInstalledState).copyWith(
              version: status.version,
              uptime: status.startTime.isNotEmpty
                  ? durationUntilNow(status.startTime)
                  : null,
              memory: status.memory != 0 ? status.memory : null)
          : VXInstalledState(
              version: status.version,
              uptime: status.startTime.isNotEmpty
                  ? durationUntilNow(status.startTime)
                  : null,
              memory: status.memory != 0 ? status.memory : null);
      // convert startTime to duration+
      emit(s);
      if (s.config == null) {
        try {
          _originalConfig = await _xapiClient.serverConfig(_server);
          emit((state as VXInstalledState)
              .copyWith(config: () => _originalConfig));
        } catch (e) {
          logger.e('Failed to fetch server config: $e');
          emit((state as VXInstalledState)
              .copyWith(config: () => ServerConfig()));
        }
      }
    } else {
      emit(VXNotInstalledState());
    }
  }

  Future<void> _onVproxyReloadConfigEvent(
      VXReloadConfigEvent event, Emitter<VXState> emit) async {
    _originalConfig = await _xapiClient.serverConfig(_server);
    emit((state as VXInstalledState).copyWith(config: () => _originalConfig));
  }

  Future<void> _onVproxyRestartEvent(
      VXRestartEvent event, Emitter<VXState> emit) async {
    await _xapiClient.vx(_server, restart: true);
    add(_RefreshVXStatusEvent());
  }

  Future<void> _onVproxyStopEvent(
      VXStopEvent event, Emitter<VXState> emit) async {
    await _xapiClient.vx(_server, stop: true);
    add(_RefreshVXStatusEvent());
  }

  Future<void> _onVproxyStartEvent(
      VXStartEvent event, Emitter<VXState> emit) async {
    await _xapiClient.vx(_server, start: true);
    add(_RefreshVXStatusEvent());
  }

  Future<void> _onVproxyUpdateEvent(
      VXUpdateEvent event, Emitter<VXState> emit) async {
    await _xapiClient.vx(_server, update: true);
    add(_RefreshVXStatusEvent());
  }

  Future<void> _onVproxyUninstallEvent(
      VXUninstallEvent event, Emitter<VXState> emit) async {
    await _xapiClient.vx(_server, uninstall: true);
    add(_RefreshVXStatusEvent());
  }

  Future<void> _onVproxyAddInboundEvent(
      VXAddInboundEvent event, Emitter<VXState> emit) async {
    final state = this.state as VXInstalledState;
    if (state.config == null) {
      return;
    }
    final copy = state.config!.deepCopy();
    copy.inbounds.add(event.inbound);
    emit(state.copyWith(
        configUnsaved: copy != _originalConfig, config: () => copy));
  }

  Future<void> _onVproxyAddMultiInboundEvent(
      VXAddMultiInboundEvent event, Emitter<VXState> emit) async {
    final state = this.state as VXInstalledState;
    if (state.config == null) {
      return;
    }
    final copy = state.config!.deepCopy();
    copy.multiInbounds.add(event.multiInbound);
    emit(state.copyWith(
        configUnsaved: copy != _originalConfig, config: () => copy));
  }

  Future<void> _onVproxyEditInboundEvent(
      VXEditInboundEvent event, Emitter<VXState> emit) async {
    final state = this.state as VXInstalledState;
    if (state.config == null) {
      return;
    }
    final copy = state.config!.deepCopy();
    copy.inbounds[event.index] = event.inbound;
    emit(state.copyWith(
        configUnsaved: copy != _originalConfig, config: () => copy));
  }

  Future<void> _onVproxyEditMultiInboundEvent(
      VXEditMultiInboundEvent event, Emitter<VXState> emit) async {
    final state = this.state as VXInstalledState;
    if (state.config == null) {
      return;
    }
    final copy = state.config!.deepCopy();
    copy.multiInbounds[event.index] = event.multiInbound;
    emit(state.copyWith(
        configUnsaved: copy != _originalConfig, config: () => copy));
  }

  Future<void> _onVproxyRemoveInboundEvent(
      VXRemoveInboundEvent event, Emitter<VXState> emit) async {
    final state = this.state as VXInstalledState;
    if (state.config == null) {
      return;
    }
    final copy = state.config!.deepCopy();
    copy.inbounds.removeWhere((e) => e.tag == event.tag);
    emit(state.copyWith(
        configUnsaved: copy != _originalConfig, config: () => copy));
  }

  Future<void> _onVproxyRemoveMultiInboundEvent(
      VXRemoveMultiInboundEvent event, Emitter<VXState> emit) async {
    final state = this.state as VXInstalledState;
    if (state.config == null) {
      return;
    }
    final copy = state.config!.deepCopy();
    copy.multiInbounds.removeWhere((e) => e.tag == event.tag);
    emit(state.copyWith(
        configUnsaved: copy != _originalConfig, config: () => copy));
  }

  Future<void> _onVproxySaveConfigEvent(
      VXSaveConfigEvent event, Emitter<VXState> emit) async {
    final state = this.state as VXInstalledState;
    try {
      emit(state.copyWith(isSavingConfig: true));
      await _xapiClient.updateServerConfig(_server, state.config!);
      _originalConfig = state.config!.deepCopy();
      emit(state.copyWith(configUnsaved: false, isSavingConfig: false));
      snack(rootLocalizations()?.applySuccess ?? 'Saved successfully');
    } catch (e) {
      snack(rootLocalizations()?.applyFailed ?? 'Failed to apply: $e');
      emit(state.copyWith(isSavingConfig: false));
    }
  }

  Future<void> _onVproxyDiscardChangesEvent(
      VXDiscardChangesEvent event, Emitter<VXState> emit) async {
    final state = this.state as VXInstalledState;
    try {
      // Fetch the config from the server again to discard local changes
      _originalConfig = await _xapiClient.serverConfig(_server);
      emit(state.copyWith(config: () => _originalConfig, configUnsaved: false));
    } catch (e) {
      emit(state.copyWith(config: () => null, configUnsaved: false));
    }
  }

  Future<void> _onVproxyAddToNodesEvent(
      VXAddToNodesEvent event, Emitter<VXState> emit) async {
    final outbounds = await _xapiClient.convertInboundToOutbound(_server,
        inbound: event.inbound, multiInbound: event.multiInbound);
    _outboundBloc.add(AddHandlersEvent(
        outbounds.map((e) => HandlerConfig(outbound: e)).toList(),
        groupName: _server.name));
  }

  Future<void> _onVproxySetLogLevelEvent(
      VXSetLogLevelEvent event, Emitter<VXState> emit) async {
    final state = this.state as VXInstalledState;
    if (state.config == null) {
      return;
    }
    final copy = state.config!.deepCopy();
    if (copy.hasLog()) {
      copy.log.logLevel = event.logLevel;
    } else {
      copy.log = LoggerConfig(logLevel: event.logLevel);
    }
    emit(state.copyWith(
        configUnsaved: copy != _originalConfig, config: () => copy));
  }
}

Duration durationUntilNow(String unixTimestamp) {
  final now = DateTime.now().toUtc();
  final duration = now.difference(
      DateTime.fromMillisecondsSinceEpoch(int.parse(unixTimestamp) * 1000));
  return duration;
}
