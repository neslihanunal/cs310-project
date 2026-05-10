import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../utils/text_styles.dart';
import '../../utils/routes.dart';
import '../../utils/dummy_data.dart';
import '../../models/user_model.dart';
import '../../widgets/custom_text_field.dart';
import 'splash_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late User _seed;
  late String _email;
  bool _isAdmin = false;
  bool _initialized = false;

  final _firstCtrl = TextEditingController();
  final _lastCtrl = TextEditingController();
  final _clubCtrl = TextEditingController();
  String _dept = '';
  bool _showDepts = false;
  String _error = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final args =
      ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      _email = args['email'] as String;
      _seed = args['seed'] as User;
      _isAdmin = _seed.role == 'admin';
      _initialized = true;
    }
  }

  @override
  void dispose() {
    _firstCtrl.dispose();
    _lastCtrl.dispose();
    _clubCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (_isAdmin) {
      if (_clubCtrl.text.trim().isEmpty) {
        setState(() => _error = 'Please enter your club name.');
        return;
      }
    } else {
      if (_firstCtrl.text.trim().isEmpty || _lastCtrl.text.trim().isEmpty) {
        setState(() => _error = 'Please enter your first and last name.');
        return;
      }
      if (_dept.isEmpty) {
        setState(() => _error = 'Please select your department.');
        return;
      }
    }
    final user = User(
      role: _seed.role,
      firstName: _isAdmin ? _clubCtrl.text.trim() : _firstCtrl.text.trim(),
      lastName: _isAdmin ? '' : _lastCtrl.text.trim(),
      dept: _isAdmin ? 'Club Administrator' : _dept,
      clubName: _isAdmin ? _clubCtrl.text.trim() : null,
    );
    Navigator.pushReplacementNamed(context, AppRoutes.dashboard,
        arguments: {'user': user, 'email': _email});
  }

  @override
  Widget build(BuildContext context) {
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
                    Text(_isAdmin ? 'Set up your club' : 'One last step',
                        style: AppTextStyles.heading(22)),
                    const SizedBox(height: 6),
                    Text(
                        _isAdmin
                            ? 'Tell us about your club so students can find your events.'
                            : 'Tell us a bit about yourself. You can always edit this later from your profile.',
                        style: AppTextStyles.body(12, color: AppColors.textSec)
                            .copyWith(height: 1.6)),
                    const SizedBox(height: 28),
                    // Verified email display
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.border)),
                      child: Row(children: [
                        Icon(Icons.mail_outline,
                            color: AppColors.accent, size: 14),
                        const SizedBox(width: 10),
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('VERIFIED EMAIL',
                                  style: AppTextStyles.label()),
                              Text(_email, style: AppTextStyles.body(12)),
                            ]),
                        const Spacer(),
                        Icon(Icons.check, color: AppColors.success, size: 13),
                        const SizedBox(width: 3),
                        Text('Verified',
                            style: TextStyle(
                                fontSize: 9, color: AppColors.success)),
                      ]),
                    ),
                    const SizedBox(height: 16),
                    // Fields
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (_isAdmin) ...[
                            CustomTextField(
                                label: 'Club Name',
                                placeholder: 'e.g. CS Society',
                                controller: _clubCtrl,
                                onChanged: (_) => setState(() => _error = '')),
                          ] else ...[
                            Row(children: [
                              Expanded(
                                  child: CustomTextField(
                                      label: 'First Name',
                                      placeholder: 'First',
                                      controller: _firstCtrl,
                                      onChanged: (_) =>
                                          setState(() => _error = ''))),
                              const SizedBox(width: 8),
                              Expanded(
                                  child: CustomTextField(
                                      label: 'Last Name',
                                      placeholder: 'Last',
                                      controller: _lastCtrl,
                                      onChanged: (_) =>
                                          setState(() => _error = ''))),
                            ]),
                          ],
                          if (!_isAdmin) ...[
                            const SizedBox(height: 12),
                            // Department picker
                            Text('DEPARTMENT', style: AppTextStyles.label()),
                            const SizedBox(height: 5),
                            GestureDetector(
                              onTap: () =>
                                  setState(() => _showDepts = !_showDepts),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 11),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceAlt,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                      color: _showDepts
                                          ? AppColors.accent.withOpacity(0.5)
                                          : AppColors.border),
                                ),
                                child: Row(children: [
                                  Expanded(
                                      child: Text(
                                          _dept.isEmpty
                                              ? 'Select your department'
                                              : _dept,
                                          style: AppTextStyles.body(13,
                                              color: _dept.isEmpty
                                                  ? AppColors.textDim
                                                  : AppColors.text))),
                                  AnimatedRotation(
                                      turns: _showDepts ? 0.25 : 0,
                                      duration:
                                      const Duration(milliseconds: 200),
                                      child: Icon(Icons.chevron_right,
                                          color: AppColors.textDim, size: 14)),
                                ]),
                              ),
                            ),
                            if (_showDepts)
                              Container(
                                margin: const EdgeInsets.only(top: 4),
                                constraints:
                                const BoxConstraints(maxHeight: 180),
                                decoration: BoxDecoration(
                                    color: AppColors.surfaceHigh,
                                    borderRadius: BorderRadius.circular(8),
                                    border:
                                    Border.all(color: AppColors.border)),
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: kDepartments.length,
                                  itemBuilder: (_, i) => GestureDetector(
                                    onTap: () => setState(() {
                                      _dept = kDepartments[i];
                                      _showDepts = false;
                                      _error = '';
                                    }),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 14, vertical: 10),
                                      decoration: BoxDecoration(
                                        color: _dept == kDepartments[i]
                                            ? AppColors.accentFaded
                                            : Colors.transparent,
                                        border: Border(
                                            bottom: BorderSide(
                                                color: AppColors.borderLight)),
                                      ),
                                      child: Text(kDepartments[i],
                                          style: AppTextStyles.body(12,
                                              color: _dept == kDepartments[i]
                                                  ? AppColors.accent
                                                  : AppColors.text)),
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
                        onPressed: _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          foregroundColor: AppColors.bg,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          elevation: 0,
                        ),
                        child: Text(
                            _isAdmin ? 'Set Up Club' : 'Go to CampusBoard',
                            style: AppTextStyles.body(14,
                                color: AppColors.bg, weight: FontWeight.w600)),
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
  final String text;
  const _ErrorBanner({required this.text});
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    decoration: BoxDecoration(
        color: AppColors.dangerFaded,
        borderRadius: BorderRadius.circular(6)),
    child: Text(text,
        style:
        TextStyle(fontSize: 11, color: AppColors.danger, height: 1.4)),
  );
}
