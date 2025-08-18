import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:z_parking/features/auth/repository/auth_repository.dart';

sealed class AuthEvent extends Equatable {
	const AuthEvent();
	@override
	List<Object?> get props => [];
}

class LoginSubmitted extends AuthEvent {
	const LoginSubmitted({required this.mobileNumber, required this.otp});
	final String mobileNumber;
	final String otp;
	@override
	List<Object?> get props => [mobileNumber, otp];
}

sealed class AuthState extends Equatable {
	const AuthState();
	@override
	List<Object?> get props => [];
}

class AuthInitial extends AuthState {
	const AuthInitial();
}

class AuthLoading extends AuthState {
	const AuthLoading();
}

class AuthAuthenticated extends AuthState {
	const AuthAuthenticated();
}

class AuthFailure extends AuthState {
	const AuthFailure(this.message);
	final String message;
	@override
	List<Object?> get props => [message];
}

class AuthBloc extends Bloc<AuthEvent, AuthState> {
	AuthBloc(this._authRepository) : super(const AuthInitial()) {
		on<LoginSubmitted>(_onLoginSubmitted);
	}

	final AuthRepository _authRepository;

	Future<void> _onLoginSubmitted(LoginSubmitted event, Emitter<AuthState> emit) async {
		emit(const AuthLoading());
		try {
			await _authRepository.login(mobileNumber: event.mobileNumber, otp: event.otp);
			emit(const AuthAuthenticated());
		} catch (e) {
			emit(AuthFailure(e.toString()));
		}
	}
}


