import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:vx/auth/auth_provider.dart';
import 'package:vx/auth/user.dart';
import 'package:vx/main.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(this._authRepo, bool isActivated)
      : super(
          AuthState(
            user: _authRepo.currentUser,
            isActivated: isActivated,
          ),
        ) {
    on<_AuthUserChanged>(_onUserChanged);
    on<AuthActivatedEvent>(_onActivated);

    _userSubscription = _authRepo.user.listen(
      (user) {
        add(_AuthUserChanged(user));
      },
    );
  }

  void setTestUser() {
    emit(AuthState(
      user: User(id: 'test', email: 'test@test.com', pro: true),
      isActivated: false,
    ));
  }

  void unsetTestUser() {
    emit(AuthState(isActivated: false));
  }

  final AuthProvider _authRepo;
  late final StreamSubscription<User?> _userSubscription;
  late String deviceToken;

  void _onUserChanged(_AuthUserChanged event, Emitter<AuthState> emit) {
    emit(AuthState(user: event.user, isActivated: state.isActivated));
  }

  void _onActivated(AuthActivatedEvent event, Emitter<AuthState> emit) {
    emit(AuthState(user: state.user, isActivated: true));
  }

  @override
  Future<void> close() {
    _userSubscription.cancel();
    return super.close();
  }
}

abstract class AuthEvent {
  const AuthEvent();
}

class _AuthUserChanged extends AuthEvent {
  const _AuthUserChanged(this.user);

  final User? user;
}

class AuthActivatedEvent extends AuthEvent {
  const AuthActivatedEvent();
}

class AuthState extends Equatable {
  const AuthState({this.user, required this.isActivated});

  final User? user;
  final bool isActivated;

  bool get isAuthenticated => user != null;

  /// whether unlock pro features
  bool get pro {
    if (isActivated) {
      return true;
    }
    return user?.unlockPro ?? false;
  }

  @override
  List<Object?> get props => [user, isActivated];
}
