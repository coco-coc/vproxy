part of 'log_bloc.dart';


class LogEvent extends Equatable {
  const LogEvent();

  @override
  List<Object?> get props => [];
}

class LogBlocInitialEvent extends LogEvent {
  const LogBlocInitialEvent();
}

class _NewLogEvent extends LogEvent {
  const _NewLogEvent(this.log);
  final UserLogMessage log;
}

class LogSwitchPressedEvent extends LogEvent {
  const LogSwitchPressedEvent(this.enableLog);
  final bool enableLog;
}

class DirectPressedEvent extends LogEvent {
  const DirectPressedEvent();
}

class ProxyPressedEvent extends LogEvent {
  const ProxyPressedEvent();
}

class RejectPressedEvent extends LogEvent {
  const RejectPressedEvent();
}

class ErrorOnlyPressedEvent extends LogEvent {
  const ErrorOnlyPressedEvent();
}

class AppPressedEvent extends LogEvent {
  const AppPressedEvent(this.showApp);
  final bool showApp;
}

class HandlerPressedEvent extends LogEvent {
  const HandlerPressedEvent(this.showHandler);
  final bool showHandler;
}

class SubstringChangedEvent extends LogEvent {
  const SubstringChangedEvent(this.substring);
  final String substring;

  @override
  List<Object?> get props => [substring];
}
