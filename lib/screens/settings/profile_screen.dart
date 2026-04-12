import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../utils/text_styles.dart';
import '../../utils/routes.dart';
import '../../utils/dummy_data.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_text_field.dart';
import '../../app_state.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late TextEditingController _firstCtrl, _lastCtrl, _clubCtrl;
  String _dept = '';
  bool _showDepts = false;
  bool _saved = false;
  bool _init  = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_init) {
      final acc = AppStateProvider.of(context).account;
      _firstCtrl = TextEditingController(text: acc?.firstName ?? '');
      _lastCtrl  = TextEditingController(text: acc?.lastName  ?? '');
      _clubCtrl  = TextEditingController(text: acc?.clubName  ?? '');
      _dept      = acc?.dept ?? '';
      _init = true;
    }
  }

  @override
  void dispose() { _firstCtrl.dispose(); _lastCtrl.dispose(); _clubCtrl.dispose(); super.dispose(); }

  void _save(AppState state) {
    state.updateAccount(state.account!.copyWith(
      firstName: _firstCtrl.text.trim(),
      lastName:  _lastCtrl.text.trim(),
      dept:      state.role == 'admin' ? 'Club Administrator' : _dept,
      clubName:  state.role == 'admin' ? _clubCtrl.text.trim() : null,
    ));
    setState(() => _saved = true);
    Future.delayed(const Duration(seconds: 2), () { if (mounted) setState(() => _saved = false); });
  }

  @override
  Widget build(BuildContext context) {
    final state   = AppStateProvider.of(context);
    final isAdmin = state.role == 'admin';
    final email   = state.userEmail ?? '${state.account?.firstName.toLowerCase() ?? 'user'}@sabanciuniv.edu';

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            CustomAppBar(onBack: () => Navigator.pop(context), title: isAdmin ? 'Club Profile' : 'My Profile', subtitle: 'Edit your information'),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Email display
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.border)),
                      child: Row(children: [
                        Icon(Icons.mail_outline, color: AppColors.accent, size: 14),
                        const SizedBox(width: 10),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('UNIVERSITY EMAIL', style: AppTextStyles.label()),
                          Text(email, style: AppTextStyles.body(12), overflow: TextOverflow.ellipsis),
                        ])),
                        Icon(Icons.check, color: AppColors.success, size: 13),
                        const SizedBox(width: 3),
                        Text('Verified', style: TextStyle(fontSize: 9, color: AppColors.success)),
                      ]),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
                      child: Column(children: [
                        if (isAdmin) ...[
                          CustomTextField(label: 'Club Name', controller: _clubCtrl, placeholder: 'e.g. CS Society', onChanged: (_) => setState(() => _saved = false)),
                          const SizedBox(height: 12),
                        ],
                        Row(children: [
                          Expanded(child: CustomTextField(label: 'First Name', controller: _firstCtrl, placeholder: 'First', onChanged: (_) => setState(() => _saved = false))),
                          const SizedBox(width: 8),
                          Expanded(child: CustomTextField(label: 'Last Name', controller: _lastCtrl, placeholder: 'Last', onChanged: (_) => setState(() => _saved = false))),
                        ]),
                        if (!isAdmin) ...[
                          const SizedBox(height: 12),
                          Text('DEPARTMENT', style: AppTextStyles.label()),
                          const SizedBox(height: 5),
                          GestureDetector(
                            onTap: () => setState(() => _showDepts = !_showDepts),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                              decoration: BoxDecoration(color: AppColors.surfaceAlt, borderRadius: BorderRadius.circular(8), border: Border.all(color: _showDepts ? AppColors.accent.withOpacity(0.5) : AppColors.border)),
                              child: Row(children: [
                                Expanded(child: Text(_dept.isEmpty ? 'Select department' : _dept, style: AppTextStyles.body(13, color: _dept.isEmpty ? AppColors.textDim : AppColors.text))),
                                AnimatedRotation(turns: _showDepts ? 0.25 : 0, duration: const Duration(milliseconds: 200), child: Icon(Icons.chevron_right, color: AppColors.textDim, size: 14)),
                              ]),
                            ),
                          ),
                          if (_showDepts)
                            Container(
                              margin: const EdgeInsets.only(top: 4),
                              constraints: const BoxConstraints(maxHeight: 160),
                              decoration: BoxDecoration(color: AppColors.surfaceHigh, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.border)),
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: kDepartments.length,
                                itemBuilder: (_, i) => GestureDetector(
                                  onTap: () => setState(() { _dept = kDepartments[i]; _showDepts = false; _saved = false; }),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                    decoration: BoxDecoration(color: _dept == kDepartments[i] ? AppColors.accentFaded : Colors.transparent, border: Border(bottom: BorderSide(color: AppColors.borderLight))),
                                    child: Text(kDepartments[i], style: AppTextStyles.body(12, color: _dept == kDepartments[i] ? AppColors.accent : AppColors.text)),
                                  ),
                                ),
                              ),
                            ),
                        ],
                        if (isAdmin) ...[
                          const SizedBox(height: 4),
                          Text('Your name as the club representative. Not shown publicly.', style: AppTextStyles.caption(size: 10).copyWith(height: 1.5)),
                        ],
                      ]),
                    ),
                    const SizedBox(height: 16),
                    _saved
                        ? Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            decoration: BoxDecoration(color: AppColors.successFaded, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.success.withOpacity(0.3))),
                            child: Row(children: [Icon(Icons.check, color: AppColors.success, size: 14), const SizedBox(width: 8), Text('Changes saved', style: TextStyle(fontSize: 12, color: AppColors.success))]),
                          )
                        : SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () => _save(state),
                              style: ElevatedButton.styleFrom(backgroundColor: isAdmin ? AppColors.warning : AppColors.accent, foregroundColor: AppColors.bg, padding: const EdgeInsets.symmetric(vertical: 13), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), elevation: 0),
                              child: Text('Save Changes', style: AppTextStyles.body(13, color: AppColors.bg, weight: FontWeight.w600)),
                            ),
                          ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () { state.logout(); Navigator.pushReplacementNamed(context, AppRoutes.welcome); },
                        style: OutlinedButton.styleFrom(foregroundColor: AppColors.danger, side: BorderSide(color: AppColors.danger.withOpacity(0.3)), padding: const EdgeInsets.symmetric(vertical: 13), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                        child: Text('Sign Out', style: AppTextStyles.body(13, color: AppColors.danger, weight: FontWeight.w500)),
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