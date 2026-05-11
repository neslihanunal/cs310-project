import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
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
  Map<String, bool> _categories = {
    'Academic': true,
    'Social': true,
    'Sports': false,
    'Career': true,
    'Arts': false,
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
    if (_initialized) {
      return;
    }
    final authProvider = context.read<AuthProvider>();
    _categories = {
      for (final category in ['Academic', 'Social', 'Sports', 'Career', 'Arts'])
        category: authProvider.preferredCategories.contains(category),
    };
    _reminder = authProvider.reminderLeadMinutes.toString();
    _layout = authProvider.dashboardLayout;
    _initialized = true;
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            CustomAppBar(
              onBack: () => Navigator.pop(context),
              title: 'Event Preferences',
              subtitle: 'Personalise your board experience',
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  Text(
                    'DEFAULT CATEGORIES SHOWN',
                    style: AppTextStyles.label(),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      children: _categories.entries
                          .toList()
                          .asMap()
                          .entries
                          .map((entry) {
                        final index = entry.key;
                        final item = entry.value;
                        final enabled = item.value;
                        return GestureDetector(
                          onTap: () => setState(() {
                            _categories[item.key] = !enabled;
                            _saved = false;
                          }),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              border: index < _categories.length - 1
                                  ? Border(
                                      bottom: BorderSide(
                                        color: AppColors.borderLight,
                                      ),
                                    )
                                  : null,
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    color: enabled
                                        ? AppColors.accentFaded
                                        : AppColors.surfaceAlt,
                                    borderRadius: BorderRadius.circular(7),
                                    border: Border.all(
                                      color: enabled
                                          ? AppColors.accent.withOpacity(0.3)
                                          : AppColors.border,
                                    ),
                                  ),
                                  child: Icon(
                                    _catIcon(item.key),
                                    color: enabled
                                        ? AppColors.accent
                                        : AppColors.textDim,
                                    size: 13,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    item.key,
                                    style: AppTextStyles.body(
                                      13,
                                      color: enabled
                                          ? AppColors.text
                                          : AppColors.textDim,
                                    ),
                                  ),
                                ),
                                CustomToggle(
                                  value: enabled,
                                  onTap: () => setState(() {
                                    _categories[item.key] = !enabled;
                                    _saved = false;
                                  }),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('REMINDER TIMING', style: AppTextStyles.label()),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      for (final option in [
                        ('15', '15 min'),
                        ('30', '30 min'),
                        ('60', '1 hour'),
                        ('1440', '1 day'),
                      ])
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() {
                              _reminder = option.$1;
                              _saved = false;
                            }),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              margin: const EdgeInsets.symmetric(horizontal: 3),
                              padding: const EdgeInsets.symmetric(vertical: 9),
                              decoration: BoxDecoration(
                                color: _reminder == option.$1
                                    ? AppColors.accentFaded
                                    : AppColors.surfaceAlt,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: _reminder == option.$1
                                      ? AppColors.accent.withOpacity(0.5)
                                      : AppColors.border,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  option.$2,
                                  style: AppTextStyles.body(
                                    11,
                                    color: _reminder == option.$1
                                        ? AppColors.accent
                                        : AppColors.textSec,
                                    weight: _reminder == option.$1
                                        ? FontWeight.w500
                                        : FontWeight.w400,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text('BOARD LAYOUT', style: AppTextStyles.label()),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      for (final option in [
                        ('board', 'Post-it Board', 'Visual grid'),
                        ('list', 'List View', 'Compact rows'),
                      ])
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() {
                              _layout = option.$1;
                              _saved = false;
                            }),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              margin: const EdgeInsets.symmetric(horizontal: 3),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: _layout == option.$1
                                    ? AppColors.accentFaded
                                    : AppColors.surface,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: _layout == option.$1
                                      ? AppColors.accent.withOpacity(0.5)
                                      : AppColors.border,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    option.$2,
                                    style: AppTextStyles.body(
                                      12,
                                      color: _layout == option.$1
                                          ? AppColors.accent
                                          : AppColors.text,
                                      weight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    option.$3,
                                    style: AppTextStyles.caption(size: 10),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _saved
                      ? Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.successFaded,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppColors.success.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.check,
                                color: AppColors.success,
                                size: 14,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Preferences saved',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.success,
                                ),
                              ),
                            ],
                          ),
                        )
                      : SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () async {
                              await authProvider.updatePreferences(
                                categories: _categories.entries
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
                              padding: const EdgeInsets.symmetric(vertical: 13),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              'Save Preferences',
                              style: AppTextStyles.body(
                                13,
                                color: AppColors.bg,
                                weight: FontWeight.w600,
                              ),
                            ),
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
