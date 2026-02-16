class User {
  final int id;
  final String studentId;
  final String email;
  final String firstName;
  final String lastName;
  final String campus;
  final String? program;
  final bool isVerified;
  final String role;

  User({
    required this.id,
    required this.studentId,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.campus,
    this.program,
    required this.isVerified,
    required this.role,
  });

  String get name => '$firstName $lastName';

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'student_id': studentId,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'campus': campus,
      'program': program,
      'is_verified': isVerified,
      'role': role,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      studentId: map['student_id'],
      email: map['email'],
      firstName: map['first_name'],
      lastName: map['last_name'],
      campus: map['campus'],
      program: map['program'],
      isVerified: map['is_verified'] == 1,
      role: map['role'],
    );
  }

  User copyWith({
    int? id,
    String? studentId,
    String? email,
    String? firstName,
    String? lastName,
    String? campus,
    String? program,
    bool? isVerified,
    String? role,
  }) {
    return User(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      campus: campus ?? this.campus,
      program: program ?? this.program,
      isVerified: isVerified ?? this.isVerified,
      role: role ?? this.role,
    );
  }
}
