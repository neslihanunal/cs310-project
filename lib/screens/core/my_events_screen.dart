import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/event_provider.dart';
import '../../utils/app_colors.dart';
import '../../utils/routes.dart';
import '../../utils/text_styles.dart';
import '../../widgets/bottom_nav.dart';

class MyEventsScreen extends StatefulWidget {
  const MyEventsScreen({super.key});

  @override
  State<MyEventsScreen> createState() => _MyEventsScreenState();
}

class _MyEventsScreenState extends State<MyEventsScreen> {
  String _tab = 'saved';

  IconData _catIcon(String cat) {
    switch (cat) {
      case 'Academic':
        return Icons.menu_book_outlined;
      case 'Social':
        return Icons.people_outlined;
      case 'Sports':
        return Icons.sports_basketball_outlined;
      case 'Career':
        return Icons.work_outline;
      case 'Arts':
        return Icons.palette_outlined;
      default:
        return Icons.event_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final eventProvider = context.watch<EventProvider>();

    final role = authProvider.role;
    final saved = eventProvider.savedEvents(authProvider.uid);
    final rsvped = eventProvider.attendingEvents(authProvider.uid);
    final items = _tab == 'saved' ? saved : rsvped;

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
                  Text('My Events', style: AppTextStyles.screenTitle()),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceAlt,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        for (final tab in [
                          ('saved', 'Saved', saved.length),
                          ('rsvp', "RSVP'd", rsvped.length),
                        ])
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _tab = tab.$1),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 160),
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                decoration: BoxDecoration(
                                  color: _tab == tab.$1
                                      ? AppColors.surface
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: Text(
                                    '${tab.$2} (${tab.$3})',
                                    style: AppTextStyles.body(
                                      12,
                                      color: _tab == tab.$1
                                          ? AppColors.text
                                          : AppColors.textDim,
                                      weight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: items.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _tab == 'saved'
                                ? Icons.bookmark_border
                                : Icons.check_circle_outline,
                            color: AppColors.textMuted,
                            size: 32,
                          ),
                          const SizedBox(height: 14),
                          Text(
                            _tab == 'saved'
                                ? 'Nothing saved yet'
                                : "No RSVP'd events yet",
                            style: AppTextStyles.body(
                              14,
                              color: AppColors.textDim,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _tab == 'saved'
                                ? 'Bookmark events to find them here'
                                : 'Confirmed events will appear here',
                            style: AppTextStyles.caption(size: 11),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: items.length,
                      itemBuilder: (_, index) {
                        final event = items[index];
                        final colors = AppColors.postit[
                            event.colorSeed % AppColors.postit.length];
                        return GestureDetector(
                          onTap: () {
                            eventProvider.selectEvent(event);
                            Navigator.pushNamed(context, AppRoutes.eventDetail);
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Row(
                              children: [
                                if (event.posterUrl != null)
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: event.posterUrl!.startsWith('assets/')
                                        ? Image.asset(
                                            event.posterUrl!,
                                            width: 54,
                                            height: 54,
                                            fit: BoxFit.cover,
                                          )
                                        : Image.network(
                                            event.posterUrl!,
                                            width: 54,
                                            height: 54,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) =>
                                                Container(
                                              width: 54,
                                              height: 54,
                                              decoration: BoxDecoration(
                                                color: colors.bg,
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                border: Border.all(
                                                  color: colors.border,
                                                ),
                                              ),
                                              child: Icon(
                                                _catIcon(event.cat),
                                                color: colors.pin,
                                                size: 18,
                                              ),
                                            ),
                                          ),
                                  )
                                else
                                  Container(
                                    width: 54,
                                    height: 54,
                                    decoration: BoxDecoration(
                                      color: colors.bg,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: colors.border),
                                    ),
                                    child: Icon(
                                      _catIcon(event.cat),
                                      color: colors.pin,
                                      size: 18,
                                    ),
                                  ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        event.title,
                                        style: AppTextStyles.body(
                                          13,
                                          weight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${event.club} · ${event.date} · ${event.time}',
                                        style: AppTextStyles.caption(size: 10),
                                      ),
                                    ],
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    if (authProvider.uid == null) {
                                      return;
                                    }
                                    if (_tab == 'saved') {
                                      eventProvider.toggleSave(
                                        event.id,
                                        authProvider.uid!,
                                      );
                                    } else {
                                      eventProvider.toggleAttendance(
                                        event.id,
                                        authProvider.uid!,
                                      );
                                    }
                                  },
                                  child: Icon(
                                    _tab == 'saved'
                                        ? Icons.bookmark
                                        : Icons.check_circle,
                                    color: _tab == 'saved'
                                        ? AppColors.accent
                                        : AppColors.success,
                                    size: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
            BottomNav(
              active: AppRoutes.myEvents,
              role: role,
              onNav: (route) => Navigator.pushReplacementNamed(context, route),
            ),
          ],
        ),
      ),
    );
  }
}
