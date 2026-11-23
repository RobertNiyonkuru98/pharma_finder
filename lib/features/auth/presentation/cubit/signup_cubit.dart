import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SignUpState extends Equatable {
  const SignUpState({this.isPhoneMode = true, this.isLoading = false});

  final bool isPhoneMode;
  final bool isLoading;

  SignUpState copyWith({bool? isPhoneMode, bool? isLoading}) {
    return SignUpState(
      isPhoneMode: isPhoneMode ?? this.isPhoneMode,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => <Object?>[isPhoneMode, isLoading];
}

/// Drives the contact-method switch and button spinner on the sign-up screen.
class SignUpCubit extends Cubit<SignUpState> {
  SignUpCubit() : super(const SignUpState());

  void usePhone() => emit(state.copyWith(isPhoneMode: true));

  void useEmail() => emit(state.copyWith(isPhoneMode: false));

  void startLoading() => emit(state.copyWith(isLoading: true));

  void stopLoading() => emit(state.copyWith(isLoading: false));
}
