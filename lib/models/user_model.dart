class User {
  final String role; // "student" or "admin"
  final String firstName;
  final String lastName;
  final String dept;
  final String? clubName;

  const User({
    required this.role,
    required this.firstName,
    required this.lastName,
    required this.dept,
    this.clubName,
  });

  User copyWith({
    String? firstName,
    String? lastName,
    String? dept,
    String? clubName,
  }) =>
      User(
        role: role,
        firstName: firstName ?? this.firstName,
        lastName: lastName ?? this.lastName,
        dept: dept ?? this.dept,
        clubName: clubName ?? this.clubName,
      );
}
