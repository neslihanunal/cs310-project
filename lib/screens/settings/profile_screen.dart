import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../utils/app_colors.dart';
import '../../utils/dummy_data.dart';
import '../../utils/routes.dart';
import '../../utils/text_styles.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_text_field.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late TextEditingController _firstController;
  late TextEditingController _lastController;
  late TextEditingController _clubController;

  String _department = '';
  bool _showDepartments = false;
  bool _saved = false;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) {
      return;
    }
    final user = context.read<AuthProvider>().currentUser;
    _firstController = TextEditingController(text: user?.firstName ?? '');
    _lastController = TextEditingController(text: user?.lastName ?? '');
    _clubController = TextEditingController(text: user?.clubName ?? '');
    _department = user?.department ?? '';
    _initialized = true;
  }

  @override
  void dispose() {
    _firstController.dispose();
    _lastController.dispose();
    _clubController.dispose();
    super.dispose();
  }

  Future<void> _save(AuthProvider authProvider) async {
    final currentUser = authProvider.currentUser;
    if (currentUser == null) {
      return;
    }
    final isAdmin = authProvider.role == 'admin';

    final updatedUser = currentUser.copyWith(
      firstName: isAdmin ? '' : _firstController.text.trim(),
      lastName: isAdmin ? '' : _lastController.text.trim(),
      department: isAdmin ? '' : _department,
      clubName: isAdmin ? _clubController.text.trim() : null,
      updatedAt: DateTime.now(),
    );

    await authProvider.createOrUpdateUserProfile(updatedUser);
    setState(() => _saved = true);
    Future<void>.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _saved = false);
      }
    });
  }

  Future<void> _showChangePasswordDialog(AuthProvider authProvider) async {
    authProvider.clearError();

    final didChange = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => const _ChangePasswordDialog(),
    );

    if (!mounted || didChange != true) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Password changed successfully.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final currentUser = authProvider.currentUser;

    if (currentUser == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final isAdmin = authProvider.role == 'admin';
    final email = authProvider.email ?? currentUser.email;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            CustomAppBar(
              onBack: () => Navigator.pop(context),
              title: isAdmin ? 'Club Profile' : 'My Profile',
              subtitle:
                  isAdmin ? 'Edit your club details' : 'Edit your information',
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.mail_outline, color: AppColors.accent, size: 14),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'UNIVERSITY EMAIL',
                                  style: AppTextStyles.label(),
                                ),
                                Text(
                                  email,
                                  style: AppTextStyles.body(12),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
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
                        children: [
                          if (isAdmin) ...[
                            CustomTextField(
                              label: 'Club Name',
                              controller: _clubController,
                              placeholder: 'e.g. CS Society',
                              onChanged: (_) => setState(() => _saved = false),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'This verified club account controls the events published under your organization.',
                              style: AppTextStyles.caption(size: 10).copyWith(
                                height: 1.5,
                              ),
                            ),
                          ] else ...[
                            Row(
                              children: [
                                Expanded(
                                  child: CustomTextField(
                                    label: 'First Name',
                                    controller: _firstController,
                                    placeholder: 'First',
                                    onChanged: (_) =>
                                        setState(() => _saved = false),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: CustomTextField(
                                    label: 'Last Name',
                                    controller: _lastController,
                                    placeholder: 'Last',
                                    onChanged: (_) =>
                                        setState(() => _saved = false),
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
                                            ? 'Select department'
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
                                    const BoxConstraints(maxHeight: 160),
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
                                      _saved = false;
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
                          if (isAdmin) ...[
                            const SizedBox(height: 4),
                            Text(
                              'Your role stays tied to this verified club email and cannot be changed from the app.',
                              style: AppTextStyles.caption(size: 10).copyWith(
                                height: 1.5,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _saved
                        ? Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.successFaded,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AppColors.success.withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.check,
                                  color: AppColors.success,
                                  size: 14,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Changes saved',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.success,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () => _save(authProvider),
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    isAdmin ? AppColors.warning : AppColors.accent,
                                foregroundColor: AppColors.bg,
                                padding: const EdgeInsets.symmetric(vertical: 13),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                elevation: 0,
                              ),
                              child: Text(
                                'Save Changes',
                                style: AppTextStyles.body(
                                  13,
                                  color: AppColors.bg,
                                  weight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: authProvider.isLoading
                            ? null
                            : () => _showChangePasswordDialog(authProvider),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.text,
                          side: BorderSide(color: AppColors.border),
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          'Change Password',
                          style: AppTextStyles.body(
                            13,
                            color: AppColors.text,
                            weight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () async {
                          await authProvider.logout();
                          if (context.mounted) {
                            Navigator.pushReplacementNamed(
                              context,
                              AppRoutes.login,
                            );
                          }
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.danger,
                          side: BorderSide(
                            color: AppColors.danger.withOpacity(0.3),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          'Sign Out',
                          style: AppTextStyles.body(
                            13,
                            color: AppColors.danger,
                            weight: FontWeight.w500,
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

class _ChangePasswordDialog extends StatefulWidget {
  const _ChangePasswordDialog();

  @override
  State<_ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<_ChangePasswordDialog> {
  late final TextEditingController _currentPasswordController;
  late final TextEditingController _newPasswordController;
  late final TextEditingController _confirmPasswordController;

  bool _currentVisible = false;
  bool _newVisible = false;
  bool _confirmVisible = false;

  @override
  void initState() {
    super.initState();
    _currentPasswordController = TextEditingController();
    _newPasswordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AuthProvider>();
    final errorMessage = provider.errorMessage ?? '';

    return AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Text(
        'Change Password',
        style: AppTextStyles.heading(18),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomTextField(
              label: 'Current Password',
              placeholder: 'Enter current password',
              controller: _currentPasswordController,
              obscureText: !_currentVisible,
              prefixIcon: const Icon(Icons.lock_outline, size: 14),
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() => _currentVisible = !_currentVisible);
                },
                icon: Icon(
                  _currentVisible
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  size: 18,
                ),
                color: AppColors.textDim,
              ),
              onChanged: (_) => provider.clearError(),
            ),
            const SizedBox(height: 12),
            CustomTextField(
              label: 'New Password',
              placeholder: 'Enter new password',
              controller: _newPasswordController,
              obscureText: !_newVisible,
              prefixIcon: const Icon(Icons.lock_outline, size: 14),
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() => _newVisible = !_newVisible);
                },
                icon: Icon(
                  _newVisible
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  size: 18,
                ),
                color: AppColors.textDim,
              ),
              onChanged: (_) => provider.clearError(),
            ),
            const SizedBox(height: 12),
            CustomTextField(
              label: 'Confirm New Password',
              placeholder: 'Re-enter new password',
              controller: _confirmPasswordController,
              obscureText: !_confirmVisible,
              prefixIcon: const Icon(Icons.lock_outline, size: 14),
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() => _confirmVisible = !_confirmVisible);
                },
                icon: Icon(
                  _confirmVisible
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  size: 18,
                ),
                color: AppColors.textDim,
              ),
              onChanged: (_) => provider.clearError(),
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
            if (errorMessage.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.dangerFaded,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  errorMessage,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.danger,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: provider.isLoading
              ? null
              : () => Navigator.of(context).pop(false),
          child: Text(
            'Cancel',
            style: AppTextStyles.body(12, color: AppColors.textSec),
          ),
        ),
        ElevatedButton(
          onPressed: provider.isLoading
              ? null
              : () async {
                  final navigator = Navigator.of(context);
                  final didUpdate = await provider.changePassword(
                    currentPassword: _currentPasswordController.text,
                    newPassword: _newPasswordController.text,
                    confirmNewPassword: _confirmPasswordController.text,
                  );
                  if (!mounted || !didUpdate) {
                    return;
                  }
                  navigator.pop(true);
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accent,
            foregroundColor: AppColors.bg,
          ),
          child: Text(
            provider.isLoading ? 'Saving…' : 'Update Password',
            style: AppTextStyles.body(
              12,
              color: AppColors.bg,
              weight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
