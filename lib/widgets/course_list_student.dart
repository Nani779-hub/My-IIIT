import 'package:flutter/material.dart';

import '../models/course.dart';
import '../services/auth_service.dart';
import '../services/fake_db.dart';

class CourseListStudent extends StatefulWidget {
  final List<Course> availableCourses;

  const CourseListStudent({super.key, required this.availableCourses});

  @override
  State<CourseListStudent> createState() => _CourseListStudentState();
}

class _CourseListStudentState extends State<CourseListStudent> {
  late final String _studentId;

  @override
  void initState() {
    super.initState();
    final user = AuthService.instance.currentUser;
    // In this screen we assume only Student comes here.
    _studentId = user?.id ?? '';
  }

  bool _isSelected(String courseId) {
    if (_studentId.isEmpty) return false;
    return FakeDb.isStudentEnrolled(_studentId, courseId);
  }

  int get _totalCredits {
    if (_studentId.isEmpty) return 0;
    final myCourses = FakeDb.getCoursesForStudent(_studentId);
    return myCourses.fold(0, (sum, c) => sum + c.credits);
  }

  void _toggle(String courseId) {
    if (_studentId.isEmpty) return;
    setState(() {
      FakeDb.toggleEnrollment(studentId: _studentId, courseId: courseId);
    });
  }

  void _submit() {
    if (_studentId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No student session found. Please login again.'),
        ),
      );
      return;
    }

    final myCourses = FakeDb.getCoursesForStudent(_studentId);
    if (myCourses.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one course.'),
        ),
      );
      return;
    }

    final credits = _totalCredits;

    if (credits < 12) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Minimum 12 credits required for registration (demo rule).'),
        ),
      );
      return;
    }

    if (credits > 28) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Maximum 28 credits allowed in a semester (demo rule).'),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Registered for ${myCourses.length} course(s), total $credits credits (prototype).',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final credits = _totalCredits;

    if (widget.availableCourses.isEmpty) {
      return const Center(
        child: Text(
          'No courses available for your department this semester.',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Course Registration',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        const Text(
          'Select courses for this semester (demo). Credit limits are applied.',
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.builder(
            itemCount: widget.availableCourses.length,
            itemBuilder: (ctx, index) {
              final c = widget.availableCourses[index];
              final selected = _isSelected(c.id);

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(
                      c.code.split('').take(2).join(),
                      style: const TextStyle(fontSize: 11),
                    ),
                  ),
                  title: Text('${c.code} - ${c.title}'),
                  subtitle: Text(
                    'Sem ${c.semester} • ${c.department} • ${c.credits} credits',
                    style: const TextStyle(fontSize: 12),
                  ),
                  trailing: Checkbox(
                    value: selected,
                    onChanged: (_) => _toggle(c.id),
                  ),
                  onTap: () => _toggle(c.id),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: Text(
                'Total Credits: $credits  (Recommended: 18–24)',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: credits < 12 || credits > 28
                      ? Colors.red
                      : Colors.green,
                ),
              ),
            ),
            ElevatedButton.icon(
              onPressed: _submit,
              icon: const Icon(Icons.check),
              label: const Text('Submit'),
            ),
          ],
        ),
      ],
    );
  }
}

