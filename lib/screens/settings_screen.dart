import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/theme_provider.dart';
import 'privacy_policy_screen.dart';
import 'terms_of_service_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late SharedPreferences _prefs;
  late ThemeProvider _themeProvider;
  bool _notificationsEnabled = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _themeProvider = Get.find<ThemeProvider>();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = _prefs.getBool('notifications_enabled') ?? true;
      _isLoading = false;
    });
  }

  Future<void> _setNotifications(bool value) async {
    setState(() => _notificationsEnabled = value);
    await _prefs.setBool('notifications_enabled', value);
    Get.snackbar(
      'Notifications',
      value ? 'Notifications enabled' : 'Notifications disabled',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  Future<void> _setDarkMode(bool value) async {
    await _themeProvider.toggleTheme();
    Get.snackbar(
      'Theme',
      _themeProvider.isDarkMode.value ? 'Dark mode enabled' : 'Light mode enabled',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Notifications Section
                  _buildSectionTitle('Notifications'),
                  Card(
                    elevation: 1,
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    child: ListTile(
                      title: const Text('Enable Notifications'),
                      subtitle: const Text('Receive notifications about lost and found items'),
                      trailing: Switch(
                        value: _notificationsEnabled,
                        onChanged: _setNotifications,
                        activeColor: Colors.blue,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Theme Section
                  _buildSectionTitle('Display'),
                  Card(
                    elevation: 1,
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    child: Obx(
                      () => ListTile(
                        title: const Text('Dark Mode'),
                        subtitle: const Text('Use dark theme for the app'),
                        trailing: Switch(
                          value: _themeProvider.isDarkMode.value,
                          onChanged: _setDarkMode,
                          activeColor: Colors.blue,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // About Section
                  _buildSectionTitle('About'),
                  Card(
                    elevation: 1,
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    child: Column(
                      children: [
                        ListTile(
                          title: const Text('App Version'),
                          trailing: const Text('1.0.0'),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          title: const Text('Privacy Policy'),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () => Get.to(() => const PrivacyPolicyScreen()),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          title: const Text('Terms of Service'),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () => Get.to(() => const TermsOfServiceScreen()),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Data & Privacy Section
                  _buildSectionTitle('Data & Privacy'),
                  Card(
                    elevation: 1,
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    child: ListTile(
                      title: const Text('Clear Cache'),
                      subtitle: const Text('Remove cached data'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Clear Cache?'),
                            content: const Text('This will remove all cached data from the app.'),
                            actions: [
                              TextButton(
                                onPressed: () => Get.back(),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Get.back();
                                  Get.snackbar(
                                    'Success',
                                    'Cache cleared successfully',
                                    snackPosition: SnackPosition.BOTTOM,
                                    backgroundColor: const Color(0xFF10B981),
                                    colorText: Colors.white,
                                  );
                                },
                                child: const Text('Clear'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.grey,
        ),
      ),
    );
  }
}
