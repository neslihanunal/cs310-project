import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../utils/app_colors.dart';
import '../../utils/text_styles.dart';
import '../../utils/routes.dart';
import '../../utils/dummy_data.dart';
import '../../models/user_model.dart';
import '../../widgets/custom_text_field.dart';
import '../../app_state.dart';
import 'splash_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  int _step = 1;
  final _emailCtrl = TextEditingController();
  final List<TextEditingController> _otpCtrls =
  List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _otpFocus = List.generate(6, (_) => FocusNode());
  String _emailError = '';
  String _otpError = '';
  bool _sending = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    for (final c in _otpCtrls) c.dispose();
    for (final f in _otpFocus) f.dispose();
    super.dispose();
  }

  void _sendCode() async {
    final email = _emailCtrl.text.trim().toLowerCase();
    if (!email.endsWith('@sabanciuniv.edu')) {
      setState(() => _emailError = 'Please use your @sabanciuniv.edu address.');
      return;
    }
    setState(() {
      _emailError = '';
      _sending = true;
    });
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    setState(() {
      _sending = false;
      _step = 2;
    });
  }

  void _verify() {
    final code = _otpCtrls.map((c) => c.text).join();
    if (code.length < 6) {
      setState(() => _otpError = 'Enter the 6-digit code from your email.');
      return;
    }
    final email = _emailCtrl.text.trim().toLowerCase();
    final seed = kDemoSeeds[email] ??
        const User(
          role: 'student',
          firstName: '',
          lastName: '',
          dept: '',
        );
    final existingProfile = AppStateProvider.of(context).profileForEmail(email);
    if (existingProfile != null) {
      Navigator.pushReplacementNamed(
        context,
        AppRoutes.dashboard,
        arguments: {'user': existingProfile, 'email': email},
      );
      return;
    }
    Navigator.pushReplacementNamed(
      context,
      AppRoutes.onboarding,
      arguments: {'email': email, 'seed': seed},
    );
  }

  void _handleOtp(String val, int i) {
    if (val.isNotEmpty && i < 5) {
      FocusScope.of(context).requestFocus(_otpFocus[i + 1]);
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  onTap: () {
                    if (_step == 2) {
                      setState(() {
                        _step = 1;
                        for (final c in _otpCtrls) c.clear();
                        _otpError = '';
                      });
                    } else {
                      Navigator.pop(context);
                    }
                  },
                  child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Icon(Icons.arrow_back,
                          color: AppColors.textSec, size: 18)),
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _step == 1 ? _buildEmailStep() : _buildOtpStep(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmailStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        const AppLogo(size: 24),
        const SizedBox(height: 12),
        Text('Sign in', style: AppTextStyles.heading(22)),
        const SizedBox(height: 4),
        Text(
            'Enter your Sabancı University email. We\'ll send a one-time code — no password needed.',
            style: AppTextStyles.body(12, color: AppColors.textSec)
                .copyWith(height: 1.6)),
        const SizedBox(height: 28),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border)),
          child: Column(
            children: [
              CustomTextField(
                label: 'University Email',
                placeholder: 'name@sabanciuniv.edu',
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                prefixIcon: const Icon(Icons.mail_outline, size: 14),
                onChanged: (_) => setState(() => _emailError = ''),
              ),
              if (_emailError.isNotEmpty) ...[
                const SizedBox(height: 8),
                _ErrorBanner(text: _emailError),
              ],
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _sending ? null : _sendCode,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: AppColors.bg,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                    disabledBackgroundColor: AppColors.accent.withOpacity(0.75),
                  ),
                  child: Text(_sending ? 'Sending…' : 'Send Verification Code',
                      style: AppTextStyles.body(14,
                          color: AppColors.bg, weight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOtpStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
              color: AppColors.accentFaded,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.accent.withOpacity(0.3))),
          child: Icon(Icons.mail_outline, color: AppColors.accent, size: 20),
        ),
        const SizedBox(height: 16),
        Text('Check your email', style: AppTextStyles.heading(22)),
        const SizedBox(height: 6),
        RichText(
          text: TextSpan(
              style: AppTextStyles.body(12, color: AppColors.textSec)
                  .copyWith(height: 1.6),
              children: [
                const TextSpan(text: 'We sent a 6-digit code to\n'),
                TextSpan(
                    text: _emailCtrl.text.trim(),
                    style: AppTextStyles.body(12, weight: FontWeight.w500)),
              ]),
        ),
        const SizedBox(height: 28),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('VERIFICATION CODE', style: AppTextStyles.label()),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                    6,
                        (i) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: SizedBox(
                        width: 40,
                        height: 48,
                        child: TextField(
                          controller: _otpCtrls[i],
                          focusNode: _otpFocus[i],
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          maxLength: 1,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          style: AppTextStyles.body(20,
                              weight: FontWeight.w600),
                          onChanged: (v) {
                            _handleOtp(v, i);
                            setState(() => _otpError = '');
                          },
                          decoration: InputDecoration(
                            counterText: '',
                            filled: true,
                            fillColor: AppColors.surfaceAlt,
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide:
                                BorderSide(color: AppColors.border)),
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide:
                                BorderSide(color: AppColors.border)),
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                    color:
                                    AppColors.accent.withOpacity(0.6))),
                          ),
                        ),
                      ),
                    )),
              ),
              if (_otpError.isNotEmpty) ...[
                const SizedBox(height: 10),
                _ErrorBanner(text: _otpError),
              ],
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _verify,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: AppColors.bg,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                  ),
                  child: Text('Verify & Continue',
                      style: AppTextStyles.body(14,
                          color: AppColors.bg, weight: FontWeight.w600)),
                ),
              ),
              const SizedBox(height: 14),
              Center(
                child: GestureDetector(
                  onTap: () => setState(() {
                    _step = 1;
                    for (final c in _otpCtrls) c.clear();
                    _otpError = '';
                  }),
                  child: RichText(
                      text: TextSpan(
                          style: AppTextStyles.caption(size: 11),
                          children: [
                            const TextSpan(text: "Didn't receive it? "),
                            TextSpan(
                                text: 'Resend code',
                                style: TextStyle(color: AppColors.accent)),
                          ])),
                ),
              ),
            ],
          ),
        ),
      ],
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
