import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../utils/text_styles.dart';
import '../../widgets/custom_app_bar.dart';

class FaqScreen extends StatefulWidget {
  const FaqScreen({super.key});
  @override
  State<FaqScreen> createState() => _FaqScreenState();
}

class _FaqScreenState extends State<FaqScreen> {
  int? _open;

  static const _faqs = [
    ('Why do I need a @sabanciuniv.edu email?', 'CampusBoard is a closed platform for Sabancı University only. The email verifies you\'re a member without needing a password.'),
    ('Do I need to verify my email every time I open the app?', 'No. You only verify once on first login, or when you switch to a new device. After that you stay signed in automatically.'),
    ('Where does my name come from?', 'You enter your first name, last name, and department during the onboarding step right after your first login. You can edit them anytime from Settings → Account & Profile.'),
    ('How do I become a club admin?', 'Admin status is assigned by the CampusBoard team based on official club registration. Contact us via the Feedback page if your club isn\'t listed.'),
    ('My verification code didn\'t arrive. What do I do?', 'Check your spam folder first. If it\'s still not there after a minute, tap \'Resend code\' on the verification screen. Codes expire after 10 minutes.'),
    ('Is CampusBoard an official Sabancı University app?', 'No. It\'s a student project created for the CS310 Mobile Application Development course and is not affiliated with or endorsed by Sabancı University.'),
    ('Can I add events to my phone\'s calendar?', 'Calendar export is a planned feature. For now, save events in-app and set a reminder from the Notifications settings.'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            CustomAppBar(onBack: () => Navigator.pop(context), title: 'FAQ & Help', subtitle: 'Frequently asked questions'),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _faqs.length + 1,
                itemBuilder: (_, i) {
                  if (i == _faqs.length) return const SizedBox(height: 20);
                  final faq = _faqs[i];
                  final isOpen = _open == i;
                  return GestureDetector(
                    onTap: () => setState(() => _open = isOpen ? null : i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: isOpen ? AppColors.accent.withOpacity(0.4) : AppColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                            child: Row(children: [
                              Expanded(child: Text(faq.$1, style: AppTextStyles.body(13, weight: isOpen ? FontWeight.w500 : FontWeight.w400).copyWith(height: 1.4))),
                              const SizedBox(width: 8),
                              AnimatedRotation(turns: isOpen ? 0.25 : 0, duration: const Duration(milliseconds: 200),
                                  child: Icon(Icons.chevron_right, color: isOpen ? AppColors.accent : AppColors.textDim, size: 14)),
                            ]),
                          ),
                          if (isOpen)
                            Padding(
                              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                              child: Text(faq.$2, style: AppTextStyles.body(12, color: AppColors.textSec).copyWith(height: 1.7)),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
