import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../utils/text_styles.dart';
import '../../utils/routes.dart';
import '../../app_state.dart';

class EventDetailScreen extends StatefulWidget {
  const EventDetailScreen({super.key});
  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
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
    final state = AppStateProvider.of(context);
    final selected = state.selectedEvent;
    if (selected == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final event = state.liveEvent(selected.id) ?? selected;
    final isAdmin = state.role == 'admin';
    final isAttending = state.isAttending(event.id);
    final c = AppColors.postit[event.id % AppColors.postit.length];

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 2, 20, 0),
              child: Row(children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Icon(Icons.arrow_back,
                          color: AppColors.textSec, size: 16)),
                ),
                const Spacer(),
                if (!isAdmin)
                  GestureDetector(
                    onTap: () => state.toggleSave(event.id),
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: event.saved
                            ? AppColors.accentFaded
                            : AppColors.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: event.saved
                                ? AppColors.accent.withOpacity(0.4)
                                : AppColors.border),
                      ),
                      child: Icon(
                          event.saved ? Icons.bookmark : Icons.bookmark_border,
                          color: event.saved
                              ? AppColors.accent
                              : AppColors.textSec,
                          size: 15),
                    ),
                  ),
              ]),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Post-it header card
                    Container(
                      padding: const EdgeInsets.fromLTRB(18, 20, 18, 18),
                      decoration: BoxDecoration(
                          color: c.bg,
                          border: Border.all(color: c.border),
                          borderRadius: BorderRadius.circular(6)),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Positioned(
                              top: -23,
                              left: 20,
                              child: Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                      color: c.pin, shape: BoxShape.circle))),
                          Positioned(
                              top: -23,
                              right: 20,
                              child: Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                      color: c.pin, shape: BoxShape.circle))),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(children: [
                                Icon(_catIcon(event.cat),
                                    color: c.pin, size: 11),
                                const SizedBox(width: 5),
                                Text(event.cat.toUpperCase(),
                                    style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w600,
                                        color: c.pin,
                                        letterSpacing: 0.08)),
                                const Spacer(),
                                if (isAdmin)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                        color: AppColors.successFaded,
                                        borderRadius: BorderRadius.circular(4)),
                                    child: Text('Published',
                                        style: TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.success)),
                                  ),
                              ]),
                              const SizedBox(height: 12),
                              Text(event.title,
                                  style: AppTextStyles.heading(20).copyWith(
                                      color: c.cardText,
                                      fontWeight: FontWeight.w600,
                                      height: 1.2)),
                              const SizedBox(height: 4),
                              Text('by ${event.club}',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: c.pin,
                                      fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (event.posterUrl != null) ...[
                      GestureDetector(
                        onTap: () => showDialog(
                          context: context,
                          barrierColor: Colors.black.withOpacity(0.92),
                          builder: (_) => Dialog.fullscreen(
                            backgroundColor: AppColors.bg,
                            child: SafeArea(
                              child: Stack(
                                children: [
                                  Center(
                                    child: InteractiveViewer(
                                      minScale: 1,
                                      maxScale: 5,
                                      child:
                                          event.posterUrl!.startsWith('assets/')
                                              ? Image.asset(event.posterUrl!,
                                                  fit: BoxFit.contain)
                                              : Image.network(event.posterUrl!,
                                                  fit: BoxFit.contain),
                                    ),
                                  ),
                                  Positioned(
                                    top: 16,
                                    right: 16,
                                    child: GestureDetector(
                                      onTap: () => Navigator.pop(context),
                                      child: Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: AppColors.surface,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          border: Border.all(
                                              color: AppColors.border),
                                        ),
                                        child: const Icon(Icons.close,
                                            color: Colors.white, size: 18),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: AspectRatio(
                            aspectRatio: 16 / 9,
                            child: event.posterUrl!.startsWith('assets/')
                                ? Image.asset(
                                    event.posterUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(
                                      color: AppColors.surface,
                                      alignment: Alignment.center,
                                      child: Icon(Icons.image_outlined,
                                          color: c.pin, size: 24),
                                    ),
                                  )
                                : Image.network(
                                    event.posterUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(
                                      color: AppColors.surface,
                                      alignment: Alignment.center,
                                      child: Icon(Icons.image_outlined,
                                          color: c.pin, size: 24),
                                    ),
                                  ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    // Date / Time / RSVP chips
                    Row(children: [
                      for (final x in [
                        {'label': 'DATE', 'val': event.date},
                        {'label': 'TIME', 'val': event.time},
                        {'label': 'RSVP', 'val': '${event.rsvp}'},
                      ])
                        Expanded(
                          child: Container(
                            margin: x['label'] == 'DATE'
                                ? const EdgeInsets.only(right: 4)
                                : x['label'] == 'TIME'
                                    ? const EdgeInsets.symmetric(horizontal: 4)
                                    : const EdgeInsets.only(left: 4),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppColors.border)),
                            child: Column(children: [
                              Text(x['label']!,
                                  style: TextStyle(
                                      fontSize: 8,
                                      color: AppColors.textDim,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.08)),
                              const SizedBox(height: 4),
                              Text(x['val']!,
                                  style: AppTextStyles.body(14,
                                      weight: FontWeight.w600)),
                            ]),
                          ),
                        ),
                    ]),
                    const SizedBox(height: 10),
                    // Location
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.border)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(spacing: 6, runSpacing: 6, children: [
                            for (final x in [
                              {'l': 'Location', 'v': event.loc},
                              {'l': 'Floor', 'v': event.floor},
                              {'l': 'Room', 'v': event.room}
                            ])
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 9, vertical: 4),
                                decoration: BoxDecoration(
                                    color: AppColors.surfaceAlt,
                                    borderRadius: BorderRadius.circular(5),
                                    border:
                                        Border.all(color: AppColors.border)),
                                child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text('${x['l']} ',
                                          style:
                                              AppTextStyles.caption(size: 9)),
                                      Text(x['v']!,
                                          style: AppTextStyles.body(11)),
                                    ]),
                              ),
                          ]),
                          const SizedBox(height: 10),
                          GestureDetector(
                            onTap: () =>
                                Navigator.pushNamed(context, AppRoutes.map),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 9),
                              decoration: BoxDecoration(
                                  color: AppColors.surfaceAlt,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: AppColors.border)),
                              child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.location_on_outlined,
                                        color: AppColors.accent, size: 13),
                                    const SizedBox(width: 6),
                                    Text('View on map',
                                        style: AppTextStyles.body(12,
                                            color: AppColors.textSec,
                                            weight: FontWeight.w500)),
                                  ]),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    // About
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.border)),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('ABOUT', style: AppTextStyles.label()),
                            const SizedBox(height: 8),
                            Text(event.desc,
                                style: AppTextStyles.body(13,
                                        color: AppColors.text)
                                    .copyWith(
                                        height: 1.65, letterSpacing: -0.01)),
                          ]),
                    ),
                    const SizedBox(height: 14),
                    // Action buttons (student only)
                    if (!isAdmin)
                      Row(children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => state.toggleSave(event.id),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 13),
                              decoration: BoxDecoration(
                                color: event.saved
                                    ? AppColors.accentFaded
                                    : AppColors.surface,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                    color: event.saved
                                        ? AppColors.accent.withOpacity(0.4)
                                        : AppColors.border),
                              ),
                              child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                        event.saved
                                            ? Icons.bookmark
                                            : Icons.bookmark_border,
                                        color: event.saved
                                            ? AppColors.accent
                                            : AppColors.textSec,
                                        size: 13),
                                    const SizedBox(width: 5),
                                    Text(event.saved ? 'Saved' : 'Save',
                                        style: AppTextStyles.body(13,
                                            color: event.saved
                                                ? AppColors.accent
                                                : AppColors.textSec,
                                            weight: FontWeight.w500)),
                                  ]),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 2,
                          child: GestureDetector(
                            onTap: () => state.toggleAttendance(event.id),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(vertical: 13),
                              decoration: BoxDecoration(
                                color: isAttending
                                    ? AppColors.successFaded
                                    : AppColors.accent,
                                borderRadius: BorderRadius.circular(8),
                                border: isAttending
                                    ? Border.all(
                                        color:
                                            AppColors.success.withOpacity(0.4))
                                    : null,
                              ),
                              child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    if (isAttending) ...[
                                      Icon(Icons.check,
                                          color: AppColors.success, size: 13),
                                      const SizedBox(width: 5)
                                    ],
                                    Text(
                                        isAttending
                                            ? 'Attending'
                                            : 'Confirm Attendance',
                                        style: AppTextStyles.body(13,
                                            color: isAttending
                                                ? AppColors.success
                                                : AppColors.bg,
                                            weight: FontWeight.w600)),
                                  ]),
                            ),
                          ),
                        ),
                      ]),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
