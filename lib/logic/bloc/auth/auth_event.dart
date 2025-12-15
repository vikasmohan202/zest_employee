import 'package:equatable/equatable.dart';
import 'package:zest_employee/data/models/admin_model.dart';

abstract class AuthEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthAppStarted extends AuthEvent {}

class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;
  AuthLoginRequested(this.email, this.password);
  @override
  List<Object?> get props => [email, password];
}
class AuthRestoreSession extends AuthEvent {
  final Admin employee;

  AuthRestoreSession({required this.employee});
}


class AuthSignupRequested extends AuthEvent {
  final String email;
  final String password;
  final String? name;
  AuthSignupRequested(this.email, this.password, {this.name});
  @override
  List<Object?> get props => [email, password, name];
}

class AuthLogoutRequested extends AuthEvent {
  
}
