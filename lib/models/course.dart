class Course {
  final String id;
  final String code;
  final String title;

  // Academic info
  final int semester;
  final String department;
  final int credits;
  final bool isCore;

  // Faculty handling (optional for demo)
  final String faculty;

  // Seats + enrollment
  final int maxSeats;
  final List<String> enrolledStudentIds;

  Course({
    required this.id,
    required this.code,
    required this.title,
    required this.semester,
    required this.department,
    required this.credits,
    this.isCore = true,
    this.faculty = 'TBA',
    this.maxSeats = 60,
    List<String>? enrolledStudentIds,
  }) : enrolledStudentIds = enrolledStudentIds ?? [];

  // ---- LOGIC ----

  bool isStudentEnrolled(String studentId) {
    return enrolledStudentIds.contains(studentId);
  }

  int get seatsLeft => maxSeats - enrolledStudentIds.length;

  Course copyWith({
    String? id,
    String? code,
    String? title,
    int? semester,
    String? department,
    int? credits,
    bool? isCore,
    String? faculty,
    int? maxSeats,
    List<String>? enrolledStudentIds,
  }) {
    return Course(
      id: id ?? this.id,
      code: code ?? this.code,
      title: title ?? this.title,
      semester: semester ?? this.semester,
      department: department ?? this.department,
      credits: credits ?? this.credits,
      isCore: isCore ?? this.isCore,
      faculty: faculty ?? this.faculty,
      maxSeats: maxSeats ?? this.maxSeats,
      enrolledStudentIds:
          enrolledStudentIds ?? List.of(this.enrolledStudentIds),
    );
  }
}

