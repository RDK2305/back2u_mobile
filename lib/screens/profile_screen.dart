import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../providers/auth_provider.dart';
import '../providers/notification_provider.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import '../config/routes.dart';
import '../config/theme.dart';
import 'settings_screen.dart';
import 'notifications_screen.dart';
import 'messages_inbox_screen.dart';
import 'my_ratings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _programController = TextEditingController();
  bool _isLoading = false;
  bool _isEditing = false;

  // Rating state
  double _avgRating = 0;
  int _totalRatings = 0;
  bool _ratingsLoaded = false;

  @override
  void initState() {
    super.initState();
    _populateFields();
    _loadRatings();
  }

  Future<void> _loadRatings() async {
    try {
      final user = Get.find<AuthProvider>().currentUser.value;
      if (user == null) return;
      final data = await ApiService().getUserAverageRating(user.id);
      if (mounted) {
        setState(() {
          _avgRating = double.tryParse(
                  data['average']?.toString() ??
                  data['avg_rating']?.toString() ?? '0') ??
              0;
          _totalRatings = data['total'] ?? data['total_ratings'] ?? 0;
          _ratingsLoaded = true;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _ratingsLoaded = true);
    }
  }

  void _populateFields() {
    final user = Get.find<AuthProvider>().currentUser.value;
    if (user != null) {
      _firstNameController.text = user.firstName;
      _lastNameController.text = user.lastName;
      _programController.text = user.program ?? '';
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _programController.dispose();
    super.dispose();
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final token = AuthService().getToken();
      if (token == null) {
        _toast('Not authenticated', isError: true);
        return;
      }

      await ApiService().updateProfile(token, {
        'first_name': _firstNameController.text.trim(),
        'last_name': _lastNameController.text.trim(),
        if (_programController.text.trim().isNotEmpty)
          'program': _programController.text.trim(),
      });

      setState(() => _isEditing = false);
      _toast('Profile updated successfully');
    } catch (e) {
      _toast(
          e.toString().replaceAll('Exception: ', ''), isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _toast(String message, {bool isError = false}) {
    Get.snackbar(
      isError ? 'Error' : 'Success',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor:
          isError ? AppTheme.errorColor : AppTheme.successColor,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(12),
      borderRadius: 12,
      icon: Icon(
        isError ? Icons.error_outline : Icons.check_circle_outline,
        color: Colors.white,
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.errorColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.logout, color: AppTheme.errorColor, size: 20),
            ),
            const SizedBox(width: 12),
            const Text('Sign Out', style: TextStyle(fontSize: 18)),
          ],
        ),
        content: const Text(
            'Are you sure you want to sign out of your account?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              await Get.find<AuthProvider>().logout();
              Get.offAllNamed(AppRoutes.login);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Sign Out',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Get.find<AuthProvider>();
    final notifProvider = Get.find<NotificationProvider>();

    return Obx(() {
      final user = authProvider.currentUser.value;
      final initials =
          '${user?.firstName.isNotEmpty == true ? user!.firstName[0] : 'U'}${user?.lastName.isNotEmpty == true ? user!.lastName[0] : 'S'}'
              .toUpperCase();

      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── Gradient AppBar ──────────────────────────────────────────────
            SliverAppBar(
              expandedHeight: 220,
              pinned: true,
              automaticallyImplyLeading: false,
              backgroundColor: AppTheme.primaryColor,
              actions: [
                // Notifications icon with badge
                Obx(() {
                  final count = notifProvider.unreadCount.value;
                  return Stack(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.notifications_outlined,
                            color: Colors.white),
                        onPressed: () => Get.to(() => const NotificationsScreen()),
                        tooltip: 'Notifications',
                      ),
                      if (count > 0)
                        Positioned(
                          right: 8,
                          top: 8,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              count > 9 ? '9+' : '$count',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                }),
                IconButton(
                  icon: const Icon(Icons.settings_outlined, color: Colors.white),
                  onPressed: () => Get.to(() => const SettingsScreen()),
                  tooltip: 'Settings',
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFF1E3A8A),
                        Color(0xFF2563EB),
                        Color(0xFF3B82F6),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: SafeArea(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 36),
                        // Avatar
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              initials,
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E3A8A),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '${user?.firstName ?? ''} ${user?.lastName ?? ''}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Role badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            (user?.role ?? 'student').toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Info cards
                    _buildInfoSection(user),
                    const SizedBox(height: 20),

                    // ⭐ Rating card
                    _buildRatingCard(),
                    const SizedBox(height: 20),

                    // Quick actions row
                    _buildQuickActions(notifProvider),
                    const SizedBox(height: 20),

                    // Edit profile section
                    _buildEditSection(),
                    const SizedBox(height: 24),

                    // Logout button
                    _buildLogoutButton(),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  // ── Info Section ──────────────────────────────────────────────────────────
  Widget _buildInfoSection(dynamic user) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [AppTheme.shadowSmall],
      ),
      child: Column(
        children: [
          _infoTile(
              icon: Icons.email_outlined,
              label: 'Email',
              value: user?.email ?? 'N/A',
              color: AppTheme.primaryColor),
          _divider(),
          _infoTile(
              icon: Icons.badge_outlined,
              label: 'Student ID',
              value: user?.studentId ?? 'N/A',
              color: AppTheme.infoColor),
          _divider(),
          _infoTile(
              icon: Icons.location_city_outlined,
              label: 'Campus',
              value: user?.campus ?? 'N/A',
              color: AppTheme.successColor),
          if (user?.program != null && user!.program!.isNotEmpty) ...[
            _divider(),
            _infoTile(
                icon: Icons.school_outlined,
                label: 'Program',
                value: user.program!,
                color: AppTheme.warningColor),
          ],
        ],
      ),
    );
  }

  // ── Rating Card ──────────────────────────────────────────────────────────────
  Widget _buildRatingCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.amber.shade50,
            Colors.orange.shade50,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
        boxShadow: [AppTheme.shadowSmall],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.star_rounded, color: Colors.amber, size: 22),
              const SizedBox(width: 8),
              Text('My Rating',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.amber[900],
                      )),
              const Spacer(),
              TextButton.icon(
                onPressed: () => Get.to(() => const MyRatingsScreen()),
                icon: const Icon(Icons.star_rounded,
                    size: 16, color: Colors.amber),
                label: const Text('See All'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.amber[800],
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (!_ratingsLoaded)
            const Center(
              child: SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else if (_totalRatings == 0)
            Text(
              'No ratings yet. Complete a claim to receive ratings from other students.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondaryColor,
                  ),
            )
          else
            Row(
              children: [
                // Stars
                Row(
                  children: List.generate(5, (i) {
                    final filled = i < _avgRating.floor();
                    final half = !filled &&
                        i < _avgRating &&
                        (_avgRating - i) >= 0.5;
                    return Icon(
                      filled
                          ? Icons.star_rounded
                          : half
                              ? Icons.star_half_rounded
                              : Icons.star_outline_rounded,
                      color: Colors.amber,
                      size: 28,
                    );
                  }),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _avgRating.toStringAsFixed(1),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.amber[800],
                          ),
                    ),
                    Text(
                      '$_totalRatings rating${_totalRatings == 1 ? '' : 's'}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.textSecondaryColor,
                          ),
                    ),
                  ],
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _infoTile(
      {required IconData icon,
      required String label,
      required String value,
      required Color color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                        fontSize: 11,
                        color: AppTheme.textSecondaryColor,
                        fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                Text(value,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() => Divider(
      height: 1, indent: 16, endIndent: 16, color: AppTheme.borderColor);

  // ── Quick Actions ─────────────────────────────────────────────────────────
  Widget _buildQuickActions(NotificationProvider notifProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Quick Actions',
            style: Theme.of(context)
                .textTheme
                .titleSmall
                ?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _quickActionCard(
                icon: Icons.notifications_outlined,
                label: 'Notifications',
                color: AppTheme.primaryColor,
                badge: Obx(() {
                  final c = notifProvider.unreadCount.value;
                  if (c == 0) return const SizedBox.shrink();
                  return Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      c > 9 ? '9+' : '$c',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold),
                    ),
                  );
                }),
                onTap: () => Get.to(() => const NotificationsScreen()),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _quickActionCard(
                icon: Icons.assignment_outlined,
                label: 'My Claims',
                color: AppTheme.infoColor,
                badge: const SizedBox.shrink(),
                onTap: () => Get.toNamed(AppRoutes.myClaims),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _quickActionCard(
                icon: Icons.inventory_2_outlined,
                label: 'My Items',
                color: AppTheme.successColor,
                badge: const SizedBox.shrink(),
                onTap: () => Get.toNamed(AppRoutes.myItems),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _quickActionCard(
                icon: Icons.bookmark_outlined,
                label: 'Saved Items',
                color: AppTheme.warningColor,
                badge: const SizedBox.shrink(),
                onTap: () => Get.toNamed(AppRoutes.savedItems),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _quickActionCard(
                icon: Icons.message_outlined,
                label: 'Messages',
                color: const Color(0xFF8B5CF6),
                badge: const SizedBox.shrink(),
                onTap: () => Get.to(() => const MessagesInboxScreen()),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _quickActionCard(
                icon: Icons.star_outlined,
                label: 'My Ratings',
                color: Colors.amber[700]!,
                badge: const SizedBox.shrink(),
                onTap: () => Get.toNamed(AppRoutes.myRatings),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _quickActionCard({
    required IconData icon,
    required String label,
    required Color color,
    required Widget badge,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(icon, color: color, size: 28),
                Positioned(top: -4, right: -8, child: badge),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ── Edit Section ──────────────────────────────────────────────────────────
  Widget _buildEditSection() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [AppTheme.shadowSmall],
      ),
      child: Column(
        children: [
          // Header with toggle
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
            child: Row(
              children: [
                Icon(Icons.edit_outlined,
                    color: AppTheme.primaryColor, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Edit Profile',
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => setState(() => _isEditing = !_isEditing),
                  child: Text(
                    _isEditing ? 'Cancel' : 'Edit',
                    style: TextStyle(
                      color: _isEditing
                          ? AppTheme.errorColor
                          : AppTheme.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          AnimatedCrossFade(
            firstChild: _buildReadOnlyView(),
            secondChild: _buildEditForm(),
            crossFadeState: _isEditing
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 250),
          ),
        ],
      ),
    );
  }

  Widget _buildReadOnlyView() {
    final authProvider = Get.find<AuthProvider>();
    final user = authProvider.currentUser.value;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        children: [
          _infoTile(
              icon: Icons.person_outline,
              label: 'First Name',
              value: user?.firstName ?? '',
              color: AppTheme.primaryColor),
          _divider(),
          _infoTile(
              icon: Icons.person_outline,
              label: 'Last Name',
              value: user?.lastName ?? '',
              color: AppTheme.primaryColor),
        ],
      ),
    );
  }

  Widget _buildEditForm() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            _formField(
                controller: _firstNameController,
                label: 'First Name',
                icon: Icons.person_outline,
                validator: (v) =>
                    v!.trim().isEmpty ? 'First name is required' : null),
            const SizedBox(height: 12),
            _formField(
                controller: _lastNameController,
                label: 'Last Name',
                icon: Icons.person_outline,
                validator: (v) =>
                    v!.trim().isEmpty ? 'Last name is required' : null),
            const SizedBox(height: 12),
            _formField(
                controller: _programController,
                label: 'Program (optional)',
                icon: Icons.school_outlined,
                validator: null),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _updateProfile,
                icon: _isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.save_outlined, size: 18),
                label: Text(_isLoading ? 'Saving...' : 'Save Changes'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _formField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20, color: AppTheme.primaryColor),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
      validator: validator,
    );
  }

  // ── Logout Button ─────────────────────────────────────────────────────────
  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _showLogoutDialog,
        icon: const Icon(Icons.logout, size: 20),
        label: const Text('Sign Out',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppTheme.errorColor,
          padding: const EdgeInsets.symmetric(vertical: 14),
          side: BorderSide(color: AppTheme.errorColor.withValues(alpha: 0.5)),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }
}
