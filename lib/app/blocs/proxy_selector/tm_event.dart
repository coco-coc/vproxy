part of 'proxy_selector_bloc.dart';

sealed class ProxySelectorEvent extends Equatable {
  const ProxySelectorEvent();

  @override
  List<Object> get props => [];

  @override
  bool get stringify => true;
}

class XBlocInitialEvent extends ProxySelectorEvent {}

class AuthUserChangedEvent extends ProxySelectorEvent {
  const AuthUserChangedEvent(this.unlockPro);
  final bool unlockPro;

  @override
  List<Object> get props => [unlockPro];
}


class RoutingModeSelectionChangeEvent extends ProxySelectorEvent {
  const RoutingModeSelectionChangeEvent(this.routeMode);
  final CustomRouteMode routeMode;
}

class CustomRouteModeChangeEvent extends ProxySelectorEvent {
  const CustomRouteModeChangeEvent(this.routeMode);
  final CustomRouteMode routeMode;
}

class CustomRouteModeDeleteEvent extends ProxySelectorEvent {
  const CustomRouteModeDeleteEvent(this.routeMode);
  final CustomRouteMode routeMode;
}

class InboundModeChangeEvent extends ProxySelectorEvent {
  const InboundModeChangeEvent(this.mode);
  final InboundMode mode;
}

class ProxySelectorModeChangeEvent extends ProxySelectorEvent {
  const ProxySelectorModeChangeEvent(this.mode);
  final ProxySelectorMode mode;

  @override
  List<Object> get props => [mode];
}

class ManualSelectionModeChangeEvent extends ProxySelectorEvent {
  const ManualSelectionModeChangeEvent(this.mode);
  final ProxySelectorManualNodeSelectionMode mode;
}

class ManualNodeBalanceStrategyChangeEvent extends ProxySelectorEvent {
  const ManualNodeBalanceStrategyChangeEvent(this.strategy);
  final SelectorConfig_BalanceStrategy strategy;
}

class ManualModeLandHandlersChangeEvent extends ProxySelectorEvent {
  const ManualModeLandHandlersChangeEvent();
  // final List<int> landHandlers;
}

class AutoNodeSelectorConfigChangeEvent extends ProxySelectorEvent {
  const AutoNodeSelectorConfigChangeEvent({
    this.selectorStrategyOrLandHandlers = false,
    this.balancingStragegy = false,
    this.filterLandHandlers = false,
  });

  final bool selectorStrategyOrLandHandlers;
  final bool balancingStragegy;
  final bool filterLandHandlers;
}

