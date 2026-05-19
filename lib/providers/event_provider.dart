import 'dart:async';

import 'package:flutter/material.dart';

import '../models/event_model.dart';
import '../services/firestore_service.dart';

class EventProvider extends ChangeNotifier {
  EventProvider({
    required FirestoreService firestoreService,
  }) : _firestoreService = firestoreService;

  final FirestoreService _firestoreService;

  List<Event> _events = <Event>[];
  bool _isLoading = true;
  String? _errorMessage;
  String? _selectedEventId;
  String? _editingEventId;
  StreamSubscription<List<Event>>? _subscription;

  List<Event> get events => _events;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  DateTime get referenceDate {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  List<Event> get activeEvents {
    return _events.where((event) => !event.deleted && !isPastEvent(event)).toList();
  }

  List<Event> get nonDeletedEvents {
    return _events.where((event) => !event.deleted).toList();
  }

  Event? get selectedEvent => _eventById(_selectedEventId);
  Event? get editingEvent => _eventById(_editingEventId);

  Map<DateTime, List<Event>> get eventsByDate {
    final grouped = <DateTime, List<Event>>{};
    for (final event in activeEvents) {
      final eventDate = event.scheduledDate;
      if (eventDate == null) {
        continue;
      }
      final day = DateTime(eventDate.year, eventDate.month, eventDate.day);
      grouped.putIfAbsent(day, () => <Event>[]).add(event);
    }
    return grouped;
  }

  void startListening() {
    if (_subscription != null) {
      return;
    }
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    _subscription?.cancel();
    _subscription = _firestoreService.eventsStream().listen(
      (events) {
        _events = events;
        _isLoading = false;
        _errorMessage = null;
        notifyListeners();
      },
      onError: (Object error) {
        _isLoading = false;
        _errorMessage = error.toString();
        notifyListeners();
      },
    );
  }

  Future<void> stopListeningAndClear() async {
    await _subscription?.cancel();
    _subscription = null;
    _events = <Event>[];
    _selectedEventId = null;
    _editingEventId = null;
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }

  bool isPastEvent(Event event) {
    final eventDate = event.scheduledDate;
    if (eventDate == null) {
      return false;
    }
    return eventDate.isBefore(referenceDate);
  }

  List<Event> eventsForRole(String role) {
    return activeEvents;
  }

  List<Event> savedEvents(String? uid) {
    return activeEvents.where((event) => event.isSavedBy(uid)).toList();
  }

  List<Event> attendingEvents(String? uid) {
    return activeEvents.where((event) => event.isAttendingBy(uid)).toList();
  }

  List<Event> adminOwnedEvents(String? uid, {String? clubId}) {
    return _events.where((event) {
      final matchesUid = uid != null && uid.isNotEmpty && event.createdBy == uid;
      final matchesClub =
          clubId != null && clubId.isNotEmpty && event.clubId == clubId;
      return !event.deleted && (matchesUid || matchesClub);
    }).toList();
  }

  List<Event> eventsForDate(DateTime date) {
    return nonDeletedEvents.where((event) {
      final eventDate = event.scheduledDate;
      if (eventDate == null) {
        return false;
      }
      return eventDate.year == date.year &&
          eventDate.month == date.month &&
          eventDate.day == date.day;
    }).toList()
      ..sort((a, b) => a.time.compareTo(b.time));
  }

  Future<void> createEvent(Event event) async {
    await _firestoreService.createEvent(event);
  }

  Future<void> updateEvent(Event event) async {
    await _firestoreService.updateEvent(event);
  }

  Future<void> deleteEvent(String eventId) async {
    await _firestoreService.deleteEvent(eventId);
  }

  Future<void> toggleSave(String eventId, String uid) async {
    await _firestoreService.toggleSave(eventId, uid);
  }

  Future<void> toggleAttendance(String eventId, String uid) async {
    await _firestoreService.toggleAttendance(eventId, uid);
  }

  void selectEvent(Event? event) {
    _selectedEventId = event?.id;
    notifyListeners();
  }

  void setEditingEvent(Event? event) {
    _editingEventId = event?.id;
    notifyListeners();
  }

  Event? eventById(String eventId) => _eventById(eventId);

  Event? _eventById(String? eventId) {
    if (eventId == null) {
      return null;
    }
    for (final event in _events) {
      if (event.id == eventId) {
        return event;
      }
    }
    return null;
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
