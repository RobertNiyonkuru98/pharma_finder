import 'package:flutter_bloc/flutter_bloc.dart';

/// Tab index for the bottom navigation shell.
class NavigationCubit extends Cubit<int> {
  NavigationCubit([super.initialIndex = 0]);

  static const int homeTab = 0;
  static const int searchTab = 1;
  static const int sosTab = 2;
  static const int profileTab = 3;

  void select(int index) {
    if (index != state) emit(index);
  }
}