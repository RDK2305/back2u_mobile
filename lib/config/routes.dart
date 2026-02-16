import 'package:get/get.dart';
import '../screens/home_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/report_lost_item_screen.dart';
import '../screens/public_found_items_screen.dart';
import '../screens/my_items_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/privacy_policy_screen.dart';
import '../screens/terms_of_service_screen.dart';
import '../screens/splash_screen.dart';

/// Application Routes
/// Define all named routes for navigation
class AppRoutes {
  // Route names
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String reportLost = '/report-lost';
  static const String reportFound = '/report-found';
  static const String browseItems = '/browse-items';
  static const String myItems = '/my-items';
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String privacyPolicy = '/privacy-policy';
  static const String termsOfService = '/terms-of-service';

  // Get all routes
  static List<GetPage> getRoutes() {
    return [
      GetPage(
        name: splash,
        page: () => const SplashScreen(),
        transition: Transition.fadeIn,
      ),
      GetPage(
        name: login,
        page: () => const LoginScreen(),
        transition: Transition.fadeIn,
      ),
      GetPage(
        name: register,
        page: () => const RegisterScreen(),
        transition: Transition.fadeIn,
      ),
      GetPage(
        name: home,
        page: () => const HomeScreen(),
        transition: Transition.fadeIn,
      ),
      GetPage(
        name: reportLost,
        page: () => const ReportLostItemScreen(),
        transition: Transition.rightToLeft,
      ),
      GetPage(
        name: reportFound,
        page: () => const PublicFoundItemsScreen(),
        transition: Transition.rightToLeft,
      ),
      GetPage(
        name: browseItems,
        page: () => const PublicFoundItemsScreen(),
        transition: Transition.fadeIn,
      ),
      GetPage(
        name: myItems,
        page: () => const MyItemsScreen(),
        transition: Transition.fadeIn,
      ),
      GetPage(
        name: profile,
        page: () => const ProfileScreen(),
        transition: Transition.fadeIn,
      ),
      GetPage(
        name: settings,
        page: () => const SettingsScreen(),
        transition: Transition.rightToLeft,
      ),
      GetPage(
        name: privacyPolicy,
        page: () => const PrivacyPolicyScreen(),
        transition: Transition.rightToLeft,
      ),
      GetPage(
        name: termsOfService,
        page: () => const TermsOfServiceScreen(),
        transition: Transition.rightToLeft,
      ),
    ];
  }
}
