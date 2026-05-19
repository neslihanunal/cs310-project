import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_colors.dart';
import '../../utils/dummy_data.dart';
import '../../utils/routes.dart';
import '../../utils/text_styles.dart';
import '../../widgets/custom_text_field.dart';
import 'splash_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final TextEditingController _firstController = TextEditingController();
  final TextEditingController _lastController = TextEditingController();
  final TextEditingController _clubController = TextEditingController();

  String _email = '';
  String _department = '';
  bool _showDepartments = false;
  bool _initialized = false;
  String _error = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) {
      return;
    }

    final authProvider = context.read<AuthProvider>();
    _email = authProvider.email ?? '';
    final canUseAdminRole = authProvider.canUseAdminRole;
    final seed = kDemoSeeds[_email];
    if (seed != null) {
      _firstController.text = seed.firstName;
      _lastController.text = seed.lastName;
      if (canUseAdminRole) {
        _clubController.text = seed.clubName ?? '';
      }
      _department = seed.department;
    }
    _initialized = true;
  }

  @override
  void dispose() {
    _firstController.dispose();
    _lastController.dispose();
    _clubController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final authProvider = context.read<AuthProvider>();
    final isAdmin = authProvider.canUseAdminRole;
    if (isAdmin && _clubController.text.trim().isEmpty) {
      setState(() => _error = 'Please enter your club name.');
      return;
    }
    if (!isAdmin &&
        (_firstController.text.trim().isEmpty ||
            _lastController.text.trim().isEmpty)) {
      setState(() => _error = 'Please enter your first and last name.');
      return;
    }
    if (!isAdmin && _department.isEmpty) {
      setState(() => _error = 'Please select your department.');
      return;
    }

    final now = DateTime.now();
    final user = AppUser(
      uid: authProvider.uid ?? '',
      email: _email,
      role: authProvider.role,
      firstName: isAdmin ? '' : _firstController.text.trim(),
      lastName: isAdmin ? '' : _lastController.text.trim(),
      department: isAdmin ? '' : _department,
      clubName: isAdmin ? _clubController.text.trim() : null,
      createdAt: authProvider.currentUser?.createdAt ?? now,
      updatedAt: now,
    );

    await authProvider.createOrUpdateUserProfile(user);
    if (!mounted) {
      return;
    }
    Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final isAdmin = authProvider.canUseAdminRole;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 4),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AppLogo(size: 28),
                    const SizedBox(height: 14),
                    Text(
                      isAdmin ? 'Set up your club' : 'One last step',
                      style: AppTextStyles.heading(22),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      isAdmin
                          ? 'Tell us about your club so students can find your events.'
                          : 'Tell us a bit about yourself. You can always edit this later from your profile.',
                      style: AppTextStyles.body(12, color: AppColors.textSec)
                          .copyWith(height: 1.6),
                    ),
                    const SizedBox(height: 28),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.mail_outline,
                            color: AppColors.accent,
                            size: 14,
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'VERIFIED EMAIL',
                                style: AppTextStyles.label(),
                              ),
                              Text(_email, style: AppTextStyles.body(12)),
                            ],
                          ),
                          const Spacer(),
                          Icon(Icons.check, color: AppColors.success, size: 13),
                          const SizedBox(width: 3),
                          Text(
                            'Verified',
                            style: TextStyle(
                              fontSize: 9,
                              color: AppColors.success,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('ACCOUNT TYPE', style: AppTextStyles.label()),
                          const SizedBox(height: 6),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 11,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceAlt,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Text(
                              isAdmin ? 'Club/Admin' : 'Student',
                              style: AppTextStyles.body(
                                12,
                                color: AppColors.text,
                                weight: FontWeight.w500,
                              ),
                            ),
                          ),
                          if (isAdmin) ...[
                            const SizedBox(height: 12),
                            CustomTextField(
                              label: 'Club Name',
                              placeholder: 'e.g. CS Society',
                              controller: _clubController,
                              onChanged: (_) => setState(() => _error = ''),
                            ),
                          ] else ...[
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: CustomTextField(
                                    label: 'First Name',
                                    placeholder: 'First',
                                    controller: _firstController,
                                    onChanged: (_) =>
                                        setState(() => _error = ''),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: CustomTextField(
                                    label: 'Last Name',
                                    placeholder: 'Last',
                                    controller: _lastController,
                                    onChanged: (_) =>
                                        setState(() => _error = ''),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text('DEPARTMENT', style: AppTextStyles.label()),
                            const SizedBox(height: 5),
                            GestureDetector(
                              onTap: () => setState(
                                () => _showDepartments = !_showDepartments,
                              ),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 11,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceAlt,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: _showDepartments
                                        ? AppColors.accent.withOpacity(0.5)
                                        : AppColors.border,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        _department.isEmpty
                                            ? 'Select your department'
                                            : _department,
                                        style: AppTextStyles.body(
                                          13,
                                          color: _department.isEmpty
                                              ? AppColors.textDim
                                              : AppColors.text,
                                        ),
                                      ),
                                    ),
                                    AnimatedRotation(
                                      turns: _showDepartments ? 0.25 : 0,
                                      duration:
                                          const Duration(milliseconds: 200),
                                      child: Icon(
                                        Icons.chevron_right,
                                        color: AppColors.textDim,
                                        size: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (_showDepartments)
                              Container(
                                margin: const EdgeInsets.only(top: 4),
                                constraints:
                                    const BoxConstraints(maxHeight: 180),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceHigh,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: kDepartments.length,
                                  itemBuilder: (_, index) => GestureDetector(
                                    onTap: () => setState(() {
                                      _department = kDepartments[index];
                                      _showDepartments = false;
                                      _error = '';
                                    }),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 10,
                                      ),
                                      decoration: BoxDecoration(
                                        color:
                                            _department == kDepartments[index]
                                            ? AppColors.accentFaded
                                            : Colors.transparent,
                                        border: Border(
                                          bottom: BorderSide(
                                            color: AppColors.borderLight,
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        kDepartments[index],
                                        style: AppTextStyles.body(
                                          12,
                                          color: _department ==
                                                  kDepartments[index]
                                              ? AppColors.accent
                                              : AppColors.text,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                          if (_error.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            _ErrorBanner(text: _error),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: authProvider.isLoading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          foregroundColor: AppColors.bg,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          authProvider.isLoading
                              ? 'Saving…'
                              : (isAdmin
                                  ? 'Set Up Club'
                                  : 'Go to CampusBoard'),
                          style: AppTextStyles.body(
                            14,
                            color: AppColors.bg,
                            weight: FontWeight.w600,
                          ),
                        ),
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
        style: TextStyle(
          fontSize: 11,
          color: AppColors.danger,
          height: 1.4,
        ),
      ),
    );
  }
}
