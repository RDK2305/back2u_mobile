import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../config/theme.dart';
import '../../config/routes.dart';
import '../../providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _studentIdController = TextEditingController();
  final _emailController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _programController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  final _authProvider = Get.find<AuthProvider>();
  String _selectedCampus = 'Main';
  bool _showPassword = false;
  bool _showConfirmPassword = false;
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<String> _campuses = ['Main', 'Waterloo', 'Cambridge'];

  @override
  void initState() {
    super.initState();
    _setupAnimation();
  }

  void _setupAnimation() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _studentIdController.dispose();
    _emailController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _programController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    _authProvider.clearErrors();

    bool success = await _authProvider.register(
      studentId: _studentIdController.text.trim(),
      email: _emailController.text.trim(),
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      campus: _selectedCampus,
      program: _programController.text.trim().isEmpty ? null : _programController.text.trim(),
      password: _passwordController.text,
      confirmPassword: _confirmPasswordController.text,
    );

    if (success) {
      Get.snackbar(
        'Success',
        'Registration successful! Please login with your credentials.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppTheme.successColor,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
      await Future.delayed(const Duration(seconds: 1));
      Get.offAllNamed(AppRoutes.login);
    } else {
      Get.snackbar(
        'Registration Failed',
        _authProvider.errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppTheme.errorColor,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Create Account'),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.paddingLarge,
                vertical: AppTheme.paddingMedium,
              ),
              child: Column(
                children: [
                  SizedBox(height: AppTheme.paddingMedium),
                  _buildHeader(),
                  SizedBox(height: AppTheme.paddingLarge),
                  _buildForm(),
                  SizedBox(height: AppTheme.paddingLarge),
                  _buildRegisterButton(),
                  SizedBox(height: AppTheme.paddingMedium),
                  _buildLoginLink(),
                  SizedBox(height: AppTheme.paddingLarge),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Text(
          'Join Back2U',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: AppTheme.textPrimaryColor,
          ),
        ),
        SizedBox(height: AppTheme.paddingSmall),
        Text(
          'Create an account to start connecting with recovered items',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppTheme.textSecondaryColor,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // First Row: Student ID & Email
          Row(
            children: [
              Expanded(
                child: _buildTextFieldWithIcon(
                  controller: _studentIdController,
                  label: 'Student ID',
                  icon: Icons.card_membership,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Required';
                    }
                    return null;
                  },
                ),
              ),
              SizedBox(width: AppTheme.paddingMedium),
              Expanded(
                child: _buildTextFieldWithIcon(
                  controller: _emailController,
                  label: 'Email',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Required';
                    }
                    if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value)) {
                      return 'Invalid email';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: AppTheme.paddingMedium),

          // Second Row: First Name & Last Name
          Row(
            children: [
              Expanded(
                child: _buildTextFieldWithIcon(
                  controller: _firstNameController,
                  label: 'First Name',
                  icon: Icons.person_outline,
                  validator: (value) =>
                      (value == null || value.isEmpty) ? 'Required' : null,
                ),
              ),
              SizedBox(width: AppTheme.paddingMedium),
              Expanded(
                child: _buildTextFieldWithIcon(
                  controller: _lastNameController,
                  label: 'Last Name',
                  icon: Icons.person_outline,
                  validator: (value) =>
                      (value == null || value.isEmpty) ? 'Required' : null,
                ),
              ),
            ],
          ),
          SizedBox(height: AppTheme.paddingMedium),

          // Campus Dropdown
          _buildCampusDropdown(),
          SizedBox(height: AppTheme.paddingMedium),

          // Program
          _buildTextFieldWithIcon(
            controller: _programController,
            label: 'Program (Optional)',
            icon: Icons.school_outlined,
          ),
          SizedBox(height: AppTheme.paddingMedium),

          // Password
          _buildPasswordField(),
          SizedBox(height: AppTheme.paddingMedium),

          // Confirm Password
          _buildConfirmPasswordField(),
        ],
      ),
    );
  }

  Widget _buildTextFieldWithIcon({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        ),
      ),
      validator: validator,
    );
  }

  Widget _buildCampusDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: _selectedCampus,
      decoration: InputDecoration(
        labelText: 'Campus',
        prefixIcon: const Icon(Icons.location_on_outlined),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        ),
      ),
      items: _campuses
          .map((campus) => DropdownMenuItem(
                value: campus,
                child: Text(campus),
              ))
          .toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() => _selectedCampus = value);
        }
      },
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: !_showPassword,
      decoration: InputDecoration(
        labelText: 'Password',
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: Icon(
            _showPassword ? Icons.visibility : Icons.visibility_off,
          ),
          onPressed: () {
            setState(() => _showPassword = !_showPassword);
          },
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        ),
        helperText: 'Minimum 8 characters',
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Password is required';
        }
        if (value.length < 8) {
          return 'Password must be at least 8 characters';
        }
        return null;
      },
    );
  }

  Widget _buildConfirmPasswordField() {
    return TextFormField(
      controller: _confirmPasswordController,
      obscureText: !_showConfirmPassword,
      decoration: InputDecoration(
        labelText: 'Confirm Password',
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: Icon(
            _showConfirmPassword ? Icons.visibility : Icons.visibility_off,
          ),
          onPressed: () {
            setState(() => _showConfirmPassword = !_showConfirmPassword);
          },
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Confirm password';
        }
        if (value != _passwordController.text) {
          return 'Passwords do not match';
        }
        return null;
      },
    );
  }

  Widget _buildRegisterButton() {
    return Obx(() => SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _authProvider.isLoading.value ? null : _handleRegister,
        child: _authProvider.isLoading.value
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text('Create Account'),
      ),
    ));
  }

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Already have an account? ',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        TextButton(
          onPressed: () => Get.back(),
          child: Text(
            'Login',
            style: TextStyle(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
