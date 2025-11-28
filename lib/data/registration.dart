enum RegistrationStatus {
  pending,
  hodApproved,
  academicApproved,
}

class Registration {
  final String roll;
  final int semester;
  final int credits;
  RegistrationStatus status;

  Registration({
    required this.roll,
    required this.semester,
    required this.credits,
    this.status = RegistrationStatus.pending,
  });
}

/// Fake registration requests (prototype demo data)
List<Registration> registrations = [
  Registration(roll: 'CS24B001', semester: 3, credits: 22),
  Registration(roll: 'AI22B011', semester: 5, credits: 20),
  Registration(roll: 'EC22B018', semester: 5, credits: 24),
];

