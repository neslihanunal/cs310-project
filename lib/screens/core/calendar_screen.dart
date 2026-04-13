import 'package:flutter/material.dart';

import '../../app_state.dart';
import '../../utils/app_colors.dart';
import '../../utils/routes.dart';
import '../../utils/text_styles.dart';
import '../../widgets/bottom_nav.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDate = DateTime(now.year, now.month, now.day);
  }

  DateTime? _parseEventDate(String value) {
    final parts = value.split(' ');
    if (parts.length != 2) return null;

    const months = <String, int>{
      'Jan': 1,
      'Feb': 2,
      'Mar': 3,
      'Apr': 4,
      'May': 5,
      'Jun': 6,
      'Jul': 7,
      'Aug': 8,
      'Sep': 9,
      'Oct': 10,
      'Nov': 11,
      'Dec': 12,
    };

    final month = months[parts[0]];
    final day = int.tryParse(parts[1]);
    if (month == null || day == null) return null;
    return DateTime(DateTime.now().year, month, day);
  }

  Future<void> _pickDate() async {
    final year = DateTime.now().year;
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(year, 1, 1),
      lastDate: DateTime(year, 12, 31),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.dark(
            primary: AppColors.accent,
            surface: AppColors.surfaceHigh,
            onSurface: AppColors.text,
          ),
          dialogBackgroundColor: AppColors.surfaceHigh,
        ),
        child: child!,
      ),
    );

    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  String _headerLabel(DateTime date) {
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
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);
    final role = state.role;
    final dayEvents = state.events.where((e) {
      if (e.deleted) return false;
      final eventDate = _parseEventDate(e.date);
      return eventDate != null &&
          eventDate.year == _selectedDate.year &&
          eventDate.month == _selectedDate.month &&
          eventDate.day == _selectedDate.day;
    }).toList()
      ..sort((a, b) => a.time.compareTo(b.time));

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 2, 20, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Calendar', style: AppTextStyles.screenTitle()),
                  Text('Choose any date to see scheduled events',
                      style: AppTextStyles.caption()),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.calendar_today_outlined,
                              color: AppColors.accent, size: 14),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _headerLabel(_selectedDate),
                              style: AppTextStyles.body(13,
                                  weight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _pickDate,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.accent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Pick Date',
                        style: AppTextStyles.body(12,
                            color: AppColors.bg, weight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_headerLabel(_selectedDate).toUpperCase()} — ${dayEvents.length} EVENT${dayEvents.length == 1 ? '' : 'S'}',
                      style: AppTextStyles.label(),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: dayEvents.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.event_busy_outlined,
                                      color: AppColors.textMuted, size: 30),
                                  const SizedBox(height: 12),
                                  Text('No events on this date',
                                      style: AppTextStyles.body(12,
                                          color: AppColors.textDim)),
                                ],
                              ),
                            )
                          : ListView.builder(
                              itemCount: dayEvents.length,
                              itemBuilder: (_, i) {
                                final e = dayEvents[i];
                                final c = AppColors
                                    .postit[e.id % AppColors.postit.length];
                                return GestureDetector(
                                  onTap: () {
                                    state.selectEvent(e);
                                    Navigator.pushNamed(
                                        context, AppRoutes.eventDetail);
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color: AppColors.surface,
                                      borderRadius: BorderRadius.circular(8),
                                      border:
                                          Border.all(color: AppColors.border),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 3,
                                          height: 34,
                                          decoration: BoxDecoration(
                                            color: c.pin,
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
                                              Text(e.title,
                                                  style: AppTextStyles.body(13,
                                                      weight: FontWeight.w500)),
                                              const SizedBox(height: 3),
                                              Text('${e.time} · ${e.loc}',
                                                  style: AppTextStyles.caption(
                                                      size: 10)),
                                            ],
                                          ),
                                        ),
                                        Text(e.time,
                                            style: AppTextStyles.body(10,
                                                color: c.pin,
                                                weight: FontWeight.w600)),
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
            ),
            BottomNav(
                active: AppRoutes.calendar,
                role: role,
                onNav: (r) => Navigator.pushReplacementNamed(context, r)),
          ],
        ),
      ),
    );
  }
}
