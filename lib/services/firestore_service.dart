import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/event_model.dart';
import '../models/user_model.dart';
import 'local_storage_service.dart';

class FirestoreService {
  FirestoreService({
    required LocalStorageService localStorage,
    required bool firebaseEnabled,
    FirebaseFirestore? firestore,
  })  : _localStorage = localStorage,
        _firebaseEnabled = firebaseEnabled,
        _firestore = firebaseEnabled ? (firestore ?? FirebaseFirestore.instance) : null;

  final LocalStorageService _localStorage;
  final bool _firebaseEnabled;
  final FirebaseFirestore? _firestore;

  final Map<String, Event> _localEvents = <String, Event>{};
  final Map<String, AppUser> _localUsers = <String, AppUser>{};
  final StreamController<List<Event>> _localEventsController =
      StreamController<List<Event>>.broadcast();

  bool _localLoaded = false;

  CollectionReference<Map<String, dynamic>> get _eventsCollection =>
      _firestore!.collection('events');

  CollectionReference<Map<String, dynamic>> get _usersCollection =>
      _firestore!.collection('users');

  Future<void> _ensureLocalLoaded() async {
    if (_firebaseEnabled || _localLoaded) {
      return;
    }
    final events = _localStorage.cachedEvents;
    final users = _localStorage.cachedUsers;
    for (final event in events) {
      _localEvents[event.id] = event;
    }
    _localUsers.addAll(users);
    _localLoaded = true;
  }

  List<Event> _sortedLocalEvents() {
    final events = _localEvents.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return events;
  }

  Future<void> _persistLocalEvents() async {
    await _localStorage.saveCachedEvents(_sortedLocalEvents());
    _localEventsController.add(_sortedLocalEvents());
  }

  Future<void> _persistLocalUsers() async {
    await _localStorage.saveCachedUsers(_localUsers);
  }

  Stream<List<Event>> eventsStream() async* {
    if (_firebaseEnabled) {
      yield* _eventsCollection
          .where('deleted', isEqualTo: false)
          .snapshots()
          .map((snapshot) {
        final events =
            snapshot.docs.map(Event.fromFirestore).where((event) => !event.deleted).toList()
              ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return events;
      });
      return;
    }

    await _ensureLocalLoaded();
    yield _sortedLocalEvents().where((event) => !event.deleted).toList();
    yield* _localEventsController.stream.map(
      (events) => events.where((event) => !event.deleted).toList(),
    );
  }

  Stream<Event?> eventStream(String eventId) async* {
    if (_firebaseEnabled) {
      yield* _eventsCollection.doc(eventId).snapshots().map((snapshot) {
        if (!snapshot.exists || snapshot.data() == null) {
          return null;
        }
        return Event.fromFirestore(snapshot);
      });
      return;
    }

    await _ensureLocalLoaded();
    yield _localEvents[eventId];
    yield* _localEventsController.stream
        .map((events) => events.where((event) => event.id == eventId).firstOrNull);
  }

  Future<void> createEvent(Event event) async {
    if (_firebaseEnabled) {
      await _eventsCollection.doc(event.id).set(event.toFirestore());
      return;
    }

    await _ensureLocalLoaded();
    _localEvents[event.id] = event;
    await _persistLocalEvents();
  }

  Future<void> updateEvent(Event event) async {
    if (_firebaseEnabled) {
      await _eventsCollection.doc(event.id).set(event.toFirestore(), SetOptions(merge: true));
      return;
    }

    await _ensureLocalLoaded();
    _localEvents[event.id] = event;
    await _persistLocalEvents();
  }

  Future<void> deleteEvent(String eventId) async {
    if (_firebaseEnabled) {
      await _eventsCollection.doc(eventId).set(<String, dynamic>{
        'deleted': true,
        'updatedAt': DateTime.now(),
      }, SetOptions(merge: true));
      return;
    }

    await _ensureLocalLoaded();
    final existing = _localEvents[eventId];
    if (existing == null) {
      return;
    }
    _localEvents[eventId] =
        existing.copyWith(deleted: true, updatedAt: DateTime.now());
    await _persistLocalEvents();
  }

  Future<void> toggleSave(String eventId, String uid) async {
    if (_firebaseEnabled) {
      await _firestore!.runTransaction((transaction) async {
        final ref = _eventsCollection.doc(eventId);
        final snapshot = await transaction.get(ref);
        if (!snapshot.exists || snapshot.data() == null) {
          return;
        }
        final event = Event.fromFirestore(snapshot);
        final savedBy = List<String>.from(event.savedBy);
        if (savedBy.contains(uid)) {
          savedBy.remove(uid);
        } else {
          savedBy.add(uid);
        }
        transaction.update(ref, <String, dynamic>{
          'savedBy': savedBy,
          'updatedAt': DateTime.now(),
        });
      });
      return;
    }

    await _ensureLocalLoaded();
    final existing = _localEvents[eventId];
    if (existing == null) {
      return;
    }
    final savedBy = List<String>.from(existing.savedBy);
    if (savedBy.contains(uid)) {
      savedBy.remove(uid);
    } else {
      savedBy.add(uid);
    }
    _localEvents[eventId] =
        existing.copyWith(savedBy: savedBy, updatedAt: DateTime.now());
    await _persistLocalEvents();
  }

  Future<void> toggleAttendance(String eventId, String uid) async {
    if (_firebaseEnabled) {
      await _firestore!.runTransaction((transaction) async {
        final ref = _eventsCollection.doc(eventId);
        final snapshot = await transaction.get(ref);
        if (!snapshot.exists || snapshot.data() == null) {
          return;
        }
        final event = Event.fromFirestore(snapshot);
        final attendingBy = List<String>.from(event.attendingBy);
        if (attendingBy.contains(uid)) {
          attendingBy.remove(uid);
        } else {
          attendingBy.add(uid);
        }
        transaction.update(ref, <String, dynamic>{
          'attendingBy': attendingBy,
          'updatedAt': DateTime.now(),
        });
      });
      return;
    }

    await _ensureLocalLoaded();
    final existing = _localEvents[eventId];
    if (existing == null) {
      return;
    }
    final attendingBy = List<String>.from(existing.attendingBy);
    if (attendingBy.contains(uid)) {
      attendingBy.remove(uid);
    } else {
      attendingBy.add(uid);
    }
    _localEvents[eventId] =
        existing.copyWith(attendingBy: attendingBy, updatedAt: DateTime.now());
    await _persistLocalEvents();
  }

  Future<AppUser?> getUserProfile(String uid) async {
    if (_firebaseEnabled) {
      final snapshot = await _usersCollection.doc(uid).get();
      if (!snapshot.exists || snapshot.data() == null) {
        return null;
      }
      return AppUser.fromFirestore(snapshot);
    }

    await _ensureLocalLoaded();
    return _localUsers[uid];
  }

  Future<void> createOrUpdateUserProfile(AppUser user) async {
    if (_firebaseEnabled) {
      await _usersCollection.doc(user.uid).set(user.toFirestore(), SetOptions(merge: true));
      return;
    }

    await _ensureLocalLoaded();
    _localUsers[user.uid] = user;
    await _persistLocalUsers();
  }

  Future<bool> userProfileExists(String uid) async {
    final profile = await getUserProfile(uid);
    return profile != null;
  }
}

extension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
