import 'package:equatable/equatable.dart';
import 'package:zest_employee/data/models/admin_model.dart';

abstract class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final Admin employee;
  AuthAuthenticated(this.employee);
  @override
  List<Object?> get props => [employee];
}
class AuthProfileUpdating extends AuthState {}

class AuthProfileUpdated extends AuthState {
  final Admin employee;
  AuthProfileUpdated(this.employee);

  @override
  List<Object?> get props => [employee];
}

class AuthUnauthenticated extends AuthState {}

class AuthFailure extends AuthState {
  final String message;
  AuthFailure(this.message);
  @override
  List<Object?> get props => [message];
}
