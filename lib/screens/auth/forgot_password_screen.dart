import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../config/theme.dart';
import '../../services/api_service.dart';

/// Small bullet-point row used in the password requirements box.
class _PwRule extends StatelessWidget {
  final String text;
  const _PwRule({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 3),
      child: Row(
        children: [
          const Icon(Icons.circle, size: 5, color: Color(0xFF2563EB)),
          const SizedBox(width: 6),
          Text(text,
              style: const TextStyle(
                  fontSize: 12, color: Color(0xFF374151))),
        ],
      ),
    );
  }
}

/// 3-step forgot password flow:
///   Step 1 → Enter email → sends OTP
///   Step 2 → Enter 6-digit OTP → verifies OTP
///   Step 3 → Enter new password → resets password
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _api = ApiService();

  int _step = 1; // 1=email, 2=otp, 3=new password
  bool _isLoading = false;
  String _email = '';
  String _otp = '';
  String? _resetToken; // JWT returned by /auth/verify-otp

  // true when backend says the email has no account — shows inline warning
  bool _emailNotFound = false;

  // Step 1
  final _emailFormKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  // Step 2
  final _otpFormKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();

  // Step 3
  final _pwFormKey = GlobalKey<FormState>();
  final _newPwController = TextEditingController();
  final _confirmPwController = TextEditingController();
  bool _showNewPw = false;
  bool _showConfirmPw = false;

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    _newPwController.dispose();
    _confirmPwController.dispose();
    super.dispose();
  }

  // ─── Step 1: Send OTP ────────────────────────────────────────────────────
  Future<void> _sendOtp() async {
    if (!_emailFormKey.currentState!.validate()) return;
    // Clear any previous "not found" warning before retrying
    if (_emailNotFound) setState(() => _emailNotFound = false);
    setState(() => _isLoading = true);
    try {
      _email = _emailController.text.trim();
      final found = await _api.forgotPassword(_email);
      if (!found) {
        // Email not registered — show inline warning, stay on step 1
        setState(() => _emailNotFound = true);
        _showToast(
          'No account found with this email. Please register first.',
          isWarning: true,
        );
        return;
      }
      // Email found — OTP sent
      setState(() => _step = 2);
      _showToast('OTP sent to $_email', isSuccess: true);
    } catch (e) {
      _showToast(e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ─── Step 2: Verify OTP ───────────────────────────────────────────────────
  Future<void> _verifyOtp() async {
    if (!_otpFormKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      _otp = _otpController.text.trim();
      // Returns the resetToken JWT from the backend, or null if invalid
      final token = await _api.verifyOtp(_email, _otp);
      if (token != null && token.isNotEmpty) {
        _resetToken = token;
        setState(() => _step = 3);
        _showToast('OTP verified successfully', isSuccess: true);
      } else {
        _showToast('Invalid OTP. Please try again.');
      }
    } catch (e) {
      _showToast(e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ─── Step 3: Reset Password ────────────────────────────────────────────────
  Future<void> _resetPassword() async {
    // Form validator already checks length, number, special-char, and match
    if (!_pwFormKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      // Pass the resetToken (JWT from step 2) as the Authorization header.
      // Also send email + otp in the body as the backend expects them.
      await _api.resetPassword(
        _email,
        _otp,
        _newPwController.text,
        resetToken: _resetToken,
      );
      _showToast('Password reset successfully! Please log in.', isSuccess: true);
      // Delay so the user can read the success toast, then go to login
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) Get.offAllNamed('/login');
    } catch (e) {
      _showToast(e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showToast(String msg,
      {bool isSuccess = false, bool isWarning = false}) {
    final Color bg = isSuccess
        ? AppTheme.successColor
        : isWarning
            ? const Color(0xFFF59E0B) // amber
            : AppTheme.errorColor;
    final String title =
        isSuccess ? 'Success' : isWarning ? 'Not Found' : 'Error';
    Get.snackbar(
      title,
      msg,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: bg,
      colorText: Colors.white,
      duration: const Duration(seconds: 5),
      margin: const EdgeInsets.all(12),
      borderRadius: 12,
      icon: Icon(
        isSuccess
            ? Icons.check_circle_outline
            : isWarning
                ? Icons.warning_amber_rounded
                : Icons.error_outline,
        color: Colors.white,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
          onPressed: () => Get.back(),
        ),
        title: Text(
          _step == 1
              ? 'Forgot Password'
              : _step == 2
                  ? 'Verify OTP'
                  : 'New Password',
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Step indicator
              _buildStepIndicator(),
              const SizedBox(height: 32),
              // Content card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [AppTheme.shadowMedium],
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _step == 1
                      ? _buildStep1(key: const ValueKey(1))
                      : _step == 2
                          ? _buildStep2(key: const ValueKey(2))
                          : _buildStep3(key: const ValueKey(3)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (i) {
        final stepNum = i + 1;
        final isActive = stepNum == _step;
        final isDone = stepNum < _step;
        return Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: isActive ? 36 : 28,
              height: isActive ? 36 : 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDone
                    ? AppTheme.successColor
                    : isActive
                        ? AppTheme.primaryColor
                        : Colors.grey[200],
                boxShadow: isActive ? [AppTheme.shadowSmall] : [],
              ),
              child: Center(
                child: isDone
                    ? const Icon(Icons.check, color: Colors.white, size: 16)
                    : Text(
                        '$stepNum',
                        style: TextStyle(
                          color: isActive ? Colors.white : Colors.grey,
                          fontWeight: FontWeight.bold,
                          fontSize: isActive ? 15 : 13,
                        ),
                      ),
              ),
            ),
            if (i < 2)
              Container(
                width: 40,
                height: 2,
                color: isDone ? AppTheme.successColor : Colors.grey[300],
              ),
          ],
        );
      }),
    );
  }

  // ─── Step 1 Widget ────────────────────────────────────────────────────────
  Widget _buildStep1({Key? key}) {
    return Form(
      key: _emailFormKey,
      child: Column(
        key: key,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.lock_reset_outlined,
              size: 48, color: AppTheme.primaryColor),
          const SizedBox(height: 16),
          Text('Reset your password',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  )),
          const SizedBox(height: 8),
          Text(
            'Enter your registered email address. We\'ll send you a one-time password (OTP) to verify your identity.',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: AppTheme.textSecondaryColor),
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _sendOtp(),
            // Clear the "not found" banner as soon as the user edits the email
            onChanged: (_) {
              if (_emailNotFound) setState(() => _emailNotFound = false);
            },
            decoration: InputDecoration(
              labelText: 'Email Address',
              hintText: 'your@conestogac.on.ca',
              prefixIcon: const Icon(Icons.email_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Email is required';
              if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(v.trim())) {
                return 'Enter a valid email';
              }
              return null;
            },
          ),

          // ── "Email not found" inline warning ─────────────────────────────
          if (_emailNotFound) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF7ED),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFF59E0B)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.warning_amber_rounded,
                          color: Color(0xFFB45309), size: 18),
                      SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          'No account found with this email.',
                          style: TextStyle(
                            color: Color(0xFF92400E),
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'This email is not registered in our system. Please create an account first.',
                    style:
                        TextStyle(color: Color(0xFF92400E), fontSize: 12),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => Get.offAllNamed('/register'),
                      icon: const Icon(Icons.person_add_outlined,
                          size: 16, color: Color(0xFFB45309)),
                      label: const Text(
                        'Create an Account',
                        style: TextStyle(
                            color: Color(0xFFB45309),
                            fontWeight: FontWeight.w600),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFF59E0B)),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          // ─────────────────────────────────────────────────────────────────

          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _sendOtp,
              icon: _isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.send_outlined),
              label: Text(_isLoading ? 'Sending OTP...' : 'Send OTP'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
          // Hint shown while waiting so the user knows the server may take time
          if (_isLoading) ...[
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.info_outline,
                    size: 14, color: AppTheme.textSecondaryColor),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    'This may take up to 30 seconds on first launch.',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondaryColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // ─── Step 2 Widget ────────────────────────────────────────────────────────
  Widget _buildStep2({Key? key}) {
    return Form(
      key: _otpFormKey,
      child: Column(
        key: key,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.security_outlined,
              size: 48, color: AppTheme.primaryColor),
          const SizedBox(height: 16),
          Text('Enter OTP',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  )),
          const SizedBox(height: 8),
          RichText(
            text: TextSpan(
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: AppTheme.textSecondaryColor),
              children: [
                const TextSpan(text: 'We sent a 6-digit OTP to '),
                TextSpan(
                  text: _email,
                  style: TextStyle(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller: _otpController,
            keyboardType: TextInputType.number,
            maxLength: 6,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _verifyOtp(),
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 8,
            ),
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              labelText: 'OTP Code',
              hintText: '000000',
              counterText: '',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'OTP is required';
              if (v.trim().length != 6) return 'OTP must be exactly 6 digits';
              if (!RegExp(r'^\d{6}$').hasMatch(v.trim())) {
                return 'OTP must contain digits only';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          Center(
            child: TextButton.icon(
              onPressed: _isLoading ? null : _sendOtp,
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Resend OTP'),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _verifyOtp,
              icon: _isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.verified_outlined),
              label: Text(_isLoading ? 'Verifying...' : 'Verify OTP'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Step 3 Widget ────────────────────────────────────────────────────────
  Widget _buildStep3({Key? key}) {
    return Form(
      key: _pwFormKey,
      child: Column(
        key: key,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.lock_open_outlined,
              size: 48, color: AppTheme.successColor),
          const SizedBox(height: 16),
          Text('Create New Password',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  )),
          const SizedBox(height: 8),
          // Password requirements box — mirrors backend validatePassword()
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F4FF),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFBFD0FF)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Password requirements:',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E3A8A))),
                SizedBox(height: 6),
                _PwRule(text: 'Minimum 8 characters'),
                _PwRule(text: 'At least one number (0-9)'),
                _PwRule(text: 'At least one special character (!@#\$%^&*)'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _newPwController,
            obscureText: !_showNewPw,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              labelText: 'New Password',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(_showNewPw
                    ? Icons.visibility
                    : Icons.visibility_off),
                onPressed: () =>
                    setState(() => _showNewPw = !_showNewPw),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Password is required';
              if (v.length < 8) return 'Must be at least 8 characters';
              if (!RegExp(r'\d').hasMatch(v)) {
                return 'Must contain at least one number';
              }
              if (!RegExp(r'[!@#$%^&*]').hasMatch(v)) {
                return 'Must contain a special character (!@#\$%^&*)';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _confirmPwController,
            obscureText: !_showConfirmPw,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _resetPassword(),
            decoration: InputDecoration(
              labelText: 'Confirm Password',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(_showConfirmPw
                    ? Icons.visibility
                    : Icons.visibility_off),
                onPressed: () =>
                    setState(() => _showConfirmPw = !_showConfirmPw),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Confirm your password';
              if (v != _newPwController.text) return 'Passwords do not match';
              return null;
            },
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _resetPassword,
              icon: _isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.check_circle_outline),
              label: Text(_isLoading ? 'Resetting...' : 'Reset Password'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.successColor,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
