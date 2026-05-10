import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../utils/text_styles.dart';
import '../../widgets/custom_app_bar.dart';
import '../auth/splash_screen.dart' show AppLogo;

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  static const _team = [
    ('Emir Mirza', 'Presentation & Communication Lead'),
    ('Erkan Ulaş Tepe', 'Learning & Research Lead'),
    ('Mirhat Harıkcı', 'Testing & Quality Assurance Lead'),
    ('Murat Çankaya', 'Project Coordinator'),
    ('Neslihan Ünal', 'Documentation & Submission Lead'),
    ('Sıla Kara', 'Integration & Repository Lead'),
  ];

  static const _stack = [
    'Flutter',
    'Dart',
    'Firebase Auth',
    'Cloud Firestore',
    'Firebase Storage',
    'Push Notifications'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            CustomAppBar(onBack: () => Navigator.pop(context)),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  // Logo + version header
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Column(children: [
                      const AppLogo(size: 36),
                      const SizedBox(height: 14),
                      Text('CampusBoard', style: AppTextStyles.screenTitle()),
                      const SizedBox(height: 4),
                      Text('v4.0 · CS310 · Spring 2026',
                          style: AppTextStyles.caption()),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 5),
                        decoration: BoxDecoration(
                            color: AppColors.warningFaded,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: AppColors.warning.withOpacity(0.3))),
                        child: Text(
                            'Student Project — Not an official Sabancı app',
                            style: TextStyle(
                                fontSize: 10,
                                color: AppColors.warning,
                                fontWeight: FontWeight.w500)),
                      ),
                    ]),
                  ),
                  Divider(color: AppColors.border),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      'A two-sided mobile platform consolidating Sabancı University club events into a single visual dashboard. Students discover events as interactive post-it notes; club admins manage announcements through a dedicated portal.',
                      style: AppTextStyles.body(12, color: AppColors.textSec)
                          .copyWith(height: 1.75),
                    ),
                  ),
                  Divider(color: AppColors.border),
                  // Team
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('TEAM', style: AppTextStyles.label()),
                          const SizedBox(height: 12),
                          ..._team.asMap().entries.map((entry) {
                            final i = entry.key;
                            final m = entry.value;
                            final c =
                                AppColors.postit[i % AppColors.postit.length];
                            return Padding(
                              padding: EdgeInsets.only(
                                  bottom: i < _team.length - 1 ? 8 : 0),
                              child: Row(children: [
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                      color: c.bg,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: c.border)),
                                  child: Center(
                                      child: Text(
                                          m.$1
                                              .split(' ')
                                              .map((n) => n[0])
                                              .join(''),
                                          style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w600,
                                              color: c.pin))),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                      Text(m.$1,
                                          style: AppTextStyles.body(12,
                                              weight: FontWeight.w500)),
                                      Text(m.$2,
                                          style:
                                              AppTextStyles.caption(size: 10)),
                                    ])),
                              ]),
                            );
                          }),
                        ]),
                  ),
                  Divider(color: AppColors.border),
                  // Stack
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('STACK', style: AppTextStyles.label()),
                          const SizedBox(height: 10),
                          Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: _stack
                                  .map((s) => Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                            color: AppColors.surfaceAlt,
                                            borderRadius:
                                                BorderRadius.circular(5),
                                            border: Border.all(
                                                color: AppColors.border)),
                                        child: Text(s,
                                            style: AppTextStyles.caption(
                                                size: 10,
                                                color: AppColors.textSec)),
                                      ))
                                  .toList()),
                        ]),
                  ),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('PROJECT NOTE', style: AppTextStyles.label()),
                        const SizedBox(height: 8),
                        Text(
                          'CampusBoard was designed as a course project to explore student event discovery, club-side publishing tools, and a cleaner campus communication experience.',
                          style:
                              AppTextStyles.body(12, color: AppColors.textSec)
                                  .copyWith(height: 1.65),
                        ),
                      ],
                    ),
                  ),
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
