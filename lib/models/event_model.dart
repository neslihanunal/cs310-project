import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  final String id;
  final String title;
  final String club;
  final String clubId;
  final String date;
  final String time;
  final String loc;
  final String cat;
  final String desc;
  final String building;
  final String floor;
  final String room;
  final String? posterUrl;
  final bool deleted;
  final String createdBy;
  final String createdByEmail;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<String> savedBy;
  final List<String> attendingBy;

  const Event({
    required this.id,
    required this.title,
    required this.club,
    required this.clubId,
    required this.date,
    required this.time,
    required this.loc,
    required this.cat,
    required this.desc,
    required this.building,
    required this.floor,
    required this.room,
    this.posterUrl,
    this.deleted = false,
    required this.createdBy,
    required this.createdByEmail,
    required this.createdAt,
    this.updatedAt,
    this.savedBy = const <String>[],
    this.attendingBy = const <String>[],
  });

  int get rsvpCount => attendingBy.length;
  int get colorSeed => id.hashCode.abs();

  bool isSavedBy(String? uid) {
    if (uid == null || uid.isEmpty) {
      return false;
    }
    return savedBy.contains(uid);
  }

  bool isAttendingBy(String? uid) {
    if (uid == null || uid.isEmpty) {
      return false;
    }
    return attendingBy.contains(uid);
  }

  DateTime? get scheduledDate {
    final parts = date.split(' ');
    if (parts.length != 2) {
      return null;
    }
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
    if (month == null || day == null) {
      return null;
    }
    final now = DateTime.now();
    return DateTime(now.year, month, day);
  }

  factory Event.fromFirestore(DocumentSnapshot<Map<String, dynamic>> document) {
    return Event.fromMap(document.id, document.data() ?? const {});
  }

  factory Event.fromMap(String id, Map<String, dynamic> data) {
    return Event(
      id: id,
      title: (data['title'] as String? ?? '').trim(),
      club: (data['club'] as String? ?? '').trim(),
      clubId: (data['clubId'] as String? ?? '').trim(),
      date: (data['date'] as String? ?? '').trim(),
      time: (data['time'] as String? ?? '').trim(),
      loc: (data['loc'] as String? ?? '').trim(),
      cat: (data['cat'] as String? ?? '').trim(),
      desc: (data['desc'] as String? ?? '').trim(),
      building: (data['building'] as String? ?? '').trim(),
      floor: (data['floor'] as String? ?? '').trim(),
      room: (data['room'] as String? ?? '').trim(),
      posterUrl: (data['posterUrl'] as String?)?.trim(),
      deleted: data['deleted'] as bool? ?? false,
      createdBy: (data['createdBy'] as String? ?? '').trim(),
      createdByEmail: (data['createdByEmail'] as String? ?? '').trim(),
      createdAt: _readDateTime(data['createdAt']) ?? DateTime.now(),
      updatedAt: _readDateTime(data['updatedAt']),
      savedBy: List<String>.from(data['savedBy'] as List? ?? const <String>[]),
      attendingBy:
          List<String>.from(data['attendingBy'] as List? ?? const <String>[]),
    );
  }

  Map<String, dynamic> toFirestore() {
    return <String, dynamic>{
      'title': title,
      'club': club,
      'clubId': clubId,
      'date': date,
      'time': time,
      'loc': loc,
      'cat': cat,
      'desc': desc,
      'building': building,
      'floor': floor,
      'room': room,
      'posterUrl': posterUrl,
      'deleted': deleted,
      'createdBy': createdBy,
      'createdByEmail': createdByEmail,
      'createdAt': createdAt,
      'updatedAt': updatedAt ?? DateTime.now(),
      'savedBy': savedBy,
      'attendingBy': attendingBy,
    };
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'club': club,
      'clubId': clubId,
      'date': date,
      'time': time,
      'loc': loc,
      'cat': cat,
      'desc': desc,
      'building': building,
      'floor': floor,
      'room': room,
      'posterUrl': posterUrl,
      'deleted': deleted,
      'createdBy': createdBy,
      'createdByEmail': createdByEmail,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'savedBy': savedBy,
      'attendingBy': attendingBy,
    };
  }

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      club: json['club'] as String? ?? '',
      clubId: json['clubId'] as String? ?? '',
      date: json['date'] as String? ?? '',
      time: json['time'] as String? ?? '',
      loc: json['loc'] as String? ?? '',
      cat: json['cat'] as String? ?? '',
      desc: json['desc'] as String? ?? '',
      building: json['building'] as String? ?? '',
      floor: json['floor'] as String? ?? '',
      room: json['room'] as String? ?? '',
      posterUrl: json['posterUrl'] as String?,
      deleted: json['deleted'] as bool? ?? false,
      createdBy: json['createdBy'] as String? ?? '',
      createdByEmail: json['createdByEmail'] as String? ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? ''),
      savedBy: List<String>.from(json['savedBy'] as List? ?? const <String>[]),
      attendingBy:
          List<String>.from(json['attendingBy'] as List? ?? const <String>[]),
    );
  }

  Event copyWith({
    String? id,
    String? title,
    String? club,
    String? clubId,
    String? date,
    String? time,
    String? loc,
    String? cat,
    String? desc,
    String? building,
    String? floor,
    String? room,
    String? posterUrl,
    bool? deleted,
    String? createdBy,
    String? createdByEmail,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? savedBy,
    List<String>? attendingBy,
  }) {
    return Event(
      id: id ?? this.id,
      title: title ?? this.title,
      club: club ?? this.club,
      clubId: clubId ?? this.clubId,
      date: date ?? this.date,
      time: time ?? this.time,
      loc: loc ?? this.loc,
      cat: cat ?? this.cat,
      desc: desc ?? this.desc,
      building: building ?? this.building,
      floor: floor ?? this.floor,
      room: room ?? this.room,
      posterUrl: posterUrl ?? this.posterUrl,
      deleted: deleted ?? this.deleted,
      createdBy: createdBy ?? this.createdBy,
      createdByEmail: createdByEmail ?? this.createdByEmail,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      savedBy: savedBy ?? this.savedBy,
      attendingBy: attendingBy ?? this.attendingBy,
    );
  }

  static DateTime? _readDateTime(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }
    if (value is DateTime) {
      return value;
    }
    if (value is String) {
      return DateTime.tryParse(value);
    }
    return null;
  }
}
