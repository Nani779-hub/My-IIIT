enum UserRole { academic, hod, teacher, student }

class AppUser {
  final String id;
  final String name;

  // Only students have roll number
  final String? rollNo;

  final String department;
  final UserRole role;

  // Prototype login field (in real life comes from backend / OTP)
  final String password;

  // Auto-generated or stored email
  final String? email;

  const AppUser({
    required this.id,
    required this.name,
    this.rollNo,
    required this.department,
    required this.role,
    required this.password,
    this.email,
  });

  String get roleLabel {
    switch (role) {
      case UserRole.academic:
        return 'Academic Section';
      case UserRole.hod:
        return 'HOD';
      case UserRole.teacher:
        return 'Teacher';
      case UserRole.student:
        return 'Student';
    }
  }

  /// Auto-generate institute email if none is provided.
  String get instituteEmail {
    if (email != null && email!.isNotEmpty) return email!;

    if (rollNo != null && rollNo!.isNotEmpty) {
      return '${rollNo!.toLowerCase()}@myiiit.ac.in';
    }

    return '${name.toLowerCase().replaceAll(' ', '.')}@myiiit.ac.in';
  }
}

