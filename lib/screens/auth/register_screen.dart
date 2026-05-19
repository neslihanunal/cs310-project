import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../utils/app_colors.dart';
import '../../utils/routes.dart';
import '../../utils/text_styles.dart';
import '../../widgets/custom_text_field.dart';
import 'splash_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  String _emailError = '';
  String _passwordError = '';
  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    final authProvider = context.read<AuthProvider>();
    final email = _emailController.text.trim().toLowerCase();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (email.isEmpty) {
      setState(() => _emailError = 'Sabancı email cannot be empty.');
      return;
    }
    if (!authProvider.isSabanciEmail(email)) {
      setState(() => _emailError = 'Please use your @sabanciuniv.edu address.');
      return;
    }
    if (password.isEmpty) {
      setState(() => _passwordError = 'Password cannot be empty.');
      return;
    }
    final passwordValidationError =
        authProvider.validateRegistrationPassword(password);
    if (passwordValidationError != null) {
      setState(() => _passwordError = passwordValidationError);
      return;
    }
    if (password != confirmPassword) {
      setState(() => _passwordError = 'Passwords do not match.');
      return;
    }

    setState(() {
      _emailError = '';
      _passwordError = '';
    });

    final didRegister = await authProvider.register(email, password);
    if (!mounted || !didRegister) {
      return;
    }

    Navigator.pushReplacementNamed(
      context,
      authProvider.needsEmailVerification
          ? AppRoutes.verifyEmail
          : authProvider.needsProfile
          ? AppRoutes.onboarding
          : AppRoutes.dashboard,
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final visibleError = _emailError.isNotEmpty
        ? _emailError
        : _passwordError.isNotEmpty
        ? _passwordError
        : authProvider.errorMessage ?? '';

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: () => Navigator.pushReplacementNamed(
                    context,
                    AppRoutes.login,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Icon(
                      Icons.arrow_back,
                      color: AppColors.textSec,
                      size: 18,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    const AppLogo(size: 24),
                    const SizedBox(height: 12),
                    Text(
                      'Create your account',
                      style: AppTextStyles.heading(22),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Use your Sabancı email and a strong password to get started.',
                      style: AppTextStyles.body(
                        12,
                        color: AppColors.textSec,
                      ).copyWith(height: 1.6),
                    ),
                    const SizedBox(height: 28),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        children: [
                          CustomTextField(
                            label: 'Sabancı Email',
                            placeholder: 'name@sabanciuniv.edu',
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            prefixIcon: const Icon(Icons.mail_outline, size: 14),
                            onChanged: (_) {
                              authProvider.clearError();
                              setState(() => _emailError = '');
                            },
                          ),
                          const SizedBox(height: 12),
                          CustomTextField(
                            label: 'Password',
                            placeholder: 'Strong password',
                            controller: _passwordController,
                            obscureText: !_passwordVisible,
                            prefixIcon: const Icon(Icons.lock_outline, size: 14),
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  _passwordVisible = !_passwordVisible;
                                });
                              },
                              icon: Icon(
                                _passwordVisible
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                size: 18,
                              ),
                              color: AppColors.textDim,
                            ),
                            onChanged: (_) {
                              authProvider.clearError();
                              setState(() => _passwordError = '');
                            },
                          ),
                          const SizedBox(height: 12),
                          CustomTextField(
                            label: 'Confirm Password',
                            placeholder: 'Re-enter your password',
                            controller: _confirmPasswordController,
                            obscureText: !_confirmPasswordVisible,
                            prefixIcon: const Icon(Icons.lock_outline, size: 14),
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  _confirmPasswordVisible =
                                      !_confirmPasswordVisible;
                                });
                              },
                              icon: Icon(
                                _confirmPasswordVisible
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                size: 18,
                              ),
                              color: AppColors.textDim,
                            ),
                            onChanged: (_) {
                              authProvider.clearError();
                              setState(() => _passwordError = '');
                            },
                          ),
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              passwordPolicyMessage,
                              style: AppTextStyles.caption(size: 10).copyWith(
                                height: 1.5,
                              ),
                            ),
                          ),
                          if (visibleError.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            _ErrorBanner(text: visibleError),
                          ],
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: authProvider.isLoading ? null : _register,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.accent,
                                foregroundColor: AppColors.bg,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 13),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                elevation: 0,
                                disabledBackgroundColor:
                                    AppColors.accent.withOpacity(0.75),
                              ),
                              child: Text(
                                authProvider.isLoading
                                    ? 'Creating account…'
                                    : 'Create account',
                                style: AppTextStyles.body(
                                  14,
                                  color: AppColors.bg,
                                  weight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Center(
                            child: TextButton(
                              onPressed: authProvider.isLoading
                                  ? null
                                  : () => Navigator.pushReplacementNamed(
                                        context,
                                        AppRoutes.login,
                                      ),
                              child: Text(
                                'Already have an account? Log in',
                                style: AppTextStyles.body(
                                  12,
                                  color: AppColors.textSec,
                                ),
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
          ],
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.dangerFaded,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          color: AppColors.danger,
          height: 1.4,
        ),
      ),
    );
  }
}
