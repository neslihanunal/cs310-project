import 'package:flutter/material.dart';
import 'models/event_model.dart';
import 'models/user_model.dart';
import 'utils/dummy_data.dart';

class AppState extends ChangeNotifier {
  User? account;
  String? userEmail;
  final Map<String, User> _profilesByEmail = <String, User>{};
  List<Event> events = buildEventList();
  Event? selectedEvent;
  Event? editingEvent;
  final Set<int> attendingEventIds = <int>{};
  String adminDashboardTab = 'all';
  Set<String> preferredCategories = {
    'Academic',
    'Social',
    'Sports',
    'Career',
    'Arts',
  };
  String dashboardLayout = 'board';
  int reminderLeadMinutes = 30;

  String get role => account?.role ?? 'student';
  String get currentClubName {
    final clubName = account?.clubName?.trim();
    if (clubName != null && clubName.isNotEmpty) {
      return clubName;
    }
    return 'Campus Club';
  }

  String get currentClubId {
    final email = userEmail?.trim().toLowerCase();
    if (email != null && email.contains('@')) {
      return email.split('@').first.replaceAll(RegExp(r'[^a-z0-9]+'), '');
    }
    return currentClubName.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '');
  }

  String get reminderLabel {
    return switch (reminderLeadMinutes) {
      15 => '15 min',
      30 => '30 min',
      60 => '1 hour',
      1440 => '1 day',
      _ => '$reminderLeadMinutes min',
    };
  }

  DateTime get referenceDate {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  DateTime? parseEventDate(String value) {
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

  bool isPastEvent(Event event) {
    final eventDate = parseEventDate(event.date);
    if (eventDate == null) return false;
    final ref =
        DateTime(referenceDate.year, referenceDate.month, referenceDate.day);
    return eventDate.isBefore(ref);
  }

  bool isActiveEvent(Event event) => !event.deleted && !isPastEvent(event);

  bool isVisibleToStudents(Event event) => isActiveEvent(event);

  List<Event> eventsForRole(String role) {
    return events.where(isActiveEvent).toList();
  }

  User? profileForEmail(String email) => _profilesByEmail[email.toLowerCase()];

  void setAccount(User user, {String? email}) {
    account = user;
    if (email != null) {
      userEmail = email;
      _profilesByEmail[email.toLowerCase()] = user;
    } else if (userEmail != null) {
      _profilesByEmail[userEmail!.toLowerCase()] = user;
    }
    notifyListeners();
  }

  void updateAccount(User user) {
    account = user;
    if (userEmail != null) {
      _profilesByEmail[userEmail!.toLowerCase()] = user;
    }
    notifyListeners();
  }

  void logout() {
    account = null;
    userEmail = null;
    selectedEvent = null;
    editingEvent = null;
    adminDashboardTab = 'all';
    notifyListeners();
  }

  void setAdminDashboardTab(String tab) {
    adminDashboardTab = tab;
    notifyListeners();
  }

  void updatePreferences({
    Set<String>? categories,
    String? layout,
    int? reminderMinutes,
  }) {
    if (categories != null) {
      preferredCategories = categories;
    }
    if (layout != null) {
      dashboardLayout = layout;
    }
    if (reminderMinutes != null) {
      reminderLeadMinutes = reminderMinutes;
    }
    notifyListeners();
  }

  void toggleSave(int id) {
    events = events
        .map((e) => e.id == id ? e.copyWith(saved: !e.saved) : e)
        .toList();
    if (selectedEvent?.id == id) {
      selectedEvent = selectedEvent!.copyWith(saved: !selectedEvent!.saved);
    }
    notifyListeners();
  }

  void toggleAttendance(int id) {
    final isAttending = attendingEventIds.contains(id);
    if (isAttending) {
      attendingEventIds.remove(id);
      events = events
          .map((e) => e.id == id ? e.copyWith(rsvp: e.rsvp - 1) : e)
          .toList();
    } else {
      attendingEventIds.add(id);
      events = events
          .map((e) => e.id == id ? e.copyWith(rsvp: e.rsvp + 1) : e)
          .toList();
    }
    final updated = liveEvent(id);
    if (selectedEvent?.id == id && updated != null) {
      selectedEvent = updated;
    }
    notifyListeners();
  }

  bool isAttending(int id) => attendingEventIds.contains(id);

  void selectEvent(Event e) {
    selectedEvent = liveEvent(e.id) ?? e;
    notifyListeners();
  }

  void addOrUpdateEvent(Event event) {
    final idx = events.indexWhere((e) => e.id == event.id);
    if (idx >= 0) {
      events = [
        for (int i = 0; i < events.length; i++) i == idx ? event : events[i],
      ];
    } else {
      events = [event, ...events];
    }
    if (selectedEvent?.id == event.id) {
      selectedEvent = event;
    }
    editingEvent = null;
    notifyListeners();
  }

  void removeEvent(int id) {
    events = events.where((e) => e.id != id).toList();
    attendingEventIds.remove(id);
    if (selectedEvent?.id == id) {
      selectedEvent = null;
    }
    notifyListeners();
  }

  void setEditingEvent(Event? e) {
    editingEvent = e;
    notifyListeners();
  }

  Event? liveEvent(int id) {
    for (final e in events) {
      if (e.id == id) return e;
    }
    return null;
  }
}

class AppStateProvider extends InheritedNotifier<AppState> {
  const AppStateProvider(
      {super.key, required AppState state, required super.child})
      : super(notifier: state);

  static AppState of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<AppStateProvider>()!
        .notifier!;
  }
}
