import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../utils/text_styles.dart';
import '../../utils/routes.dart';
import '../../widgets/bottom_nav.dart';
import '../../app_state.dart';

class MyEventsScreen extends StatefulWidget {
  const MyEventsScreen({super.key});

  @override
  State<MyEventsScreen> createState() => _MyEventsScreenState();
}

class _MyEventsScreenState extends State<MyEventsScreen> {
  String _tab = 'saved';

  IconData _catIcon(String cat) {
    switch (cat) {
      case 'Academic': return Icons.menu_book_outlined;
      case 'Social':   return Icons.people_outlined;
      case 'Sports':   return Icons.sports_basketball_outlined;
      case 'Career':   return Icons.work_outline;
      case 'Arts':     return Icons.palette_outlined;
      default:         return Icons.event_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);
    final role  = state.role;
    final visibleEvents = state.eventsForRole(role);
    final saved = visibleEvents.where((e) => e.saved).toList();
    final rsvped = visibleEvents.where((e) => state.isAttending(e.id)).toList();
    final items = _tab == 'saved' ? saved : rsvped;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 2, 20, 14),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('My Events', style: AppTextStyles.screenTitle()),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(color: AppColors.surfaceAlt, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.border)),
                  child: Row(
                    children: [
                      for (final tab in [('saved', 'Saved', saved.length), ('rsvp', "RSVP'd", rsvped.length)])
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _tab = tab.$1),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 160),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: _tab == tab.$1 ? AppColors.surface : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text('${tab.$2} (${tab.$3})', style: AppTextStyles.body(12, color: _tab == tab.$1 ? AppColors.text : AppColors.textDim, weight: FontWeight.w500)),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ]),
            ),
            Expanded(
              child: items.isEmpty
                  ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                      Icon(_tab == 'saved' ? Icons.bookmark_border : Icons.check_circle_outline, color: AppColors.textMuted, size: 32),
                      const SizedBox(height: 14),
                      Text(_tab == 'saved' ? 'Nothing saved yet' : "No RSVP'd events yet", style: AppTextStyles.body(14, color: AppColors.textDim)),
                      const SizedBox(height: 4),
                      Text(_tab == 'saved' ? 'Bookmark events to find them here' : 'Confirmed events will appear here', style: AppTextStyles.caption(size: 11)),
                    ]))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: items.length,
                      itemBuilder: (_, i) {
                        final e = items[i];
                        final c = AppColors.postit[e.id % AppColors.postit.length];
                        return GestureDetector(
                          onTap: () { state.selectEvent(e); Navigator.pushNamed(context, AppRoutes.eventDetail); },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.border)),
                            child: Row(children: [
                              if (e.posterUrl != null)
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: e.posterUrl!.startsWith('assets/')
                                      ? Image.asset(e.posterUrl!, width: 54, height: 54, fit: BoxFit.cover)
                                      : Image.network(
                                          e.posterUrl!,
                                          width: 54,
                                          height: 54,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) => Container(
                                            width: 54,
                                            height: 54,
                                            decoration: BoxDecoration(color: c.bg, borderRadius: BorderRadius.circular(8), border: Border.all(color: c.border)),
                                            child: Icon(_catIcon(e.cat), color: c.pin, size: 18),
                                          ),
                                        ),
                                )
                              else
                                Container(
                                  width: 54, height: 54,
                                  decoration: BoxDecoration(color: c.bg, borderRadius: BorderRadius.circular(8), border: Border.all(color: c.border)),
                                  child: Icon(_catIcon(e.cat), color: c.pin, size: 18),
                                ),
                              const SizedBox(width: 12),
                              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text(e.title, style: AppTextStyles.body(13, weight: FontWeight.w500)),
                                const SizedBox(height: 2),
                                Text('${e.club} · ${e.date} · ${e.time}', style: AppTextStyles.caption(size: 10)),
                              ])),
                              GestureDetector(
                                onTap: () {
                                  if (_tab == 'saved') {
                                    state.toggleSave(e.id);
                                  } else {
                                    state.toggleAttendance(e.id);
                                  }
                                },
                                child: Icon(_tab == 'saved' ? Icons.bookmark : Icons.check_circle, color: _tab == 'saved' ? AppColors.accent : AppColors.success, size: 16),
                              ),
                            ]),
                          ),
                        );
                      },
                    ),
            ),
            BottomNav(active: AppRoutes.myEvents, role: role, onNav: (r) => Navigator.pushReplacementNamed(context, r)),
          ],
        ),
      ),
    );
  }
}
