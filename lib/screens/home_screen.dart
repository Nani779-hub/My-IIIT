import 'package:flutter/material.dart';

import '../models/app_user.dart';
import '../models/course.dart';
import '../services/auth_service.dart';
import '../services/fake_db.dart';
import '../widgets/app_drawer.dart';
import '../widgets/course_list_student.dart';
import '../widgets/course_management_admin.dart';

// Extra screens from your 2nd app
import '../screens_extra/notices_screen.dart';
import '../screens_extra/registration_history.dart';
import '../screens_extra/pending_approvals.dart';
import '../screens_extra/settings.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = '/home';

  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DrawerSection _section = DrawerSection.dashboard;

  AppUser? get _user => AuthService.instance.currentUser;

  // Courses filtered by department / role
  List<Course> get _filteredCourses {
    final user = _user;
    if (user == null) return [];
    if (user.role == UserRole.academic) {
      return FakeDb.courses;
    }
    return FakeDb.courses
        .where((c) => c.department == user.department)
        .toList();
  }

  // Students visible to this user
  List<AppUser> get _students {
    final user = _user;
    if (user == null) return [];
    final allStudents =
        FakeDb.users.where((u) => u.role == UserRole.student).toList();
    if (user.role == UserRole.academic) return allStudents;
    return allStudents
        .where((u) => u.department == user.department)
        .toList();
  }

  // Faculty (Teachers + HODs) visible to this user
  List<AppUser> get _faculty {
    final user = _user;
    if (user == null) return [];
    final allFaculty = FakeDb.users
        .where((u) => u.role == UserRole.teacher || u.role == UserRole.hod)
        .toList();
    if (user.role == UserRole.academic) return allFaculty;
    return allFaculty
        .where((u) => u.department == user.department)
        .toList();
  }

  // Departments (for Academic view)
  List<String> get _departments {
    final set = <String>{};
    for (final c in FakeDb.courses) {
      set.add(c.department);
    }
    final list = set.toList();
    list.sort();
    return list;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // If user not logged in, push back to login
    if (_user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacementNamed('/login');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _user;
    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My IIIT – Academic Portal'),
      ),
      drawer: AppDrawer(
        user: user,
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
        child: _buildBody(user),
      ),
    );
  }

  // ---------- MAIN BODY SWITCH ----------

  Widget _buildBody(AppUser user) {
    switch (_section) {
      case DrawerSection.dashboard:
        return _buildDashboard(user);
      case DrawerSection.profile:
        return _buildProfileView(user);
      case DrawerSection.notices:
        return const NoticesScreen();
      case DrawerSection.courseRegistration:
        return CourseListStudent(
          availableCourses: _filteredCourses,
        );
      case DrawerSection.manageCourses:
        return CourseManagementAdmin(
          courses: _filteredCourses,
          roleLabel: user.roleLabel,
        );
      case DrawerSection.students:
        return _buildStudentsView(user);
      case DrawerSection.faculty:
        return _buildFacultyView(user);
      case DrawerSection.departments:
        return _buildDepartmentsView();
      case DrawerSection.approvals:
        return const PendingApprovals();
      case DrawerSection.history:
        return RegistrationHistory(
          roll: user.rollNo ?? '', // adjust if your model uses rollNumber
        );
      case DrawerSection.settings:
        return const SettingsScreen();
    }
  }

  // ---------- DASHBOARD (COMBINED) ----------

  Widget _buildDashboard(AppUser user) {
    final totalCourses = _filteredCourses.length;
    final totalStudents = _students.length;
    final totalFaculty = _faculty.length;

    // Time-based greeting from App 1
    final hour = TimeOfDay.now().hour;
    final greeting = hour < 12
        ? 'Good morning'
        : hour < 18
            ? 'Good afternoon'
            : 'Good evening';

    String accessNote;
    switch (user.role) {
      case UserRole.academic:
        accessNote =
            'You are logged in as Academic Section. You have institute-wide visibility across departments and can oversee approvals.';
        break;
      case UserRole.hod:
        accessNote =
            'You are logged in as HOD. You can manage courses, view department students & faculty, and review registrations.';
        break;
      case UserRole.teacher:
        accessNote =
            'You are logged in as Teacher. You can view department courses and related academic information.';
        break;
      case UserRole.student:
        accessNote =
            'You are logged in as Student. You can view offered courses, register, and track your registration status.';
        break;
    }

    final displayRoll = user.rollNo ?? 'ID: Not set';

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Greeting + quick role info (from App 1 idea, App 2 style)
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.08),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Icon(
                      Icons.person_rounded,
                      color: Theme.of(context).colorScheme.primary,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$greeting, ${user.name.split(' ').first}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${user.roleLabel} • ${user.department} • $displayRoll',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
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
                            fontSize: 12,
                            color: Color(0xFF2563EB),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Stats cards
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
                title: 'Students in View',
                value: totalStudents.toString(),
                icon: Icons.groups_outlined,
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'My IIIT – Role Based Access',
                    style:
                        TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    accessNote,
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: const [
                      Chip(
                        label: Text('Academic Section'),
                        avatar: Icon(Icons.admin_panel_settings, size: 16),
                      ),
                      Chip(
                        label: Text('HOD & Faculty'),
                        avatar: Icon(Icons.school, size: 16),
                      ),
                      Chip(
                        label: Text('Student Registration'),
                        avatar: Icon(
                          Icons.app_registration_rounded,
                          size: 16,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
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

  Widget _buildProfileView(AppUser user) {
    final email = (user.rollNo != null
            ? '${user.rollNo!.toLowerCase()}@myiiit.ac.in'
            : '${user.name.toLowerCase().replaceAll(' ', '.')}@myiiit.ac.in')
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
                      user.name.substring(0, 1).toUpperCase(),
                      style: const TextStyle(fontSize: 22),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user.roleLabel,
                          style: const TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          user.department,
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
                  _profileRow('Name', user.name),
                  _profileRow('Role', user.roleLabel),
                  _profileRow('Department', user.department),
                  _profileRow(
                    'Roll Number',
                    user.rollNo ?? 'Not applicable',
                  ),
                  _profileRow('Institute Email', email),
                  _profileRow('Academic Year', '2024 - 2025'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(14.0),
              child: Text(
                'Note: This is a prototype profile view. In the full system, details like phone '
                'number, parent contact, address, and official photo would be integrated from the central system.',
                style: TextStyle(color: Colors.grey, fontSize: 12),
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
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  // ---------- STUDENTS VIEW ----------

  Widget _buildStudentsView(AppUser user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          user.role == UserRole.academic
              ? 'All Students (Institute-wide)'
              : 'Students – ${user.department}',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        const Text(
          'List of students visible to your role and department.',
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: _students.isEmpty
              ? const Center(
                  child: Text(
                    'No students found for this view.',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  itemCount: _students.length,
                  itemBuilder: (ctx, i) {
                    final s = _students[i];
                    final labelSource = s.rollNo ?? s.name;
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Text(
                            labelSource.substring(0, 2).toUpperCase(),
                            style: const TextStyle(fontSize: 11),
                          ),
                        ),
                        title: Text(s.name),
                        subtitle: Text(
                          '${s.rollNo ?? 'No Roll'} • ${s.department}',
                          style: const TextStyle(fontSize: 12),
                        ),
                        trailing: const Icon(Icons.chevron_right),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  // ---------- FACULTY VIEW ----------

  Widget _buildFacultyView(AppUser user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          user.role == UserRole.academic
              ? 'Faculty & HODs (Institute-wide)'
              : 'Faculty – ${user.department}',
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

  // ---------- DEPARTMENTS VIEW (Academic only) ----------

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
          'Academic section can view configured departments with course and headcount summary.',
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
                    final deptStudents = FakeDb.users
                        .where((u) =>
                            u.role == UserRole.student &&
                            u.department == dept)
                        .length;
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
                          'Courses: $deptCourses • Students: $deptStudents • Faculty: $deptFaculty',
                          style: const TextStyle(fontSize: 12),
                        ),
                        trailing: const Icon(Icons.chevron_right),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

