import 'package:flutter/material.dart';
import '../models/app_user.dart';
import '../models/course.dart';
import '../services/fake_db.dart';
import '../services/student_db.dart';
import '../widgets/app_drawer.dart';
import '../widgets/course_list_student.dart';
import '../widgets/course_management_admin.dart';

class HomeScreen extends StatefulWidget {
  // Needed for named routes
  static const routeName = '/home';

  final AppUser user;

  const HomeScreen({super.key, required this.user});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DrawerSection _section = DrawerSection.dashboard;

  // For SQLite students view
  int _selectedSemester = 1;
  bool _studentsLoading = false;
  String? _studentsError;
  List<StudentRecord> _studentsSql = [];

  // Simple local settings demo state
  bool _notifEnabled = true;
  bool _emailUpdates = true;
  bool _darkMode = false;

  @override
  void initState() {
    super.initState();
    _loadStudentsFromDb();
  }

  List<Course> get _filteredCourses {
    if (widget.user.role == UserRole.academic) {
      return FakeDb.courses;
    }
    return FakeDb.courses
        .where((c) => c.department == widget.user.department)
        .toList();
  }

  List<AppUser> get _faculty {
    final allFaculty = FakeDb.users
        .where((u) => u.role == UserRole.teacher || u.role == UserRole.hod)
        .toList();
    if (widget.user.role == UserRole.academic) return allFaculty;
    return allFaculty
        .where((u) => u.department == widget.user.department)
        .toList();
  }

  List<String> get _departments {
    final set = <String>{};
    for (final c in FakeDb.courses) {
      set.add(c.department);
    }
    return set.toList()..sort();
  }

