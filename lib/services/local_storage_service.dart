import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/event_model.dart';
import '../models/user_model.dart';

class LocalStorageService {
  static const String _dashboardLayoutKey = 'dashboard_layout';
  static const String _reminderLeadMinutesKey = 'reminder_lead_minutes';
  static const String _preferredCategoriesKey = 'preferred_categories';
  static const String _lastSelectedTabKey = 'last_selected_tab';
  static const String _cachedUsersKey = 'cached_users';
  static const String _cachedEventsKey = 'cached_events';

  final SharedPreferences _prefs;

  LocalStorageService._(this._prefs);

  static Future<LocalStorageService> create() async {
    final prefs = await SharedPreferences.getInstance();
    return LocalStorageService._(prefs);
  }

  String get dashboardLayout => _prefs.getString(_dashboardLayoutKey) ?? 'board';

  Future<void> saveDashboardLayout(String value) {
    return _prefs.setString(_dashboardLayoutKey, value);
  }

  int get reminderLeadMinutes => _prefs.getInt(_reminderLeadMinutesKey) ?? 30;

  Future<void> saveReminderLeadMinutes(int value) {
    return _prefs.setInt(_reminderLeadMinutesKey, value);
  }

  List<String> get preferredCategories {
    final stored = _prefs.getStringList(_preferredCategoriesKey);
    if (stored == null || stored.isEmpty) {
      return const <String>['Academic', 'Social', 'Sports', 'Career', 'Arts'];
    }
    return stored;
  }

  Future<void> savePreferredCategories(List<String> values) {
    return _prefs.setStringList(_preferredCategoriesKey, values);
  }

  String get lastSelectedTab => _prefs.getString(_lastSelectedTabKey) ?? 'all';

  Future<void> saveLastSelectedTab(String value) {
    return _prefs.setString(_lastSelectedTabKey, value);
  }

  Map<String, AppUser> get cachedUsers {
    final raw = _prefs.getString(_cachedUsersKey);
    if (raw == null || raw.isEmpty) {
      return <String, AppUser>{};
    }
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    return decoded.map((key, value) {
      return MapEntry(
        key,
        AppUser.fromJson(Map<String, dynamic>.from(value as Map)),
      );
    });
  }

  Future<void> saveCachedUsers(Map<String, AppUser> users) async {
    final encoded = users.map((key, value) => MapEntry(key, value.toJson()));
    await _prefs.setString(_cachedUsersKey, jsonEncode(encoded));
  }

  List<Event> get cachedEvents {
    final raw = _prefs.getString(_cachedEventsKey);
    if (raw == null || raw.isEmpty) {
      return <Event>[];
    }
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((item) => Event.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();
  }

  Future<void> saveCachedEvents(List<Event> events) async {
    final payload = events.map((event) => event.toJson()).toList();
    await _prefs.setString(_cachedEventsKey, jsonEncode(payload));
  }
}
