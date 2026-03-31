import 'package:get/get.dart';
import '../screens/main_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/report_lost_item_screen.dart';
import '../screens/report_found_item_screen.dart';
import '../screens/browse_items_screen.dart';
import '../screens/my_items_screen.dart';
import '../screens/my_claims_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/notifications_screen.dart';
import '../screens/privacy_policy_screen.dart';
import '../screens/terms_of_service_screen.dart';
import '../screens/splash_screen.dart';
import '../screens/messages_inbox_screen.dart';
import '../screens/my_ratings_screen.dart';
import '../screens/saved_items_screen.dart';
import '../screens/help_faq_screen.dart';

class AppRoutes {
  // Route names
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String main = '/main';
  static const String reportLost = '/report-lost';
  static const String reportFound = '/report-found';
  static const String browseItems = '/browse-items';
  static const String myItems = '/my-items';
  static const String myClaims = '/my-claims';
  static const String profile = '/profile';
  static const String forgotPassword = '/forgot-password';
  static const String settings = '/settings';
  static const String notifications = '/notifications';
  static const String messages = '/messages';
  static const String myRatings = '/my-ratings';
  static const String savedItems = '/saved-items';
  static const String helpFaq = '/help-faq';
  static const String privacyPolicy = '/privacy-policy';
  static const String termsOfService = '/terms-of-service';

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
        name: forgotPassword,
        page: () => const ForgotPasswordScreen(),
        transition: Transition.rightToLeft,
      ),
      GetPage(
        name: main,
        page: () => const MainScreen(),
        transition: Transition.fadeIn,
      ),
      GetPage(
        name: home,
        page: () => const MainScreen(),
        transition: Transition.fadeIn,
      ),
      GetPage(
        name: reportLost,
        page: () => const ReportLostItemScreen(),
        transition: Transition.rightToLeft,
      ),
      GetPage(
        name: reportFound,
        page: () => const ReportFoundItemScreen(),
        transition: Transition.rightToLeft,
      ),
      GetPage(
        name: browseItems,
        page: () => const BrowseItemsScreen(),
        transition: Transition.fadeIn,
      ),
      GetPage(
        name: myItems,
        page: () => const MyItemsScreen(),
        transition: Transition.fadeIn,
      ),
      GetPage(
        name: myClaims,
        page: () => const MyClaimsScreen(),
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
        name: notifications,
        page: () => const NotificationsScreen(),
        transition: Transition.rightToLeft,
      ),
      GetPage(
        name: messages,
        page: () => const MessagesInboxScreen(),
        transition: Transition.rightToLeft,
      ),
      GetPage(
        name: myRatings,
        page: () => const MyRatingsScreen(),
        transition: Transition.rightToLeft,
      ),
      GetPage(
        name: savedItems,
        page: () => const SavedItemsScreen(),
        transition: Transition.rightToLeft,
      ),
      GetPage(
        name: helpFaq,
        page: () => const HelpFaqScreen(),
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
