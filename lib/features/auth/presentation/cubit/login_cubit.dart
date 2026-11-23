import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginState extends Equatable {
  const LoginState({this.isPhoneMode = true, this.isLoading = false});

  final bool isPhoneMode;
  final bool isLoading;

  LoginState copyWith({bool? isPhoneMode, bool? isLoading}) {
    return LoginState(
      isPhoneMode: isPhoneMode ?? this.isPhoneMode,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => <Object?>[isPhoneMode, isLoading];
}

/// Drives the contact-method switch and button spinner on the login screen.
class LoginCubit extends Cubit<LoginState> {
  LoginCubit() : super(const LoginState());

  void usePhone() => emit(state.copyWith(isPhoneMode: true));

  void useEmail() => emit(state.copyWith(isPhoneMode: false));

  void startLoading() => emit(state.copyWith(isLoading: true));

  void stopLoading() => emit(state.copyWith(isLoading: false));
}