  Future<void> _loadStudentsFromDb() async {
    setState(() {
      _studentsLoading = true;
      _studentsError = null;
    });

    try {
      final deptFilter =
          widget.user.role == UserRole.academic ? null : widget.user.department;

      final list = await StudentDb.instance.getStudents(
        department: deptFilter,
        semester: _selectedSemester,
        limit: 4000, // can load all if needed
      );

      setState(() {
        _studentsSql = list;
      });
    } catch (e) {
      setState(() {
        _studentsError = 'Failed to load students from SQLite: $e';
      });
    } finally {
      setState(() {
        _studentsLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My IIIT – Academic Portal'),
      ),
      drawer: AppDrawer(
        user: widget.user,
        selected: _section,
        onSelect: (section) {
          setState(() {
            _section = section;
          });
          Navigator.of(context).pop();
        },
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    switch (_section) {
      case DrawerSection.dashboard:
        return _buildDashboard();
      case DrawerSection.profile:
        return _buildProfileView();
      case DrawerSection.notices:
        return _buildNoticesView();
      case DrawerSection.courseRegistration:
        return CourseListStudent(availableCourses: _filteredCourses);
      case DrawerSection.manageCourses:
        return CourseManagementAdmin(
          courses: _filteredCourses,
          roleLabel: widget.user.roleLabel,
        );
      case DrawerSection.students:
        return _buildStudentsViewSqlite();
      case DrawerSection.faculty:
        return _buildFacultyView();
      case DrawerSection.departments:
        return _buildDepartmentsView();
      case DrawerSection.approvals:
        return _buildApprovalsView();
      case DrawerSection.history:
        return _buildHistoryView();
      case DrawerSection.settings:
        return _buildSettingsView();
    }
  }

  // ---------- DASHBOARD ----------

  Widget _buildDashboard() {
    final totalCourses = _filteredCourses.length;
    final totalFaculty = _faculty.length;

    String accessNote;
    switch (widget.user.role) {
      case UserRole.academic:
        accessNote =
            'You are logged in as Academic Section. Institute-wide visibility and control.';
        break;
      case UserRole.hod:
        accessNote =
            'You are logged in as HOD. You manage department courses and students.';
        break;
      case UserRole.teacher:
        accessNote =
            'You are logged in as Teacher. You view department courses and students.';
        break;
      case UserRole.student:
        accessNote =
            'You are logged in as Student. You register for courses and view academic info.';
        break;
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 24,
                    child: Icon(Icons.person),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome, ${widget.user.name}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${widget.user.roleLabel} • ${widget.user.department}',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.verified_outlined,
                            size: 16, color: Color(0xFF2563EB)),
                        SizedBox(width: 6),
                        Text(
                          'My IIIT',
                          style: TextStyle(
                              fontSize: 12, color: Color(0xFF2563EB)),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _dashboardCard(
                title: 'Courses in View',
                value: totalCourses.toString(),
                icon: Icons.menu_book_outlined,
              ),
              _dashboardCard(
                title: 'Faculty in View',
                value: totalFaculty.toString(),
                icon: Icons.school_outlined,
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'Overview',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14.0),
              child: Text(
                accessNote,
                style: TextStyle(color: Colors.grey.shade700),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Database Summary (SQLite)',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          FutureBuilder<int>(
            future: StudentDb.instance.getStudentCount(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Card(
                  child: Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Text('Loading SQLite student data...'),
                  ),
                );
              }
              final count = snapshot.data!;
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    'Students stored in SQLite: $count',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          // 🔹 Show a small sample of students on Dashboard itself
          FutureBuilder<List<StudentRecord>>(
            future: StudentDb.instance.getSampleStudents(limit: 5),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const SizedBox(); // no extra loading indicator
              }
              final list = snapshot.data!;
              if (list.isEmpty) {
                return const SizedBox();
              }
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Sample students from SQLite (for demo):',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      ...list.map(
                        (s) => Text(
                          '${s.rollNo} • ${s.name} • ${s.department} • Sem ${s.semester}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _dashboardCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return SizedBox(
      width: 170,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon),
              const SizedBox(height: 8),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------- PROFILE VIEW ----------

  Widget _buildProfileView() {
    final email = (widget.user.rollNo != null
            ? '${widget.user.rollNo!.toLowerCase()}@myiiit.ac.in'
            : '${widget.user.name.toLowerCase().replaceAll(' ', '.')}@myiiit.ac.in')
        .replaceAll(' ', '');

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'My Profile',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14.0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    child: Text(
                      widget.user.name.substring(0, 1).toUpperCase(),
                      style: const TextStyle(fontSize: 22),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.user.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.user.roleLabel,
                          style: const TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.user.department,
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Account Details',
                    style:
                        TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                  const SizedBox(height: 8),
                  _profileRow('Name', widget.user.name),
                  _profileRow('Role', widget.user.roleLabel),
                  _profileRow('Department', widget.user.department),
                  _profileRow(
                      'Roll Number', widget.user.rollNo ?? 'Not applicable'),
                  _profileRow('Institute Email', email),
                  _profileRow('Academic Year', '2024 - 2025'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _profileRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: const TextStyle(
                  fontWeight: FontWeight.w500, color: Colors.grey),
            ),
          ),
          Expanded(
            child: Text(value),
          )
        ],
      ),
    );
  }

  // ---------- STUDENTS (from SQLite, semester-wise) ----------

  Widget _buildStudentsViewSqlite() {
    final isAcademic = widget.user.role == UserRole.academic;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isAcademic
              ? 'Students (SQLite – Institute-wide)'
              : 'Students – ${widget.user.department} (SQLite)',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        const Text(
          'Showing students stored in SQLite, filtered semester-wise.',
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            const Text(
              'Semester:',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(width: 8),
            DropdownButton<int>(
              value: _selectedSemester,
              items: List.generate(
                8,
                (i) => DropdownMenuItem(
                  value: i + 1,
                  child: Text('Sem ${i + 1}'),
                ),
              ),
              onChanged: (value) {
                if (value == null) return;
                setState(() {
                  _selectedSemester = value;
                });
                _loadStudentsFromDb();
              },
            ),
            const Spacer(),
            IconButton(
              onPressed: _loadStudentsFromDb,
              icon: const Icon(Icons.refresh),
              tooltip: 'Reload from SQLite',
            )
          ],
        ),
        const SizedBox(height: 8),
        if (_studentsLoading)
          const Expanded(
            child: Center(
              child: CircularProgressIndicator(),
            ),
          )
        else if (_studentsError != null)
          Expanded(
            child: Center(
              child: Text(
                _studentsError!,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          )
        else if (_studentsSql.isEmpty)
          const Expanded(
            child: Center(
              child: Text(
                'No students found for this semester.',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          )
        else
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Showing ${_studentsSql.length} student(s) for Sem $_selectedSemester',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 6),
                Expanded(
                  child: ListView.builder(
                    itemCount: _studentsSql.length,
                    itemBuilder: (ctx, i) {
                      final s = _studentsSql[i];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 3),
                        child: ListTile(
                          leading: CircleAvatar(
                            child: Text(
                              s.rollNo.substring(s.rollNo.length - 2),
                              style: const TextStyle(fontSize: 11),
                            ),
                          ),
                          title: Text(s.name),
                          subtitle: Text(
                            '${s.rollNo} • ${s.department} • Sem ${s.semester}',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  // ---------- FACULTY VIEW ----------

  Widget _buildFacultyView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.user.role == UserRole.academic
              ? 'Faculty & HODs (Institute-wide)'
              : 'Faculty – ${widget.user.department}',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        const Text(
          'Teaching faculty and HODs visible to your role.',
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: _faculty.isEmpty
              ? const Center(
                  child: Text(
                    'No faculty found for this view.',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  itemCount: _faculty.length,
                  itemBuilder: (ctx, i) {
                    final f = _faculty[i];
                    final isHod = f.role == UserRole.hod;
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Icon(
                            isHod ? Icons.star_rate_rounded : Icons.person,
                            size: 18,
                          ),
                        ),
                        title: Text(f.name),
                        subtitle: Text(
                          '${isHod ? 'HOD' : 'Teacher'} • ${f.department}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  // ---------- DEPARTMENTS VIEW ----------

  Widget _buildDepartmentsView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Departments Overview',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        const Text(
          'Academic section can view departments with simple summary.',
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: _departments.isEmpty
              ? const Center(
                  child: Text(
                    'No departments configured yet.',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  itemCount: _departments.length,
                  itemBuilder: (ctx, i) {
                    final dept = _departments[i];
                    final deptCourses = FakeDb.courses
                        .where((c) => c.department == dept)
                        .length;
                    final deptStudents =
                        4000; // For demo, same count per dept; explain in viva
                    final deptFaculty = FakeDb.users
                        .where((u) =>
                            (u.role == UserRole.teacher ||
                                u.role == UserRole.hod) &&
                            u.department == dept)
                        .length;

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        title: Text(dept),
                        subtitle: Text(
                          'Courses: $deptCourses • Students (SQLite, all years): $deptStudents • Faculty: $deptFaculty',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  // ---------- NOTICES VIEW (DEMO) ----------

  Widget _buildNoticesView() {
    final demoNotices = [
      {
        'title': 'Mid-Semester Exams – Timetable Published',
        'body':
            'Mid-sem exams for all B.Tech batches will be conducted from 10–15 Oct. Please check the exam cell notice board for detailed timetable.',
        'date': '02 Dec 2025',
        'tag': 'Examination',
      },
      {
        'title': 'Course Registration Window Open',
        'body':
            'Online course registration for Even Semester will remain open till 12 Dec 2025.',
        'date': '30 Nov 2025',
        'tag': 'Academics',
      },
      {
        'title': 'Holiday on 6th December',
        'body':
            'Institute will remain closed on 6th December due to local festival.',
        'date': '28 Nov 2025',
        'tag': 'General',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Notices & Circulars (Demo)',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        const Text(
          'Sample institute notices for demonstration.',
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: ListView.builder(
            itemCount: demoNotices.length,
            itemBuilder: (ctx, i) {
              final notice = demoNotices[i];
              return Card(
                child: ListTile(
                  title: Text(
                    notice['title'] as String,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      notice['body'] as String,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          notice['tag'] as String,
                          style: const TextStyle(
                            fontSize: 10,
                            color: Color(0xFF2563EB),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notice['date'] as String,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ---------- APPROVALS VIEW (DEMO) ----------

  Widget _buildApprovalsView() {
    final demoApprovals = [
      {
        'student': 'CS24B0001',
        'name': 'Student 1',
        'course': 'CS301 – Algorithms',
        'status': 'Pending',
      },
      {
        'student': 'CS24B0005',
        'name': 'Student 5',
        'course': 'CS305 – Database Systems',
        'status': 'Pending',
      },
    ];

    final isAcademicOrHod = widget.user.role == UserRole.academic ||
        widget.user.role == UserRole.hod;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Pending Approvals (Demo)',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          isAcademicOrHod
              ? 'Sample course registration requests pending for approval.'
              : 'Only Academic Section / HOD see approval requests.',
          style: const TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 12),
        if (!isAcademicOrHod)
          const Expanded(
            child: Center(
              child: Text(
                'You do not have approval permissions.',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          )
        else
          Expanded(
            child: ListView.builder(
              itemCount: demoApprovals.length,
              itemBuilder: (ctx, i) {
                final item = demoApprovals[i];
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.pending_actions_rounded),
                    title: Text('${item['course']}'),
                    subtitle: Text(
                      '${item['student']} • ${item['name']}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    trailing: Text(
                      item['status'] as String,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.orange,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  // ---------- HISTORY VIEW (DEMO) ----------

  Widget _buildHistoryView() {
    // Simple demo: show some fake registrations only for students
    if (widget.user.role != UserRole.student) {
      return const Center(
        child: Text(
          'Registration history is only applicable for student role (demo).',
          style: TextStyle(color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      );
    }

    final demoHistory = [
      {
        'semester': 'Sem 1',
        'courses': ['CS101 – Programming', 'MA101 – Calculus I'],
        'status': 'Completed',
      },
      {
        'semester': 'Sem 2',
        'courses': ['CS102 – Data Structures', 'MA102 – Linear Algebra'],
        'status': 'Completed',
      },
      {
        'semester': 'Sem 3',
        'courses': ['CS201 – Discrete Mathematics', 'CS202 – DBMS'],
        'status': 'Ongoing',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Registration History (Demo)',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        const Text(
          'Sample past registrations for demonstration.',
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: ListView.builder(
            itemCount: demoHistory.length,
            itemBuilder: (ctx, i) {
              final item = demoHistory[i];
              final courses = item['courses'] as List<String>;
              return Card(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            item['semester'] as String,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            item['status'] as String,
                            style: TextStyle(
                              fontSize: 12,
                              color: (item['status'] == 'Completed')
                                  ? Colors.green
                                  : Colors.orange,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ...courses.map(
                        (c) => Text(
                          '• $c',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ---------- SETTINGS VIEW (DEMO) ----------

  Widget _buildSettingsView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Settings (Demo)',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        const Text(
          'These are local demo settings just to show UI.',
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: ListView(
            children: [
              SwitchListTile(
                title: const Text('Push notifications'),
                subtitle: const Text('Show important alerts from institute'),
                value: _notifEnabled,
                onChanged: (v) {
                  setState(() => _notifEnabled = v);
                },
              ),
              SwitchListTile(
                title: const Text('Email updates'),
                subtitle: const Text('Send summary to institute email'),
                value: _emailUpdates,
                onChanged: (v) {
                  setState(() => _emailUpdates = v);
                },
              ),
              SwitchListTile(
                title: const Text('Dark mode (demo only)'),
                subtitle:
                    const Text('Visual toggle for demonstration, not global'),
                value: _darkMode,
                onChanged: (v) {
                  setState(() => _darkMode = v);
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.info_outline_rounded),
                title: const Text('App version'),
                subtitle: const Text('My IIIT • v1.0 (Demo build)'),
              ),
              ListTile(
                leading: const Icon(Icons.privacy_tip_outlined),
                title: const Text('Privacy & policy (demo)'),
                subtitle: const Text('Sample text for explanation in viva.'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

