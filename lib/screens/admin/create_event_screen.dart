import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/event_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/event_provider.dart';
import '../../utils/app_colors.dart';
import '../../utils/dummy_data.dart';
import '../../utils/routes.dart';
import '../../utils/text_styles.dart';
import '../../widgets/custom_text_field.dart';

class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({super.key});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _floorController = TextEditingController();
  final TextEditingController _roomController = TextEditingController();

  String _selectedCategory = 'Academic';
  String? _selectedLocation;
  TimeOfDay _selectedTime = const TimeOfDay(hour: 19, minute: 0);

  String _titleError = '';
  String _locationError = '';
  String _dateError = '';
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) {
      return;
    }

    final eventProvider = context.read<EventProvider>();
    final edit = eventProvider.editingEvent;
    if (edit != null) {
      _titleController.text = edit.title;
      _selectedLocation = findCampusLocation(edit.loc)?.label ??
          (kCampusLocations.contains(edit.loc) ? edit.loc : null);
      _descriptionController.text = edit.desc;
      _dateController.text = edit.date;
      _floorController.text = edit.floor == '—' ? '' : edit.floor;
      _roomController.text = edit.room == '—' ? '' : edit.room;
      final timeParts = edit.time.split(':');
      if (timeParts.length == 2) {
        final hour = int.tryParse(timeParts[0]);
        final minute = int.tryParse(timeParts[1]);
        if (hour != null && minute != null) {
          _selectedTime = TimeOfDay(hour: hour, minute: minute);
        }
      }
      _selectedCategory = edit.cat;
    }

    _initialized = true;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _dateController.dispose();
    _floorController.dispose();
    _roomController.dispose();
    super.dispose();
  }

  Future<void> _confirmDiscard() async {
    final shouldLeave = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surfaceHigh,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Text('Discard event?', style: AppTextStyles.heading(16)),
        content: Text(
          'Your unsaved changes will be lost. Are you sure you want to go back?',
          style: AppTextStyles.body(12, color: AppColors.textSec),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep Editing'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Discard',
              style: TextStyle(
                color: AppColors.danger,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    if (shouldLeave == true && mounted) {
      _goToAdminHome();
    }
  }

  void _goToAdminHome() {
    final eventProvider = context.read<EventProvider>();
    final authProvider = context.read<AuthProvider>();
    eventProvider.setEditingEvent(null);
    authProvider.updatePreferences(lastSelectedTab: 'my');
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.dashboard,
      (route) => false,
    );
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final initial = _parseSelectedDate() ?? DateTime(now.year, now.month, now.day);
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
            dialogTheme: DialogThemeData(
              backgroundColor: AppColors.surfaceHigh,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked == null) {
      return;
    }
    setState(() {
      _dateController.text = _formatDate(picked);
      _dateError = '';
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

    if (picked == null) {
      return;
    }
    setState(() {
      _selectedTime = picked;
      _dateError = '';
    });
  }

  DateTime? _parseSelectedDate() {
    final value = _dateController.text.trim();
    if (value.isEmpty) {
      return null;
    }
    final parts = value.split(' ');
    if (parts.length < 2) {
      return null;
    }
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
    if (month == null || day == null) {
      return null;
    }
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
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}';
  }

  String _formatTime(TimeOfDay time) {
    final hh = time.hour.toString().padLeft(2, '0');
    final mm = time.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }

  bool _validate() {
    final eventProvider = context.read<EventProvider>();
    final selectedDate = _parseSelectedDate();
    final today = eventProvider.referenceDate;

    setState(() {
      _titleError = _titleController.text.trim().isEmpty
          ? 'Event title is required.'
          : '';
      _locationError =
          (_selectedLocation == null || _selectedLocation!.trim().isEmpty)
              ? 'Location is required.'
              : '';
      if (_dateController.text.trim().isEmpty) {
        _dateError = 'Date is required.';
      } else if (selectedDate == null) {
        _dateError = 'Choose a valid date.';
      } else if (selectedDate.isBefore(today)) {
        _dateError = 'Past dates are not allowed.';
      } else {
        _dateError = '';
      }
    });

    return _titleError.isEmpty &&
        _locationError.isEmpty &&
        _dateError.isEmpty;
  }

  Future<void> _publish() async {
    if (!_validate()) {
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final eventProvider = context.read<EventProvider>();
    final edit = eventProvider.editingEvent;
    final isEdit = edit != null;
    final now = DateTime.now();

    final selectedLocation = _selectedLocation!.trim();
    final locationDetails = kCampusLocationDetails[selectedLocation] ??
        const {
          'building': 'Campus',
          'floor': '1',
          'room': 'Main Hall',
          'label': 'Campus',
        };

    final event = Event(
      id: edit?.id ?? now.microsecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      club: authProvider.currentClubName,
      clubId: authProvider.currentClubId,
      date: _dateController.text.trim(),
      time: _formatTime(_selectedTime),
      loc: locationDetails['label']!,
      cat: _selectedCategory,
      desc: _descriptionController.text.trim().isEmpty
          ? 'Event details will be announced soon.'
          : _descriptionController.text.trim(),
      building: locationDetails['building']!,
      floor: _floorController.text.trim().isEmpty
          ? '—'
          : _floorController.text.trim(),
      room: _roomController.text.trim().isEmpty
          ? '—'
          : _roomController.text.trim(),
      posterUrl: edit?.posterUrl,
      deleted: false,
      createdBy: edit?.createdBy ?? (authProvider.uid ?? ''),
      createdByEmail: edit?.createdByEmail ?? (authProvider.email ?? ''),
      createdAt: edit?.createdAt ?? now,
      updatedAt: now,
      savedBy: edit?.savedBy ?? const <String>[],
      attendingBy: edit?.attendingBy ?? const <String>[],
    );

    if (isEdit) {
      await eventProvider.updateEvent(event);
    } else {
      await eventProvider.createEvent(event);
    }

    if (!mounted) {
      return;
    }

    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surfaceHigh,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.successFaded,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.success.withOpacity(0.3),
                ),
              ),
              child: Icon(Icons.check, color: AppColors.success, size: 26),
            ),
            const SizedBox(height: 16),
            Text(
              isEdit ? 'Changes Saved!' : 'Event Published!',
              style: AppTextStyles.heading(20),
            ),
            const SizedBox(height: 8),
            Text(
              isEdit
                  ? '"${_titleController.text.trim()}" has been updated and is now live.'
                  : '"${_titleController.text.trim()}" is now live and visible to all students.',
              textAlign: TextAlign.center,
              style: AppTextStyles.body(
                13,
                color: AppColors.textSec,
              ).copyWith(height: 1.6),
            ),
          ],
        ),
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
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 12,
                ),
              ),
              child: Text(
                'Go to Board',
                style: AppTextStyles.body(
                  13,
                  color: AppColors.bg,
                  weight: FontWeight.w600,
                ),
              ),
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
    final eventProvider = context.watch<EventProvider>();
    final isEdit = eventProvider.editingEvent != null;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          _confirmDiscard();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.bg,
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 2, 20, 0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: _confirmDiscard,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Icon(
                          Icons.arrow_back,
                          color: AppColors.textSec,
                          size: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      isEdit ? 'Edit Event' : 'New Event',
                      style: AppTextStyles.heading(17),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        height: 96,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceAlt,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.image_outlined,
                              color: AppColors.textDim,
                              size: 22,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Upload event poster',
                              style: AppTextStyles.caption(size: 11),
                            ),
                            Text(
                              'PNG, JPG up to 10MB',
                              style: AppTextStyles.caption(
                                size: 10,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        label: 'Event Title',
                        placeholder: 'e.g. Spring Hackathon 2026',
                        controller: _titleController,
                        errorText:
                            _titleError.isEmpty ? null : _titleError,
                        onChanged: (_) => setState(() => _titleError = ''),
                      ),
                      const SizedBox(height: 12),
                      Text('CATEGORY', style: AppTextStyles.label()),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 5,
                        runSpacing: 5,
                        children:
                            kCategories.where((category) => category != 'All').map((category) {
                          final isActive = _selectedCategory == category;
                          return GestureDetector(
                            onTap: () => setState(() => _selectedCategory = category),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: isActive
                                    ? AppColors.accentFaded
                                    : AppColors.surfaceAlt,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: isActive
                                      ? AppColors.accent.withOpacity(0.5)
                                      : AppColors.border,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _catIcon(category),
                                    size: 11,
                                    color: isActive
                                        ? AppColors.accent
                                        : AppColors.textDim,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    category,
                                    style: AppTextStyles.body(
                                      11,
                                      color: isActive
                                          ? AppColors.accent
                                          : AppColors.textSec,
                                      weight: isActive
                                          ? FontWeight.w500
                                          : FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 12),
                      Text('DATE', style: AppTextStyles.label()),
                      const SizedBox(height: 5),
                      GestureDetector(
                        onTap: _pickDate,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceAlt,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: _dateError.isEmpty
                                  ? AppColors.border
                                  : AppColors.danger.withOpacity(0.55),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.calendar_today_outlined,
                                color: AppColors.accent,
                                size: 14,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _dateController.text.trim().isEmpty
                                      ? 'Choose a date'
                                      : _dateController.text.trim(),
                                  style: AppTextStyles.body(
                                    12,
                                    color: _dateController.text.trim().isEmpty
                                        ? AppColors.textDim
                                        : AppColors.text,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (_dateError.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          _dateError,
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.danger,
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
                            horizontal: 12,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceAlt,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.access_time_outlined,
                                color: AppColors.accent,
                                size: 14,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _formatTime(_selectedTime),
                                style: AppTextStyles.body(12),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text('LOCATION', style: AppTextStyles.label()),
                      const SizedBox(height: 5),
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.surfaceAlt,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _locationError.isEmpty
                                ? AppColors.border
                                : AppColors.danger.withOpacity(0.55),
                          ),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedLocation,
                            isExpanded: true,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            dropdownColor: AppColors.surfaceHigh,
                            hint: Text(
                              'Choose a campus location',
                              style: AppTextStyles.body(
                                12,
                                color: AppColors.textDim,
                              ),
                            ),
                            items: kCampusLocations.map((location) {
                              return DropdownMenuItem<String>(
                                value: location,
                                child: Text(
                                  location,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.body(12),
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedLocation = value;
                                _locationError = '';
                              });
                            },
                          ),
                        ),
                      ),
                      if (_locationError.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          _locationError,
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.danger,
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: CustomTextField(
                              label: 'Floor',
                              placeholder: 'Optional',
                              controller: _floorController,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: CustomTextField(
                              label: 'Room',
                              placeholder: 'Optional',
                              controller: _roomController,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      CustomTextField(
                        label: 'Description',
                        placeholder: 'Tell students what this event is about',
                        controller: _descriptionController,
                        maxLines: 5,
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _publish,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accent,
                            foregroundColor: AppColors.bg,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            isEdit ? 'Save Changes' : 'Publish Event',
                            style: AppTextStyles.body(
                              14,
                              color: AppColors.bg,
                              weight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
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
