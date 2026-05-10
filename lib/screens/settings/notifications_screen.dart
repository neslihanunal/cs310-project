import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../utils/text_styles.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_toggle.dart';
import '../../app_state.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});
  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  Map<String, bool> _settings = {};

  static const _studentRows = [
    (
      'reminders',
      'Push Reminders',
      'Device notifications before saved events start'
    ),
    ('newEvents', 'New Events', 'When clubs post announcements'),
    ('rsvpConfirm', 'RSVP Confirmations', 'When you confirm attendance'),
    ('cancellations', 'Cancellations', 'If a saved event is cancelled'),
    ('digest', 'Weekly Digest', 'Monday summary of upcoming events'),
  ];

  static const _adminRows = [
    ('newRsvp', 'New RSVPs', 'When a student confirms attendance'),
    ('milestones', 'RSVP Milestones', 'At 10, 50, 100 attendees'),
    ('expiry', 'Event Expiry', '24h before your event goes live'),
    (
      'editConfirm',
      'Publish Confirmations',
      'After you publish or edit an event'
    ),
    ('clubDigest', 'Weekly Club Report', "Your club's reach & engagement"),
  ];

  @override
  void initState() {
    super.initState();
    // Default first 3 on
    _settings = {
      for (var i = 0; i < _studentRows.length; i++) _studentRows[i].$1: i < 3
    };
    _settings.addAll(
        {for (var i = 0; i < _adminRows.length; i++) _adminRows[i].$1: i < 3});
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);
    final isAdmin = state.role == 'admin';
    final rows = isAdmin ? _adminRows : _studentRows;
    final reminderCopy = isAdmin
        ? 'Club notifications stay on this device and inside CampusBoard.'
        : 'Saved-event reminders are currently set to ${state.reminderLabel} before start.';

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            CustomAppBar(
              onBack: () => Navigator.pop(context),
              title: isAdmin ? 'Publishing Alerts' : 'Notifications',
              subtitle: isAdmin
                  ? "Stay on top of your club's activity"
                  : 'Choose what CampusBoard notifies you about',
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  Container(
                    decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border)),
                    child: Column(
                      children: rows.asMap().entries.map((entry) {
                        final i = entry.key;
                        final row = entry.value;
                        return GestureDetector(
                          onTap: () => setState(() => _settings[row.$1] =
                              !(_settings[row.$1] ?? false)),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 13),
                            decoration: BoxDecoration(
                                border: i < rows.length - 1
                                    ? Border(
                                        bottom: BorderSide(
                                            color: AppColors.borderLight))
                                    : null),
                            child: Row(children: [
                              Expanded(
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                    Text(row.$2, style: AppTextStyles.body(13)),
                                    const SizedBox(height: 2),
                                    Text(row.$3,
                                        style: AppTextStyles.caption(size: 10)),
                                  ])),
                              const SizedBox(width: 12),
                              CustomToggle(
                                value: _settings[row.$1] ?? false,
                                activeColor: isAdmin
                                    ? AppColors.warning
                                    : AppColors.accent,
                                onTap: () => setState(() => _settings[row.$1] =
                                    !(_settings[row.$1] ?? false)),
                              ),
                            ]),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isAdmin
                          ? AppColors.warningFaded
                          : AppColors.accentFaded,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color:
                              (isAdmin ? AppColors.warning : AppColors.accent)
                                  .withOpacity(0.2)),
                    ),
                    child: RichText(
                      text: TextSpan(
                          style:
                              AppTextStyles.body(11, color: AppColors.textSec)
                                  .copyWith(height: 1.6),
                          children: [
                            TextSpan(text: '$reminderCopy '),
                            const TextSpan(
                                text:
                                    'Push notifications appear on this device and inside '),
                            TextSpan(
                                text: 'CampusBoard',
                                style: TextStyle(color: AppColors.text)),
                            const TextSpan(text: '.'),
                          ]),
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
