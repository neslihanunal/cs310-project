import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/event_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/event_provider.dart';
import '../../utils/app_colors.dart';
import '../../utils/dummy_data.dart';
import '../../utils/routes.dart';
import '../../utils/text_styles.dart';
import '../../widgets/bottom_nav.dart';
import '../../widgets/category_chip.dart';
import '../../widgets/event_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final TextEditingController _searchController = TextEditingController();

  String _filter = 'All';
  String _tab = 'all';
  String _search = '';
  bool _searchOpen = false;
  bool _initializedTab = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initializedTab) {
      return;
    }
    final authProvider = context.read<AuthProvider>();
    _tab = authProvider.lastSelectedTab;
    _initializedTab = true;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  static String _currentMonthYear() {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    final now = DateTime.now();
    return '${months[now.month - 1]} ${now.year}';
  }

  Future<void> _toggleSave(EventProvider eventProvider, String? uid, Event event) async {
    if (uid == null || uid.isEmpty) {
      return;
    }
    await eventProvider.toggleSave(event.id, uid);
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final eventProvider = context.watch<EventProvider>();

    final role = authProvider.role;
    final isAdmin = role == 'admin';
    final currentUid = authProvider.uid;
    final isListLayout = !isAdmin && authProvider.dashboardLayout == 'list';
    final tabs = isAdmin
        ? const [('all', 'All Events'), ('my', 'Our Events')]
        : const [('all', 'All Events'), ('saved', 'Saved'), ('rsvp', "RSVP'd")];
    final selectedTab = tabs.any((tab) => tab.$1 == _tab) ? _tab : 'all';

    final List<Event> sourceEvents = switch (selectedTab) {
      'saved' => eventProvider.savedEvents(currentUid),
      'rsvp' => eventProvider.attendingEvents(currentUid),
      'my' => eventProvider.adminOwnedEvents(
          currentUid,
          clubId: authProvider.currentClubId,
        ),
      _ => eventProvider.activeEvents,
    };

    final events = sourceEvents.where((event) {
      final preferenceAllowed = isAdmin ||
          authProvider.preferredCategories.contains(event.cat);
      final categoryAllowed = _filter == 'All' || event.cat == _filter;
      final searchAllowed = _search.isEmpty ||
          event.title.toLowerCase().contains(_search.toLowerCase()) ||
          event.club.toLowerCase().contains(_search.toLowerCase());
      return preferenceAllowed && categoryAllowed && searchAllowed;
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
                          Text(
                            _currentMonthYear(),
                            style: AppTextStyles.caption(),
                          ),
                        ],
                      ),
                      const Spacer(),
                      _IconBtn(
                        active: _searchOpen,
                        icon: _searchOpen ? Icons.close : Icons.search,
                        onTap: () => setState(() {
                          _searchOpen = !_searchOpen;
                          if (!_searchOpen) {
                            _search = '';
                            _searchController.clear();
                          }
                        }),
                      ),
                    ],
                  ),
                  if (_searchOpen) ...[
                    const SizedBox(height: 10),
                    TextField(
                      controller: _searchController,
                      autofocus: true,
                      onChanged: (value) => setState(() => _search = value),
                      style: AppTextStyles.body(12),
                      cursorColor: AppColors.accent,
                      decoration: InputDecoration(
                        hintText: 'Search events or clubs…',
                        hintStyle: AppTextStyles.body(
                          12,
                          color: AppColors.textDim,
                        ),
                        filled: true,
                        fillColor: AppColors.surface,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: AppColors.accent.withOpacity(0.4),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: AppColors.accent.withOpacity(0.4),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: AppColors.accent.withOpacity(0.4),
                          ),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceAlt,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: tabs.map((tab) {
                        final isActive = selectedTab == tab.$1;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() => _tab = tab.$1);
                              authProvider.updatePreferences(lastSelectedTab: tab.$1);
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: isActive
                                    ? AppColors.surface
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  tab.$2,
                                  style: AppTextStyles.body(
                                    12,
                                    color: isActive
                                        ? AppColors.text
                                        : AppColors.textDim,
                                    weight: FontWeight.w500,
                                  ),
                                ),
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
                      itemBuilder: (_, index) {
                        final category = kCategories[index];
                        return CategoryChip(
                          label: category,
                          isActive: _filter == category,
                          onTap: () => setState(() => _filter = category),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
              ),
            ),
            Expanded(
              child: eventProvider.isLoading && eventProvider.events.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : eventProvider.errorMessage != null &&
                          eventProvider.events.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 28),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  color: AppColors.danger,
                                  size: 28,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Could not load events',
                                  style: AppTextStyles.body(
                                    13,
                                    color: AppColors.text,
                                    weight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  eventProvider.errorMessage!,
                                  textAlign: TextAlign.center,
                                  style: AppTextStyles.caption(
                                    size: 10,
                                    color: AppColors.textSec,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : events.isEmpty
                          ? Center(
                              child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                              Icon(
                                Icons.event_busy_outlined,
                                color: AppColors.textMuted,
                                size: 28,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'No events found',
                                style: AppTextStyles.body(
                                  13,
                                  color: AppColors.textDim,
                                ),
                              ),
                            ],
                          ),
                        )
                      : isListLayout
                          ? ListView.builder(
                              padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
                              itemCount: events.length,
                              itemBuilder: (_, index) {
                                final event = events[index];
                                final colors = AppColors.postit[
                                    event.colorSeed % AppColors.postit.length];
                                final isSaved = event.isSavedBy(currentUid);
                                return GestureDetector(
                                  onTap: () {
                                    eventProvider.selectEvent(event);
                                    Navigator.pushNamed(
                                      context,
                                      AppRoutes.eventDetail,
                                    );
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
                                            color: colors.pin,
                                            borderRadius:
                                                BorderRadius.circular(2),
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
                                                  weight: FontWeight.w600,
                                                ),
                                              ),
                                              const SizedBox(height: 3),
                                              Text(
                                                '${event.club} · ${event.date} · ${event.time}',
                                                style: AppTextStyles.caption(
                                                  size: 10,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                'Location: ${event.loc}',
                                                style: AppTextStyles.caption(
                                                  size: 10,
                                                  color: AppColors.textSec,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (!isAdmin)
                                          GestureDetector(
                                            onTap: () => _toggleSave(
                                              eventProvider,
                                              currentUid,
                                              event,
                                            ),
                                            child: Icon(
                                              isSaved
                                                  ? Icons.bookmark
                                                  : Icons.bookmark_border,
                                              color: isSaved
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
                              itemBuilder: (_, index) {
                                final event = events[index];
                                return EventCard(
                                  event: event,
                                  idx: index,
                                  isSaved: event.isSavedBy(currentUid),
                                  interestedCount: event.rsvpCount,
                                  onTap: () {
                                    eventProvider.selectEvent(event);
                                    Navigator.pushNamed(
                                      context,
                                      AppRoutes.eventDetail,
                                    );
                                  },
                                  onSave: isAdmin
                                      ? null
                                      : () => _toggleSave(
                                            eventProvider,
                                            currentUid,
                                            event,
                                          ),
                                  showAdminActions: isAdmin && _tab == 'my',
                                  onEdit: isAdmin && _tab == 'my'
                                      ? () {
                                          eventProvider.setEditingEvent(event);
                                          Navigator.pushNamed(
                                            context,
                                            AppRoutes.createEvent,
                                          );
                                        }
                                      : null,
                                  onDelete: isAdmin && _tab == 'my'
                                      ? () => _confirmDelete(
                                            context,
                                            eventProvider,
                                            event.id,
                                            event.title,
                                          )
                                      : null,
                                );
                              },
                            ),
            ),
            BottomNav(
              active: AppRoutes.dashboard,
              role: role,
              onNav: (route) {
                Navigator.pushReplacementNamed(context, route);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    EventProvider eventProvider,
    String eventId,
    String title,
  ) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surfaceHigh,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Text('Delete Event?', style: AppTextStyles.heading(16)),
        content: Text(
          '"$title" will be removed from student-facing pages.',
          style: AppTextStyles.body(12, color: AppColors.textSec),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await eventProvider.deleteEvent(eventId);
              if (context.mounted) {
                Navigator.pop(context);
              }
            },
            child: Text(
              'Delete',
              style: TextStyle(
                color: AppColors.danger,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  const _IconBtn({
    required this.icon,
    required this.onTap,
    this.active = false,
  });

  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: active ? AppColors.accentFaded : AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color:
                active ? AppColors.accent.withOpacity(0.5) : AppColors.border,
          ),
        ),
        child: Icon(
          icon,
          color: active ? AppColors.accent : AppColors.textSec,
          size: 14,
        ),
      ),
    );
  }
}
