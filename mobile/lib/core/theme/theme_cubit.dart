import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeCubit extends Cubit<bool> {
  static const String _key = 'is_dark_mode';

  ThemeCubit() : super(true) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool(_key) ?? true;
    emit(isDark);
  }

  Future<void> toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final newValue = !state;
    await prefs.setBool(_key, newValue);
    emit(newValue);
  }

  Future<void> setDarkMode(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, isDark);
    emit(isDark);
  }

  bool get isDarkMode => state;
}
