import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../utils/text_styles.dart';
import '../../utils/routes.dart';
import '../../utils/dummy_data.dart';
import '../../widgets/bottom_nav.dart';
import '../../widgets/event_card.dart';
import '../../widgets/category_chip.dart';
import '../../app_state.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _filter = 'All';
  String _tab = 'all';
  String _search = '';
  bool _searchOpen = false;
  final _searchCtrl = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final state = AppStateProvider.of(context);
    if (state.role == 'admin' && _tab != state.adminDashboardTab) {
      _tab = state.adminDashboardTab;
    }
  }

  static String _currentMonthYear() {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    final now = DateTime.now();
    return '${months[now.month - 1]} ${now.year}';
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);
    final role = state.role;
    final isAdmin = role == 'admin';
    final isListLayout = !isAdmin && state.dashboardLayout == 'list';
    final tabs = isAdmin
        ? const [('all', 'All Events'), ('my', 'Our Events')]
        : const [('all', 'All Events'), ('saved', 'Saved'), ('rsvp', "RSVP'd")];

    final sourceEvents = state.eventsForRole(role);
    final events = sourceEvents.where((e) {
      final prefOk = isAdmin || state.preferredCategories.contains(e.cat);
      final catOk = _filter == 'All' || e.cat == _filter;
      final tabOk = switch (_tab) {
        'saved' => e.saved,
        'rsvp' => state.isAttending(e.id),
        'my' => e.clubId == state.currentClubId,
        _ => true,
      };
      final srchOk = _search.isEmpty ||
          e.title.toLowerCase().contains(_search.toLowerCase()) ||
          e.club.toLowerCase().contains(_search.toLowerCase());
      return prefOk && catOk && tabOk && srchOk;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 2, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Board', style: AppTextStyles.screenTitle()),
                            Text(_currentMonthYear(), style: AppTextStyles.caption()),
                          ]),
                      const Spacer(),
                      _IconBtn(
                        active: _searchOpen,
                        icon: _searchOpen ? Icons.close : Icons.search,
                        onTap: () => setState(() {
                          _searchOpen = !_searchOpen;
                          if (!_searchOpen) {
                            _search = '';
                            _searchCtrl.clear();
                          }
                        }),
                      ),
                    ],
                  ),
                  if (_searchOpen) ...[
                    const SizedBox(height: 10),
                    TextField(
                      controller: _searchCtrl,
                      autofocus: true,
                      onChanged: (v) => setState(() => _search = v),
                      style: AppTextStyles.body(12),
                      cursorColor: AppColors.accent,
                      decoration: InputDecoration(
                        hintText: 'Search events or clubs…',
                        hintStyle:
                            AppTextStyles.body(12, color: AppColors.textDim),
                        filled: true,
                        fillColor: AppColors.surface,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                                color: AppColors.accent.withOpacity(0.4))),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                                color: AppColors.accent.withOpacity(0.4))),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                                color: AppColors.accent.withOpacity(0.4))),
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                        color: AppColors.surfaceAlt,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.border)),
                    child: Row(
                      children: tabs.map((tab) {
                        final act = _tab == tab.$1;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() {
                              _tab = tab.$1;
                              if (isAdmin) state.setAdminDashboardTab(tab.$1);
                            }),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                  color: act
                                      ? AppColors.surface
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8)),
                              child: Center(
                                child: Text(tab.$2,
                                    style: AppTextStyles.body(12,
                                        color: act
                                            ? AppColors.text
                                            : AppColors.textDim,
                                        weight: FontWeight.w500)),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 30,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: kCategories.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 5),
                      itemBuilder: (_, i) {
                        final cat = kCategories[i];
                        return CategoryChip(
                            label: cat,
                            isActive: _filter == cat,
                            onTap: () => setState(() => _filter = cat));
                      },
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
              ),
            ),
            Expanded(
              child: events.isEmpty
                  ? Center(
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        Icon(Icons.event_busy_outlined,
                            color: AppColors.textMuted, size: 28),
                        const SizedBox(height: 12),
                        Text('No events found',
                            style: AppTextStyles.body(13,
                                color: AppColors.textDim)),
                      ]),
                    )
                  : isListLayout
                      ? ListView.builder(
                          padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
                          itemCount: events.length,
                          itemBuilder: (_, i) {
                            final e = events[i];
                            final c = AppColors
                                .postit[e.id % AppColors.postit.length];
                            return GestureDetector(
                              onTap: () {
                                state.selectEvent(e);
                                Navigator.pushNamed(
                                    context, AppRoutes.eventDetail);
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
                                    Container(
                                      width: 3,
                                      height: 38,
                                      decoration: BoxDecoration(
                                        color: c.pin,
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            e.title,
                                            style: AppTextStyles.body(
                                              13,
                                              weight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 3),
                                          Text(
                                            '${e.club} · ${e.date} · ${e.time}',
                                            style:
                                                AppTextStyles.caption(size: 10),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            'Location: ${e.loc}',
                                            style: AppTextStyles.caption(
                                              size: 10,
                                              color: AppColors.textSec,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () => state.toggleSave(e.id),
                                      child: Icon(
                                        e.saved
                                            ? Icons.bookmark
                                            : Icons.bookmark_border,
                                        color: e.saved
                                            ? AppColors.accent
                                            : AppColors.textDim,
                                        size: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        )
                      : GridView.builder(
                          padding: const EdgeInsets.fromLTRB(14, 4, 14, 8),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.62,
                          ),
                          itemCount: events.length,
                          itemBuilder: (_, i) {
                            final e = events[i];
                            return EventCard(
                              event: e,
                              idx: i,
                              onTap: () {
                                state.selectEvent(e);
                                Navigator.pushNamed(
                                    context, AppRoutes.eventDetail);
                              },
                              onSave: () => state.toggleSave(e.id),
                              interestedCount: e.rsvp,
                              showAdminActions: isAdmin && _tab == 'my',
                              onEdit: isAdmin && _tab == 'my'
                                  ? () {
                                      state.setEditingEvent(e);
                                      Navigator.pushNamed(
                                          context, AppRoutes.createEvent);
                                    }
                                  : null,
                              onDelete: isAdmin && _tab == 'my'
                                  ? () => _confirmDelete(
                                      context, state, e.id, e.title)
                                  : null,
                            );
                          },
                        ),
            ),
            BottomNav(
                active: AppRoutes.dashboard,
                role: role,
                onNav: (r) => Navigator.pushReplacementNamed(context, r)),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(
      BuildContext context, AppState state, int id, String title) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surfaceHigh,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Text('Delete Event?', style: AppTextStyles.heading(16)),
        content: Text(
            '"$title" will be removed from student-facing pages and deleted permanently.',
            style: AppTextStyles.body(12, color: AppColors.textSec)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              state.removeEvent(id);
              Navigator.pop(context);
            },
            child: Text('Delete',
                style: TextStyle(
                    color: AppColors.danger, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final bool active;
  final VoidCallback onTap;
  const _IconBtn(
      {required this.icon, required this.onTap, this.active = false});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: active ? AppColors.accentFaded : AppColors.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
                color: active
                    ? AppColors.accent.withOpacity(0.5)
                    : AppColors.border),
          ),
          child: Icon(icon,
              color: active ? AppColors.accent : AppColors.textSec, size: 14),
        ),
      );
}
