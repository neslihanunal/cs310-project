import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../utils/text_styles.dart';
import '../../widgets/custom_app_bar.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  static const _sections = [
    ('What data we collect', 'CampusBoard collects your Sabancı University email address, your first name, last name, and department (entered during onboarding), and your in-app activity — events viewed, saved, or RSVP\'d. We do not collect passwords.'),
    ('How your data is used', 'Your data is used to personalise your event feed and send reminders for saved events. Club administrators see aggregate RSVP counts only — never individual student names.'),
    ('University email verification', 'Your @sabanciuniv.edu address is used solely to verify university membership and determine your role (student or club admin). Role assignment is handled by the backend database.'),
    ('Data retention', 'Your account data is kept while your account is active. Saved events and RSVP records are deleted 30 days after the event passes. You can request full account deletion at any time via the Feedback page.'),
    ('Not an official Sabancı app', 'CampusBoard is a student project for CS310. It is not affiliated with or endorsed by Sabancı University. You are not required to use it.'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            CustomAppBar(onBack: () => Navigator.pop(context), title: 'Privacy Policy', subtitle: 'Last updated: April 2026'),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: AppColors.accentFaded, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.accent.withOpacity(0.2))),
                    child: RichText(
                      text: TextSpan(style: AppTextStyles.body(12, color: AppColors.textSec).copyWith(height: 1.6), children: [
                        const TextSpan(text: 'CampusBoard is a '),
                        TextSpan(text: 'student project', style: TextStyle(color: AppColors.text)),
                        const TextSpan(text: ' for CS310, not an official Sabancı University application. We are committed to responsible data handling.'),
                      ]),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ..._sections.map((s) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(s.$1, style: AppTextStyles.body(13, color: AppColors.accent, weight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      Text(s.$2, style: AppTextStyles.body(12, color: AppColors.textSec).copyWith(height: 1.7)),
                    ]),
                  )),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
