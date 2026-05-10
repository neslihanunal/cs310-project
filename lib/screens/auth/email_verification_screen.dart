import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../utils/app_colors.dart';
import '../../utils/routes.dart';
import '../../utils/text_styles.dart';
import 'splash_screen.dart';

class EmailVerificationScreen extends StatelessWidget {
  const EmailVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final email = authProvider.email ?? '';

    Future<void> checkVerification() async {
      final authController = context.read<AuthProvider>();
      final navigator = Navigator.of(context);
      final didVerify = await authController.refreshEmailVerification();

      if (!context.mounted || !didVerify) {
        return;
      }

      navigator.pushNamedAndRemoveUntil(
        authController.needsProfile
            ? AppRoutes.onboarding
            : AppRoutes.dashboard,
        (route) => false,
      );
    }

    Future<void> resendVerification() async {
      await context.read<AuthProvider>().resendVerificationEmail();
    }

    Future<void> backToLogin() async {
      final authController = context.read<AuthProvider>();
      final navigator = Navigator.of(context);
      await authController.logout();
      if (!context.mounted) {
        return;
      }
      navigator.pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
    }

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
                  onTap: authProvider.isLoading ? null : backToLogin,
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
                      'Verify your email',
                      style: AppTextStyles.heading(22),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Please verify your email address before continuing.',
                      style: AppTextStyles.body(
                        12,
                        color: AppColors.textSec,
                      ).copyWith(height: 1.6),
                    ),
                    const SizedBox(height: 28),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('REGISTERED EMAIL', style: AppTextStyles.label()),
                          const SizedBox(height: 6),
                          Text(
                            email,
                            style: AppTextStyles.body(
                              13,
                              weight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'We sent a verification email to this address. Open it, verify your account, then come back here.',
                            style: AppTextStyles.body(
                              12,
                              color: AppColors.textSec,
                            ).copyWith(height: 1.6),
                          ),
                          if ((authProvider.errorMessage ?? '').isNotEmpty) ...[
                            const SizedBox(height: 12),
                            _MessageBanner(text: authProvider.errorMessage!),
                          ],
                          const SizedBox(height: 14),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: authProvider.isLoading
                                  ? null
                                  : checkVerification,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.accent,
                                foregroundColor: AppColors.bg,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 13),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                elevation: 0,
                              ),
                              child: Text(
                                authProvider.isLoading
                                    ? 'Checking…'
                                    : 'I verified my email',
                                style: AppTextStyles.body(
                                  14,
                                  color: AppColors.bg,
                                  weight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: authProvider.isLoading
                                  ? null
                                  : resendVerification,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.text,
                                side: BorderSide(color: AppColors.border),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 13),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                'Resend verification email',
                                style: AppTextStyles.body(
                                  13,
                                  color: AppColors.text,
                                  weight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Center(
                            child: TextButton(
                              onPressed:
                                  authProvider.isLoading ? null : backToLogin,
                              child: Text(
                                'Back to login',
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

class _MessageBanner extends StatelessWidget {
  const _MessageBanner({required this.text});

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
