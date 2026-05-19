import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/event_provider.dart';
import '../../utils/app_colors.dart';
import '../../utils/routes.dart';
import '../../utils/text_styles.dart';
import '../../widgets/bottom_nav.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final eventProvider = context.watch<EventProvider>();

    final isAdmin = authProvider.role == 'admin';
    final account = authProvider.currentUser;

    final sections = isAdmin
        ? [
            _SettingsRow(
              icon: Icons.person_outline,
              label: 'Club Profile',
              route: AppRoutes.profile,
            ),
            _SettingsRow(
              icon: Icons.notifications_outlined,
              label: 'Publishing Alerts',
              route: AppRoutes.notifications,
            ),
            _SettingsRow(
              icon: Icons.shield_outlined,
              label: 'Privacy',
              route: AppRoutes.privacy,
            ),
            _SettingsRow(
              icon: Icons.help_outline,
              label: 'FAQ & Help',
              route: AppRoutes.faq,
            ),
            _SettingsRow(
              icon: Icons.chat_bubble_outline,
              label: 'Send Feedback',
              route: AppRoutes.feedback,
            ),
            _SettingsRow(
              icon: Icons.info_outline,
              label: 'About CampusBoard',
              route: AppRoutes.about,
            ),
          ]
        : [
            _SettingsRow(
              icon: Icons.person_outline,
              label: 'Account & Profile',
              route: AppRoutes.profile,
            ),
            _SettingsRow(
              icon: Icons.tune_outlined,
              label: 'Event Preferences',
              route: AppRoutes.eventPrefs,
            ),
            _SettingsRow(
              icon: Icons.notifications_outlined,
              label: 'Notifications',
              route: AppRoutes.notifications,
            ),
            _SettingsRow(
              icon: Icons.shield_outlined,
              label: 'Privacy',
              route: AppRoutes.privacy,
            ),
            _SettingsRow(
              icon: Icons.help_outline,
              label: 'FAQ & Help',
              route: AppRoutes.faq,
            ),
            _SettingsRow(
              icon: Icons.chat_bubble_outline,
              label: 'Send Feedback',
              route: AppRoutes.feedback,
            ),
            _SettingsRow(
              icon: Icons.info_outline,
              label: 'About CampusBoard',
              route: AppRoutes.about,
            ),
          ];

    final clubEvents = eventProvider.adminOwnedEvents(
      authProvider.uid,
      clubId: authProvider.currentClubId,
    );
    final published = clubEvents.where((event) => !event.deleted).length;
    final upcoming = clubEvents
        .where((event) => !event.deleted && !eventProvider.isPastEvent(event))
        .length;
    final totalRsvps = clubEvents
        .where((event) => !event.deleted)
        .fold<int>(0, (sum, event) => sum + event.rsvpCount);

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 2, 20, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Settings', style: AppTextStyles.screenTitle()),
                  if (isAdmin) ...[
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.warningFaded,
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(
                          color: AppColors.warning.withOpacity(0.25),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 5,
                            height: 5,
                            decoration: BoxDecoration(
                              color: AppColors.warning,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            'Admin Portal',
                            style: TextStyle(
                              fontSize: 10,
                              color: AppColors.warning,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  if (isAdmin)
                    Container(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${account?.clubName ?? authProvider.currentClubName} OVERVIEW'
                                .toUpperCase(),
                            style: AppTextStyles.label(),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              for (final stat in [
                                ('Published', '$published'),
                                ('Upcoming', '$upcoming'),
                                ('Total RSVPs', '$totalRsvps'),
                              ])
                                Expanded(
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 3),
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                    decoration: BoxDecoration(
                                      color: AppColors.surfaceAlt,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: AppColors.border),
                                    ),
                                    child: Column(
                                      children: [
                                        Text(
                                          stat.$2,
                                          style: AppTextStyles.body(
                                            18,
                                            color: AppColors.accent,
                                            weight: FontWeight.w600,
                                          ).copyWith(letterSpacing: -0.02),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          stat.$1,
                                          style: AppTextStyles.caption(size: 9),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      children: sections.asMap().entries.map((entry) {
                        final index = entry.key;
                        final row = entry.value;
                        return GestureDetector(
                          onTap: () => Navigator.pushNamed(context, row.route),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 13,
                            ),
                            decoration: BoxDecoration(
                              border: index < sections.length - 1
                                  ? Border(
                                      bottom: BorderSide(
                                        color: AppColors.borderLight,
                                      ),
                                    )
                                  : null,
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 30,
                                  height: 30,
                                  decoration: BoxDecoration(
                                    color: isAdmin
                                        ? AppColors.warningFaded
                                        : AppColors.surfaceAlt,
                                    borderRadius: BorderRadius.circular(7),
                                    border: isAdmin
                                        ? Border.all(
                                            color: AppColors.warning
                                                .withOpacity(0.2),
                                          )
                                        : null,
                                  ),
                                  child: Icon(
                                    row.icon,
                                    color: isAdmin
                                        ? AppColors.warning
                                        : AppColors.textSec,
                                    size: 15,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    row.label,
                                    style: AppTextStyles.body(13)
                                        .copyWith(letterSpacing: -0.01),
                                  ),
                                ),
                                Icon(
                                  Icons.chevron_right,
                                  color: AppColors.textDim,
                                  size: 14,
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () async {
                      await authProvider.logout();
                      if (context.mounted) {
                        Navigator.pushReplacementNamed(
                          context,
                          AppRoutes.login,
                        );
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      decoration: BoxDecoration(
                        color: AppColors.dangerFaded,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: AppColors.danger.withOpacity(0.3),
                        ),
                      ),
                      child: Center(
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
                  ),
                ],
              ),
            ),
            BottomNav(
              active: AppRoutes.settings,
              role: authProvider.role,
              onNav: (route) => Navigator.pushReplacementNamed(context, route),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsRow {
  const _SettingsRow({
    required this.icon,
    required this.label,
    required this.route,
  });

  final IconData icon;
  final String label;
  final String route;
}
