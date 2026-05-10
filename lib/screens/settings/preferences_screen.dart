import 'package:flutter/material.dart';
import '../../app_state.dart';
import '../../utils/app_colors.dart';
import '../../utils/text_styles.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_toggle.dart';

class PreferencesScreen extends StatefulWidget {
  const PreferencesScreen({super.key});
  @override
  State<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen> {
  Map<String, bool> _cats = {
    'Academic': true,
    'Social': true,
    'Sports': false,
    'Career': true,
    'Arts': false
  };
  String _reminder = '30';
  String _layout = 'board';
  bool _saved = false;
  bool _initialized = false;

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
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    final state = AppStateProvider.of(context);
    _cats = {
      for (final category in ['Academic', 'Social', 'Sports', 'Career', 'Arts'])
        category: state.preferredCategories.contains(category),
    };
    _reminder = state.reminderLeadMinutes.toString();
    _layout = state.dashboardLayout;
    _initialized = true;
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            CustomAppBar(
                onBack: () => Navigator.pop(context),
                title: 'Event Preferences',
                subtitle: 'Personalise your board experience'),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  // Categories
                  Text('DEFAULT CATEGORIES SHOWN',
                      style: AppTextStyles.label()),
                  const SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border)),
                    child: Column(
                      children:
                          _cats.entries.toList().asMap().entries.map((entry) {
                        final i = entry.key;
                        final kv = entry.value;
                        final on = kv.value;
                        return GestureDetector(
                          onTap: () => setState(() {
                            _cats[kv.key] = !on;
                            _saved = false;
                          }),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                                border: i < _cats.length - 1
                                    ? Border(
                                        bottom: BorderSide(
                                            color: AppColors.borderLight))
                                    : null),
                            child: Row(children: [
                              Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                    color: on
                                        ? AppColors.accentFaded
                                        : AppColors.surfaceAlt,
                                    borderRadius: BorderRadius.circular(7),
                                    border: Border.all(
                                        color: on
                                            ? AppColors.accent.withOpacity(0.3)
                                            : AppColors.border)),
                                child: Icon(_catIcon(kv.key),
                                    color: on
                                        ? AppColors.accent
                                        : AppColors.textDim,
                                    size: 13),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                  child: Text(kv.key,
                                      style: AppTextStyles.body(13,
                                          color: on
                                              ? AppColors.text
                                              : AppColors.textDim))),
                              CustomToggle(
                                  value: on,
                                  onTap: () => setState(() {
                                        _cats[kv.key] = !on;
                                        _saved = false;
                                      })),
                            ]),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Reminder timing
                  Text('REMINDER TIMING', style: AppTextStyles.label()),
                  const SizedBox(height: 10),
                  Row(children: [
                    for (final opt in [
                      ('15', '15 min'),
                      ('30', '30 min'),
                      ('60', '1 hour'),
                      ('1440', '1 day')
                    ])
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() {
                            _reminder = opt.$1;
                            _saved = false;
                          }),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            padding: const EdgeInsets.symmetric(vertical: 9),
                            decoration: BoxDecoration(
                              color: _reminder == opt.$1
                                  ? AppColors.accentFaded
                                  : AppColors.surfaceAlt,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: _reminder == opt.$1
                                      ? AppColors.accent.withOpacity(0.5)
                                      : AppColors.border),
                            ),
                            child: Center(
                                child: Text(opt.$2,
                                    style: AppTextStyles.body(11,
                                        color: _reminder == opt.$1
                                            ? AppColors.accent
                                            : AppColors.textSec,
                                        weight: _reminder == opt.$1
                                            ? FontWeight.w500
                                            : FontWeight.w400))),
                          ),
                        ),
                      ),
                  ]),
                  const SizedBox(height: 16),
                  // Board layout
                  Text('BOARD LAYOUT', style: AppTextStyles.label()),
                  const SizedBox(height: 10),
                  Row(children: [
                    for (final opt in [
                      ('board', 'Post-it Board', 'Visual grid'),
                      ('list', 'List View', 'Compact rows')
                    ])
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() {
                            _layout = opt.$1;
                            _saved = false;
                          }),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: _layout == opt.$1
                                  ? AppColors.accentFaded
                                  : AppColors.surface,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: _layout == opt.$1
                                      ? AppColors.accent.withOpacity(0.5)
                                      : AppColors.border),
                            ),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(opt.$2,
                                      style: AppTextStyles.body(12,
                                          color: _layout == opt.$1
                                              ? AppColors.accent
                                              : AppColors.text,
                                          weight: FontWeight.w500)),
                                  const SizedBox(height: 2),
                                  Text(opt.$3,
                                      style: AppTextStyles.caption(size: 10)),
                                ]),
                          ),
                        ),
                      ),
                  ]),
                  const SizedBox(height: 20),
                  _saved
                      ? Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                              color: AppColors.successFaded,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: AppColors.success.withOpacity(0.3))),
                          child: Row(children: [
                            Icon(Icons.check,
                                color: AppColors.success, size: 14),
                            const SizedBox(width: 8),
                            Text('Preferences saved',
                                style: TextStyle(
                                    fontSize: 12, color: AppColors.success))
                          ]),
                        )
                      : SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              state.updatePreferences(
                                categories: _cats.entries
                                    .where((entry) => entry.value)
                                    .map((entry) => entry.key)
                                    .toSet(),
                                layout: _layout,
                                reminderMinutes: int.tryParse(_reminder) ?? 30,
                              );
                              setState(() => _saved = true);
                            },
                            style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.accent,
                                foregroundColor: AppColors.bg,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 13),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)),
                                elevation: 0),
                            child: Text('Save Preferences',
                                style: AppTextStyles.body(13,
                                    color: AppColors.bg,
                                    weight: FontWeight.w600)),
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
