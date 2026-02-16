import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends GetxController {
  final isDarkMode = false.obs;
  late SharedPreferences _prefs;

  @override
  void onInit() {
    super.onInit();
    _loadThemePreference();
  }

  Future<void> _loadThemePreference() async {
    _prefs = await SharedPreferences.getInstance();
    bool savedDarkMode = _prefs.getBool('dark_mode_enabled') ?? false;
    isDarkMode.value = savedDarkMode;
  }

  Future<void> toggleTheme() async {
    isDarkMode.value = !isDarkMode.value;
    await _prefs.setBool('dark_mode_enabled', isDarkMode.value);
  }
}
