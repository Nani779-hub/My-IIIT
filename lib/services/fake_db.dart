import '../models/app_user.dart';
import '../models/course.dart';

class FakeDb {
  FakeDb._();

  // ---------- USERS ----------

  /// Demo users for Academic Section, HODs, Teachers and Students.
  static final List<AppUser> users = [
    // Academic section
    AppUser(
      id: 'u1',
      name: 'Academic Admin',
      rollNo: null,
      department: 'Academic',
      role: UserRole.academic,
      password: 'admin123',
    ),

    // HODs
    AppUser(
      id: 'u2',
      name: 'HOD CSE',
      rollNo: null,
      department: 'CSE',
      role: UserRole.hod,
      password: 'hodcse',
    ),
    AppUser(
      id: 'u3',
      name: 'HOD CSE-AI&DS',
      rollNo: null,
      department: 'CSE-AI&DS',
      role: UserRole.hod,
      password: 'hodai',
    ),
    AppUser(
      id: 'u4',
      name: 'HOD ECE',
      rollNo: null,
      department: 'ECE',
      role: UserRole.hod,
      password: 'hodece',
    ),
    AppUser(
      id: 'u5',
      name: 'HOD ECE-VLSI',
      rollNo: null,
      department: 'ECE-VLSI',
      role: UserRole.hod,
      password: 'hodvlsi',
    ),

    // Teachers
    AppUser(
      id: 'u6',
      name: 'Dr. Algorithm',
      rollNo: null,
      department: 'CSE',
      role: UserRole.teacher,
      password: 'teacher1',
    ),
    AppUser(
      id: 'u7',
      name: 'Dr. Data',
      rollNo: null,
      department: 'CSE',
      role: UserRole.teacher,
      password: 'teacher2',
    ),
    AppUser(
      id: 'u8',
      name: 'Dr. Neural',
      rollNo: null,
      department: 'CSE-AI&DS',
      role: UserRole.teacher,
      password: 'teacher3',
    ),
    AppUser(
      id: 'u9',
      name: 'Dr. Signals',
      rollNo: null,
      department: 'ECE',
      role: UserRole.teacher,
      password: 'teacher4',
    ),
    AppUser(
      id: 'u10',
      name: 'Dr. VLSI',
      rollNo: null,
      department: 'ECE-VLSI',
      role: UserRole.teacher,
      password: 'teacher5',
    ),
    AppUser(
      id: 'u11',
      name: 'Dr. Embedded',
      rollNo: null,
      department: 'ECE',
      role: UserRole.teacher,
      password: 'teacher6',
    ),

    // Students – CSE
    AppUser(
      id: 'u12',
      name: 'Sachith',
      rollNo: 'CS24B001',
      department: 'CSE',
      role: UserRole.student,
      password: 'student1',
    ),
    AppUser(
      id: 'u13',
      name: 'Ananya',
      rollNo: 'CS24B002',
      department: 'CSE',
      role: UserRole.student,
      password: 'student2',
    ),
    AppUser(
      id: 'u14',
      name: 'Rahul',
      rollNo: 'CS23B015',
      department: 'CSE',
      role: UserRole.student,
      password: 'student3',
    ),

    // Students – CSE-AI&DS
    AppUser(
      id: 'u15',
      name: 'Kiran',
      rollNo: 'AI24B003',
      department: 'CSE-AI&DS',
      role: UserRole.student,
      password: 'student4',
    ),
    AppUser(
      id: 'u16',
      name: 'Meera',
      rollNo: 'AI23B008',
      department: 'CSE-AI&DS',
      role: UserRole.student,
      password: 'student5',
    ),

    // Students – ECE
    AppUser(
      id: 'u17',
      name: 'Santosh',
      rollNo: 'EC24B010',
      department: 'ECE',
      role: UserRole.student,
      password: 'student6',
    ),
    AppUser(
      id: 'u18',
      name: 'Deepika',
      rollNo: 'EC23B012',
      department: 'ECE',
      role: UserRole.student,
      password: 'student7',
    ),

    // Students – ECE-VLSI
    AppUser(
      id: 'u19',
      name: 'Varun',
      rollNo: 'EV24B004',
      department: 'ECE-VLSI',
      role: UserRole.student,
      password: 'student8',
    ),
    AppUser(
      id: 'u20',
      name: 'Pooja',
      rollNo: 'EV23B006',
      department: 'ECE-VLSI',
      role: UserRole.student,
      password: 'student9',
    ),

    // Extra students
    AppUser(
      id: 'u21',
      name: 'Harsha',
      rollNo: 'CS22B020',
      department: 'CSE',
      role: UserRole.student,
      password: 'student10',
    ),
    AppUser(
      id: 'u22',
      name: 'Sneha',
      rollNo: 'AI22B011',
      department: 'CSE-AI&DS',
      role: UserRole.student,
      password: 'student11',
    ),
    AppUser(
      id: 'u23',
      name: 'Vikram',
      rollNo: 'EC22B018',
      department: 'ECE',
      role: UserRole.student,
      password: 'student12',
    ),
  ];

  // ---------- COURSES ----------

