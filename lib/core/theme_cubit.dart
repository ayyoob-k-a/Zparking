import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit() : super(ThemeMode.system);
  void toggle() {
    if (state == ThemeMode.light) {
      emit(ThemeMode.dark);
    } else if (state == ThemeMode.dark) {
      emit(ThemeMode.light);
    } else {
      emit(ThemeMode.dark);
    }
  }
}


