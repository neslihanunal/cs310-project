import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String uid;
  final String email;
  final String role;
  final String firstName;
  final String lastName;
  final String department;
  final String? clubName;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const AppUser({
    required this.uid,
    required this.email,
    required this.role,
    required this.firstName,
    required this.lastName,
    required this.department,
    this.clubName,
    required this.createdAt,
    this.updatedAt,
  });

  String get displayName {
    final fullName = '$firstName $lastName'.trim();
    if (role == 'admin') {
      return (clubName ?? fullName).trim();
    }
    return fullName;
  }

  factory AppUser.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    return AppUser.fromMap(document.id, document.data() ?? const {});
  }

  factory AppUser.fromMap(String uid, Map<String, dynamic> data) {
    return AppUser(
      uid: uid,
      email: (data['email'] as String? ?? '').trim().toLowerCase(),
      role: (data['role'] as String? ?? 'student').trim().toLowerCase(),
      firstName: (data['firstName'] as String? ?? '').trim(),
      lastName: (data['lastName'] as String? ?? '').trim(),
      department: (data['department'] as String? ?? '').trim(),
      clubName: (data['clubName'] as String?)?.trim(),
      createdAt: _readDateTime(data['createdAt']) ?? DateTime.now(),
      updatedAt: _readDateTime(data['updatedAt']),
    );
  }

  Map<String, dynamic> toFirestore() {
    return <String, dynamic>{
      'email': email,
      'role': role,
      'firstName': firstName,
      'lastName': lastName,
      'department': department,
      'clubName': clubName,
      'createdAt': createdAt,
      'updatedAt': updatedAt ?? DateTime.now(),
    };
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'uid': uid,
      'email': email,
      'role': role,
      'firstName': firstName,
      'lastName': lastName,
      'department': department,
      'clubName': clubName,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      uid: json['uid'] as String? ?? '',
      email: json['email'] as String? ?? '',
      role: json['role'] as String? ?? 'student',
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      department: json['department'] as String? ?? '',
      clubName: json['clubName'] as String?,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? ''),
    );
  }

  AppUser copyWith({
    String? uid,
    String? email,
    String? role,
    String? firstName,
    String? lastName,
    String? department,
    String? clubName,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AppUser(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      role: role ?? this.role,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      department: department ?? this.department,
      clubName: clubName ?? this.clubName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
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