  /// Demo courses across departments and semesters.
  static final List<Course> courses = [
    // -------- CSE --------
    Course(id: 'c1', code: 'CS101', title: 'Programming Fundamentals', semester: 1, department: 'CSE', credits: 4, isCore: true),
    Course(id: 'c2', code: 'CS102', title: 'Discrete Mathematics', semester: 2, department: 'CSE', credits: 4),
    Course(id: 'c3', code: 'CS201', title: 'Data Structures', semester: 3, department: 'CSE', credits: 4),
    Course(id: 'c4', code: 'CS202', title: 'Computer Organization & Architecture', semester: 3, department: 'CSE', credits: 3),
    Course(id: 'c5', code: 'CS203', title: 'Design & Analysis of Algorithms', semester: 4, department: 'CSE', credits: 4),
    Course(id: 'c6', code: 'CS204', title: 'Operating Systems', semester: 4, department: 'CSE', credits: 3),
    Course(id: 'c7', code: 'CS301', title: 'Database Management Systems', semester: 5, department: 'CSE', credits: 4),
    Course(id: 'c8', code: 'CS302', title: 'Computer Networks', semester: 5, department: 'CSE', credits: 4),
    Course(id: 'c9', code: 'CS401', title: 'Software Engineering', semester: 7, department: 'CSE', credits: 3),
    Course(id: 'c10', code: 'CS402', title: 'Distributed Systems', semester: 7, department: 'CSE', credits: 3, isCore: false),

    // -------- CSE-AI&DS --------
    Course(id: 'c11', code: 'AI101', title: 'Introduction to AI & Data Science', semester: 1, department: 'CSE-AI&DS', credits: 3),
    Course(id: 'c12', code: 'AI201', title: 'Probability & Statistics for AI', semester: 3, department: 'CSE-AI&DS', credits: 4),
    Course(id: 'c13', code: 'AI202', title: 'Machine Learning', semester: 4, department: 'CSE-AI&DS', credits: 4),
    Course(id: 'c14', code: 'AI301', title: 'Deep Learning', semester: 5, department: 'CSE-AI&DS', credits: 3, isCore: false),
    Course(id: 'c15', code: 'AI302', title: 'Data Mining & Warehousing', semester: 5, department: 'CSE-AI&DS', credits: 3),
    Course(id: 'c16', code: 'AI401', title: 'MLOps & Model Deployment', semester: 7, department: 'CSE-AI&DS', credits: 3, isCore: false),

    // -------- ECE --------
    Course(id: 'c17', code: 'EC101', title: 'Basic Electronics', semester: 1, department: 'ECE', credits: 4),
    Course(id: 'c18', code: 'EC201', title: 'Signals & Systems', semester: 3, department: 'ECE', credits: 4),
    Course(id: 'c19', code: 'EC202', title: 'Analog Circuits', semester: 3, department: 'ECE', credits: 3),
    Course(id: 'c20', code: 'EC203', title: 'Digital Signal Processing', semester: 4, department: 'ECE', credits: 4),
    Course(id: 'c21', code: 'EC301', title: 'Communication Systems', semester: 5, department: 'ECE', credits: 4),
    Course(id: 'c22', code: 'EC302', title: 'Embedded Systems', semester: 5, department: 'ECE', credits: 3),

    // -------- ECE-VLSI --------
    Course(id: 'c23', code: 'EV201', title: 'Digital Electronics & Logic Design', semester: 3, department: 'ECE-VLSI', credits: 4),
    Course(id: 'c24', code: 'EV202', title: 'VLSI Design', semester: 4, department: 'ECE-VLSI', credits: 4),
    Course(id: 'c25', code: 'EV301', title: 'ASIC Design Flow', semester: 5, department: 'ECE-VLSI', credits: 3),
    Course(id: 'c26', code: 'EV302', title: 'FPGA Based System Design', semester: 5, department: 'ECE-VLSI', credits: 3, isCore: false),
    Course(id: 'c27', code: 'EV401', title: 'Low Power VLSI', semester: 7, department: 'ECE-VLSI', credits: 3, isCore: false),
    Course(id: 'c28', code: 'EV402', title: 'Physical Design Automation', semester: 7, department: 'ECE-VLSI', credits: 3),
  ];

  // ---------- ENROLLMENT SYSTEM ----------

  static final Map<String, Set<String>> _enrollments = {};

  static List<Course> getCoursesForStudent(String studentId) {
    final ids = _enrollments[studentId];
    if (ids == null || ids.isEmpty) return [];
    return courses.where((c) => ids.contains(c.id)).toList();
  }

  static bool isStudentEnrolled(String studentId, String courseId) {
    return _enrollments[studentId]?.contains(courseId) == true;
  }

  static void toggleEnrollment({
    required String studentId,
    required String courseId,
  }) {
    final set = _enrollments.putIfAbsent(studentId, () => <String>{});
    if (set.contains(courseId)) {
      set.remove(courseId);
    } else {
      set.add(courseId);
    }
  }

  static int enrolledCount(String courseId) {
    int count = 0;
    for (final set in _enrollments.values) {
      if (set.contains(courseId)) count++;
    }
    return count;
  }
}

