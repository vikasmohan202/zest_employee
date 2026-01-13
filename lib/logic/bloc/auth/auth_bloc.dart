import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zest_employee/data/models/auth_results.dart';
import 'package:zest_employee/data/repositories/auth/auth_repo.dart';

import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository repo;

  AuthBloc(this.repo) : super(AuthInitial()) {
    on<AuthAppStarted>((event, emit) async {
      emit(AuthLoading());
      try {
        final res = await repo.restoreSession();
        if (res == null) {
          emit(AuthUnauthenticated());
        } else {
          emit(AuthAuthenticated(res.employee));
        }
      } catch (_) {
        emit(AuthUnauthenticated());
      }
    });

on<AuthUpdateProfileRequested>((event, emit) async {
  emit(AuthLoading());

  try {
    final res = await repo.updateProfile(
      employeeId: event.employeeId,
      fullName: event.fullName,
      email: event.email,
      phoneNumber: event.phoneNumber,
      position: event.position,
      profileImage: event.profileImage, // 🔥 IMAGE
    );

    emit(AuthAuthenticated(res.employee));
  } catch (e) {
    emit(AuthFailure(e.toString()));
  }
});


    on<AuthLoginRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final AuthResult res = await repo.login(event.email, event.password);
        
        emit(AuthAuthenticated(res.employee));
      } catch (e) {
        emit(AuthFailure(e.toString()));
        emit(AuthUnauthenticated());
      }
    });

    on<AuthSignupRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final res = await repo.signup(
          event.email,
          event.password,
          name: event.name,
        );
        emit(AuthAuthenticated(res.employee));
      } catch (e) {
        emit(AuthFailure(e.toString()));
        emit(AuthUnauthenticated());
      }
    });

    on<AuthLogoutRequested>((event, emit) async {
      await repo.logout();
      emit(AuthUnauthenticated());
    });
    on<AuthRestoreSession>((event, emit) {
      emit(AuthAuthenticated(event.employee));
    });
  }
}
