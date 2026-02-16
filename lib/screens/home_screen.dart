import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../config/theme.dart';
import '../config/routes.dart';
import '../providers/auth_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthProvider _authProvider = Get.find<AuthProvider>();
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildAppBar(),
      body: _buildBody(),
      bottomNavigationBar: _buildBottomNav(),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('Back2U'),
      elevation: 0,
      actions: [
        Obx(() {
          final userName = _authProvider.getUserDisplayName() ?? 'User';
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.paddingMedium),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Hi, $userName',
                    style: const TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                ],
              ),
            ),
          );
        }),
        PopupMenuButton<String>(
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            const PopupMenuItem<String>(
              value: 'profile',
              child: Text('Profile'),
            ),
            const PopupMenuItem<String>(
              value: 'settings',
              child: Text('Settings'),
            ),
            const PopupMenuDivider(),
            const PopupMenuItem<String>(
              value: 'logout',
              child: Text('Logout'),
            ),
          ],
          onSelected: (String value) async {
            if (value == 'logout') {
              await _authProvider.logout();
              Get.offAllNamed(AppRoutes.login);
            } else if (value == 'profile') {
              Get.toNamed(AppRoutes.profile);
            } else if (value == 'settings') {
              Get.toNamed(AppRoutes.settings);
            }
          },
        ),
      ],
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.paddingLarge,
          vertical: AppTheme.paddingMedium,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: AppTheme.paddingMedium),
            _buildWelcomeCard(),
            SizedBox(height: AppTheme.paddingLarge),
            _buildQuickActions(),
            SizedBox(height: AppTheme.paddingLarge),
            _buildRecentActivity(),
            SizedBox(height: AppTheme.paddingLarge),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor,
            AppTheme.primaryLightColor,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        boxShadow: [AppTheme.shadowMedium],
      ),
      padding: const EdgeInsets.all(AppTheme.paddingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome to Back2U',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
            ),
          ),
          SizedBox(height: AppTheme.paddingSmall),
          Text(
            'Find or report lost and found items on campus',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        SizedBox(height: AppTheme.paddingMedium),
        SizedBox(
          height: 120,
          child: ListView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            children: [
              _buildActionCard(
                icon: Icons.note_add,
                label: 'Report Lost',
                color: AppTheme.errorColor,
                onTap: () => Get.toNamed(AppRoutes.reportLost),
              ),
              SizedBox(width: AppTheme.paddingMedium),
              _buildActionCard(
                icon: Icons.add_location,
                label: 'Report Found',
                color: AppTheme.successColor,
                onTap: () => Get.toNamed(AppRoutes.reportFound),
              ),
              SizedBox(width: AppTheme.paddingMedium),
              _buildActionCard(
                icon: Icons.search,
                label: 'Browse Items',
                color: AppTheme.infoColor,
                onTap: () => Get.toNamed(AppRoutes.browseItems),
              ),
              SizedBox(width: AppTheme.paddingMedium),
              _buildActionCard(
                icon: Icons.history,
                label: 'My Items',
                color: AppTheme.warningColor,
                onTap: () => Get.toNamed(AppRoutes.myItems),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        ),
        child: Container(
          width: 100,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                color.withValues(alpha: 0.1),
                color.withValues(alpha: 0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withValues(alpha: 0.2),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              SizedBox(height: AppTheme.paddingSmall),
              Text(
                label,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Activity',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            TextButton(
              onPressed: () => Get.toNamed(AppRoutes.browseItems),
              child: const Text('See All'),
            ),
          ],
        ),
        SizedBox(height: AppTheme.paddingMedium),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.paddingMedium),
            child: Column(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 48,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
                SizedBox(height: AppTheme.paddingMedium),
                Text(
                  'No Recent Items',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                SizedBox(height: AppTheme.paddingSmall),
                Text(
                  'Report a lost item or browse found items to get started',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                SizedBox(height: AppTheme.paddingLarge),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => Get.toNamed(AppRoutes.reportLost),
                        icon: const Icon(Icons.note_add),
                        label: const Text('Report Lost'),
                      ),
                    ),
                    SizedBox(width: AppTheme.paddingMedium),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => Get.toNamed(AppRoutes.browseItems),
                        icon: const Icon(Icons.search),
                        label: const Text('Browse'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: (index) {
        setState(() => _selectedIndex = index);
        switch (index) {
          case 0:
            // Home - already here
            break;
          case 1:
            Get.toNamed(AppRoutes.myItems);
            break;
          case 2:
            Get.toNamed(AppRoutes.profile);
            break;
        }
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.list),
          label: 'My Items',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: () => Get.toNamed(AppRoutes.reportLost),
      child: const Icon(Icons.add),
    );
  }
}
