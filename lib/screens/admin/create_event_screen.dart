import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../utils/text_styles.dart';
import '../../utils/dummy_data.dart';
import '../../widgets/custom_text_field.dart';
import '../../app_state.dart';
import '../../models/event_model.dart';
import '../../utils/routes.dart';

class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({super.key});
  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

extension _StringNullX on String {
  String? ifEmptyToNull() => trim().isEmpty ? null : this;
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _dateCtrl = TextEditingController();
  final _floorCtrl = TextEditingController();
  final _roomCtrl = TextEditingController();

  void _confirmDiscard() async {
    final shouldLeave = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surfaceHigh,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Text('Discard event?', style: AppTextStyles.heading(16)),
        content: Text(
            'Your unsaved changes will be lost. Are you sure you want to go back?',
            style: AppTextStyles.body(12, color: AppColors.textSec)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Keep Editing')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text('Discard',
                  style: TextStyle(
                      color: AppColors.danger, fontWeight: FontWeight.w600))),
        ],
      ),
    );
    if (shouldLeave == true && mounted) {
      _goToAdminHome();
    }
  }

  void _goToAdminHome() {
    if (!mounted) return;
    final state = AppStateProvider.of(context);
    state.setEditingEvent(null);
    state.setAdminDashboardTab('my');
    Navigator.pushNamedAndRemoveUntil(
        context, AppRoutes.dashboard, (route) => false);
  }

  String _selCat = 'Academic';
  String? _selectedLocation;
  TimeOfDay _selectedTime = const TimeOfDay(hour: 19, minute: 0);

  // Validation errors
  String _titleErr = '';
  String _locErr = '';
  String _dateErr = '';

  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final state = AppStateProvider.of(context);
      final edit = state.editingEvent;
      if (edit != null) {
        _titleCtrl.text = edit.title;
        _selectedLocation = kCampusLocations.contains(edit.loc)
            ? edit.loc
            : kCampusLocationDetails.entries
                .firstWhere(
                  (entry) => entry.value['label'] == edit.loc,
                  orElse: () => const MapEntry('', {}),
                )
                .key
                .ifEmptyToNull();
        _descCtrl.text = edit.desc;
        _dateCtrl.text = edit.date;
        _floorCtrl.text = edit.floor == '—' ? '' : edit.floor;
        _roomCtrl.text = edit.room == '—' ? '' : edit.room;
        final timeParts = edit.time.split(':');
        if (timeParts.length == 2) {
          final h = int.tryParse(timeParts[0]);
          final m = int.tryParse(timeParts[1]);
          if (h != null && m != null) {
            _selectedTime = TimeOfDay(hour: h, minute: m);
          }
        }
        _selCat = edit.cat;
      }
      _initialized = true;
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _dateCtrl.dispose();
    _floorCtrl.dispose();
    _roomCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final initial =
        _parseSelectedDate() ?? DateTime(now.year, now.month, now.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(now.year + 3, 12, 31),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppColors.accent,
              onPrimary: AppColors.bg,
              surface: AppColors.surfaceHigh,
              onSurface: AppColors.text,
            ),
            dialogTheme:
                DialogThemeData(backgroundColor: AppColors.surfaceHigh),
          ),
          child: child!,
        );
      },
    );
    if (picked == null) return;
    setState(() {
      _dateCtrl.text = _formatDate(picked);
      _dateErr = '';
    });
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppColors.accent,
              onPrimary: AppColors.bg,
              surface: AppColors.surfaceHigh,
              onSurface: AppColors.text,
            ),
            timePickerTheme: TimePickerThemeData(
              backgroundColor: AppColors.surfaceHigh,
              hourMinuteColor: AppColors.surfaceAlt,
              dayPeriodColor: AppColors.surfaceAlt,
              dialBackgroundColor: AppColors.surfaceAlt,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked == null) return;
    setState(() {
      _selectedTime = picked;
      _dateErr = '';
    });
  }

  DateTime? _parseSelectedDate() {
    final value = _dateCtrl.text.trim();
    if (value.isEmpty) return null;
    final parts = value.split(' ');
    if (parts.length < 2) return null;
    const months = {
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
    final now = DateTime.now();
    return DateTime(now.year, month, day);
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}';
  }

  String _formatTime(TimeOfDay time) {
    final hh = time.hour.toString().padLeft(2, '0');
    final mm = time.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }

  bool _validate() {
    bool ok = true;
    final selectedDate = _parseSelectedDate();
    final state = AppStateProvider.of(context);
    final today = state.referenceDate;
    setState(() {
      _titleErr =
          _titleCtrl.text.trim().isEmpty ? 'Event title is required.' : '';
      _locErr = (_selectedLocation == null || _selectedLocation!.trim().isEmpty)
          ? 'Location is required.'
          : '';
      if (_dateCtrl.text.trim().isEmpty) {
        _dateErr = 'Date is required.';
      } else if (selectedDate == null) {
        _dateErr = 'Choose a valid date.';
      } else if (selectedDate.isBefore(today)) {
        _dateErr = 'Past dates are not allowed.';
      } else {
        _dateErr = '';
      }
    });
    if (_titleErr.isNotEmpty || _locErr.isNotEmpty || _dateErr.isNotEmpty) {
      ok = false;
    }
    return ok;
  }

  void _publish() {
    if (!_validate()) return;
    final state = AppStateProvider.of(context);
    final edit = state.editingEvent;
    final isEdit = edit != null;

    final String date = _dateCtrl.text.trim();
    final String time = _formatTime(_selectedTime);

    final selectedLocation = _selectedLocation!.trim();
    final locationDetails = kCampusLocationDetails[selectedLocation] ??
        const {
          'building': 'Campus',
          'floor': '1',
          'room': 'Main Hall',
          'label': 'Campus',
        };
    final building = locationDetails['building']!;
    final floor = _floorCtrl.text.trim().isEmpty ? '—' : _floorCtrl.text.trim();
    final room = _roomCtrl.text.trim().isEmpty ? '—' : _roomCtrl.text.trim();
    final locationLabel = locationDetails['label']!;

    final event = Event(
      id: edit?.id ?? DateTime.now().millisecondsSinceEpoch,
      title: _titleCtrl.text.trim(),
      club: state.currentClubName,
      clubId: state.currentClubId,
      date: date,
      time: time,
      loc: locationLabel,
      cat: _selCat,
      desc: _descCtrl.text.trim().isEmpty
          ? 'Event details will be announced soon.'
          : _descCtrl.text.trim(),
      rsvp: edit?.rsvp ?? 0,
      saved: edit?.saved ?? false,
      building: building,
      floor: floor,
      room: room,
      posterUrl: edit?.posterUrl,
    );
    state.addOrUpdateEvent(event);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surfaceHigh,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
                color: AppColors.successFaded,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.success.withOpacity(0.3))),
            child: Icon(Icons.check, color: AppColors.success, size: 26),
          ),
          const SizedBox(height: 16),
          Text(isEdit ? 'Changes Saved!' : 'Event Published!',
              style: AppTextStyles.heading(20)),
          const SizedBox(height: 8),
          Text(
            isEdit
                ? '"${_titleCtrl.text.trim()}" has been updated and is now live.'
                : '"${_titleCtrl.text.trim()}" is now live and visible to all students.',
            textAlign: TextAlign.center,
            style: AppTextStyles.body(13, color: AppColors.textSec)
                .copyWith(height: 1.6),
          ),
        ]),
        actions: [
          Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _goToAdminHome();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: AppColors.bg,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                elevation: 0,
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
              ),
              child: Text('Go to Board',
                  style: AppTextStyles.body(13,
                      color: AppColors.bg, weight: FontWeight.w600)),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

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
    final isEdit = state.editingEvent != null;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _confirmDiscard();
      },
      child: Scaffold(
        backgroundColor: AppColors.bg,
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 2, 20, 0),
                child: Row(children: [
                  GestureDetector(
                    onTap: _confirmDiscard,
                    child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Icon(Icons.arrow_back,
                            color: AppColors.textSec, size: 16)),
                  ),
                  const SizedBox(width: 10),
                  Text(isEdit ? 'Edit Event' : 'New Event',
                      style: AppTextStyles.heading(17)),
                ]),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Poster upload placeholder (asset image)
                      Container(
                        width: double.infinity,
                        height: 96,
                        decoration: BoxDecoration(
                            color: AppColors.surfaceAlt,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: AppColors.border,
                                style: BorderStyle.solid)),
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.image_outlined,
                                  color: AppColors.textDim, size: 22),
                              const SizedBox(height: 6),
                              Text('Upload event poster',
                                  style: AppTextStyles.caption(size: 11)),
                              Text('PNG, JPG up to 10MB',
                                  style: AppTextStyles.caption(
                                      size: 10, color: AppColors.textMuted)),
                            ]),
                      ),
                      const SizedBox(height: 16),
                      // Title
                      CustomTextField(
                          label: 'Event Title',
                          placeholder: 'e.g. Spring Hackathon 2026',
                          controller: _titleCtrl,
                          errorText: _titleErr.isEmpty ? null : _titleErr,
                          onChanged: (_) => setState(() => _titleErr = '')),
                      const SizedBox(height: 12),
                      // Category
                      Text('CATEGORY', style: AppTextStyles.label()),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 5,
                        runSpacing: 5,
                        children:
                            kCategories.where((c) => c != 'All').map((cat) {
                          final act = _selCat == cat;
                          return GestureDetector(
                            onTap: () => setState(() => _selCat = cat),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: act
                                    ? AppColors.accentFaded
                                    : AppColors.surfaceAlt,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                    color: act
                                        ? AppColors.accent.withOpacity(0.5)
                                        : AppColors.border),
                              ),
                              child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(_catIcon(cat),
                                        size: 11,
                                        color: act
                                            ? AppColors.accent
                                            : AppColors.textDim),
                                    const SizedBox(width: 4),
                                    Text(cat,
                                        style: AppTextStyles.body(11,
                                            color: act
                                                ? AppColors.accent
                                                : AppColors.textSec,
                                            weight: act
                                                ? FontWeight.w500
                                                : FontWeight.w400)),
                                  ]),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 12),
                      // Date and Time
                      Text('DATE', style: AppTextStyles.label()),
                      const SizedBox(height: 5),
                      GestureDetector(
                        onTap: _pickDate,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 12),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceAlt,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: _dateErr.isEmpty
                                  ? AppColors.border
                                  : AppColors.danger.withOpacity(0.55),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.calendar_today_outlined,
                                  color: AppColors.accent, size: 14),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _dateCtrl.text.trim().isEmpty
                                      ? 'Choose a date'
                                      : _dateCtrl.text.trim(),
                                  style: AppTextStyles.body(
                                    12,
                                    color: _dateCtrl.text.trim().isEmpty
                                        ? AppColors.textMuted
                                        : AppColors.text,
                                  ),
                                ),
                              ),
                              Icon(Icons.keyboard_arrow_down_rounded,
                                  color: AppColors.textSec, size: 18),
                            ],
                          ),
                        ),
                      ),
                      if (_dateErr.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Padding(
                          padding: const EdgeInsets.only(left: 4),
                          child: Text(
                            _dateErr,
                            style: TextStyle(
                                color: AppColors.danger, fontSize: 10),
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                      Text('TIME', style: AppTextStyles.label()),
                      const SizedBox(height: 5),
                      GestureDetector(
                        onTap: _pickTime,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 12),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceAlt,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.access_time_outlined,
                                  color: AppColors.accent, size: 14),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _formatTime(_selectedTime),
                                  style: AppTextStyles.body(12,
                                      color: AppColors.text),
                                ),
                              ),
                              Icon(Icons.keyboard_arrow_down_rounded,
                                  color: AppColors.textSec, size: 18),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Location
                      Text('LOCATION / BUILDING', style: AppTextStyles.label()),
                      const SizedBox(height: 5),
                      DropdownButtonFormField<String>(
                        value: _selectedLocation,
                        isExpanded: true,
                        dropdownColor: AppColors.surfaceHigh,
                        icon: Icon(Icons.keyboard_arrow_down_rounded,
                            color: AppColors.textSec, size: 18),
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.location_on_outlined,
                              color: AppColors.accent, size: 14),
                          hintText: 'Select campus location',
                          hintStyle: AppTextStyles.body(12,
                              color: AppColors.textMuted),
                          filled: true,
                          fillColor: AppColors.surfaceAlt,
                          errorText: _locErr.isEmpty ? null : _locErr,
                          errorStyle:
                              TextStyle(color: AppColors.danger, fontSize: 10),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 12),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: AppColors.border),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                                color: AppColors.accent.withOpacity(0.55)),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                                color: AppColors.danger.withOpacity(0.55)),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                                color: AppColors.danger.withOpacity(0.7)),
                          ),
                        ),
                        style: AppTextStyles.body(12, color: AppColors.text),
                        items: kCampusLocations
                            .map(
                              (location) => DropdownMenuItem<String>(
                                value: location,
                                child: Text(location,
                                    overflow: TextOverflow.ellipsis),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedLocation = value;
                            _locErr = '';
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: CustomTextField(
                              label: 'Floor',
                              placeholder: 'Optional, e.g. 2',
                              controller: _floorCtrl,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: CustomTextField(
                              label: 'Room',
                              placeholder: 'Optional, e.g. A204',
                              controller: _roomCtrl,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Description
                      Text('DESCRIPTION', style: AppTextStyles.label()),
                      const SizedBox(height: 5),
                      CustomTextField(
                          placeholder: 'Describe your event…',
                          controller: _descCtrl,
                          maxLines: 4),
                      const SizedBox(height: 16),
                      Row(children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _confirmDiscard,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.textSec,
                              side: BorderSide(color: AppColors.border),
                              padding: const EdgeInsets.symmetric(vertical: 13),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                            child: Text('Discard',
                                style: AppTextStyles.body(13,
                                    color: AppColors.textSec)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: _publish,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.accent,
                              foregroundColor: AppColors.bg,
                              padding: const EdgeInsets.symmetric(vertical: 13),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                              elevation: 0,
                            ),
                            child: Text(
                                isEdit ? 'Save Changes' : 'Publish Event',
                                style: AppTextStyles.body(13,
                                    color: AppColors.bg,
                                    weight: FontWeight.w600)),
                          ),
                        ),
                      ]),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
