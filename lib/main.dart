import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'config/app_config.dart';
import 'config/theme.dart';
import 'config/routes.dart';
import 'providers/auth_provider.dart';
import 'providers/item_provider.dart';
import 'providers/theme_provider.dart';
import 'services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize storage service
  await StorageService.init();
  
  // Initialize providers
  Get.put(AuthProvider());
  Get.put(ItemProvider());
  Get.put(ThemeProvider());
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Get.find<ThemeProvider>();
    
    return Obx(
      () => GetMaterialApp(
        title: AppConfig.appName,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: themeProvider.isDarkMode.value ? ThemeMode.dark : ThemeMode.light,
        debugShowCheckedModeBanner: false,
        
        // Use GetX named routes
        getPages: AppRoutes.getRoutes(),
        initialRoute: AppRoutes.splash,
      ),
    );
  }
}
