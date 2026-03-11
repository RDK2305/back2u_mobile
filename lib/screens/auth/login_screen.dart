import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../config/theme.dart';
import '../../config/routes.dart';
import '../../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authProvider = Get.find<AuthProvider>();

  bool _showPassword = false;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    );
    _fadeAnim =
        CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic));
    _animController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    _authProvider.clearErrors();
    FocusScope.of(context).unfocus();

    final success = await _authProvider.login(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (!mounted) return;
    if (success) {
      Get.offAllNamed(AppRoutes.main);
    } else {
      Get.snackbar(
        'Login Failed',
        _authProvider.errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppTheme.errorColor,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
        margin: const EdgeInsets.all(12),
        borderRadius: 12,
        icon: const Icon(Icons.error_outline, color: Colors.white),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // Gradient background header
          Container(
            height: size.height * 0.42,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1E3A8A), Color(0xFF2563EB), Color(0xFF3B82F6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // Decorative circles
          Positioned(
            top: -60,
            right: -60,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.06),
              ),
            ),
          ),
          Positioned(
            top: 80,
            left: -40,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.04),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Top header / branding
                SizedBox(
                  height: size.height * 0.35,
                  child: FadeTransition(
                    opacity: _fadeAnim,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 76,
                          height: 76,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.travel_explore_rounded,
                            size: 42,
                            color: Color(0xFF1E3A8A),
                          ),
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          'Back2U',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Lost & Found · Conestoga College',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white.withValues(alpha: 0.8),
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // White rounded card
                Expanded(
                  child: SlideTransition(
                    position: _slideAnim,
                    child: FadeTransition(
                      opacity: _fadeAnim,
                      child: Container(
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(30),
                            topRight: Radius.circular(30),
                          ),
                        ),
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(28, 28, 28, 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Welcome back \u{1F44B}',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.w800,
                                      color: const Color(0xFF1E3A8A),
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Sign in to continue',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                        color: AppTheme.textSecondaryColor),
                              ),
                              const SizedBox(height: 28),

                              Form(
                                key: _formKey,
                                child: Column(
                                  children: [
                                    _buildInputField(
                                      controller: _emailController,
                                      label: 'Email Address',
                                      hint: 'you@conestogac.on.ca',
                                      icon: Icons.email_outlined,
                                      inputType: TextInputType.emailAddress,
                                      actionType: TextInputAction.next,
                                      validator: (v) {
                                        if (v == null || v.trim().isEmpty) {
                                          return 'Email is required';
                                        }
                                        if (!RegExp(
                                                r'^[^\s@]+@[^\s@]+\.[^\s@]+$')
                                            .hasMatch(v.trim())) {
                                          return 'Enter a valid email address';
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 16),
                                    TextFormField(
                                      controller: _passwordController,
                                      obscureText: !_showPassword,
                                      textInputAction: TextInputAction.done,
                                      onFieldSubmitted: (_) => _handleLogin(),
                                      decoration: _inputDecoration(
                                        label: 'Password',
                                        hint: 'Min. 8 characters',
                                        icon: Icons.lock_outline,
                                        suffix: IconButton(
                                          icon: Icon(
                                            _showPassword
                                                ? Icons.visibility_outlined
                                                : Icons.visibility_off_outlined,
                                            color: AppTheme.textSecondaryColor,
                                            size: 20,
                                          ),
                                          onPressed: () => setState(() =>
                                              _showPassword = !_showPassword),
                                        ),
                                      ),
                                      validator: (v) {
                                        if (v == null || v.isEmpty) {
                                          return 'Password is required';
                                        }
                                        if (v.length < 8) {
                                          return 'Minimum 8 characters';
                                        }
                                        return null;
                                      },
                                    ),
                                  ],
                                ),
                              ),

                              // Forgot password
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () =>
                                      Get.toNamed(AppRoutes.forgotPassword),
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                  ),
                                  child: const Text(
                                    'Forgot Password?',
                                    style: TextStyle(
                                      color: Color(0xFF2563EB),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 8),

                              // Sign In button
                              Obx(() => SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: _authProvider.isLoading.value
                                          ? null
                                          : _handleLogin,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF1E3A8A),
                                        disabledBackgroundColor:
                                            const Color(0xFF1E3A8A)
                                                .withValues(alpha: 0.6),
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 16),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(14),
                                        ),
                                        elevation: 0,
                                      ),
                                      child: _authProvider.isLoading.value
                                          ? const SizedBox(
                                              height: 20,
                                              width: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: Colors.white,
                                              ),
                                            )
                                          : const Text(
                                              'Sign In',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                    ),
                                  )),

                              const SizedBox(height: 24),

                              // Divider
                              Row(
                                children: [
                                  Expanded(
                                    child: Divider(
                                        color: AppTheme.borderColor, height: 1),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14),
                                    child: Text(
                                      'New to Back2U?',
                                      style: TextStyle(
                                        color: AppTheme.textSecondaryColor,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Divider(
                                        color: AppTheme.borderColor, height: 1),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 16),

                              // Create account button
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton(
                                  onPressed: () =>
                                      Get.toNamed(AppRoutes.register),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14),
                                    side: const BorderSide(
                                        color: Color(0xFF1E3A8A), width: 1.5),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  child: const Text(
                                    'Create Account',
                                    style: TextStyle(
                                      color: Color(0xFF1E3A8A),
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 20),

                              // Note for security staff
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppTheme.warningColor
                                      .withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                      color: AppTheme.warningColor
                                          .withValues(alpha: 0.25)),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(Icons.info_outline,
                                        color: AppTheme.warningColor, size: 18),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Security staff: please use the web portal at back2u-h67h.onrender.com for administrative features.',
                                        style: TextStyle(
                                          color: AppTheme.warningColor,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType inputType = TextInputType.text,
    TextInputAction actionType = TextInputAction.next,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: inputType,
      textInputAction: actionType,
      decoration: _inputDecoration(label: label, hint: hint, icon: icon),
      validator: validator,
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required String hint,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon, color: const Color(0xFF1E3A8A), size: 20),
      suffixIcon: suffix,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: AppTheme.borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: AppTheme.borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF1E3A8A), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: AppTheme.errorColor),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: AppTheme.errorColor, width: 2),
      ),
      filled: true,
      fillColor: const Color(0xFFF8FAFF),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}
