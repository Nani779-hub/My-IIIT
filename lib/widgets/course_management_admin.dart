import 'package:flutter/material.dart';

import '../models/course.dart';
import '../models/app_user.dart';    
import '../services/fake_db.dart';   


class CourseManagementAdmin extends StatefulWidget {
  final List<Course> courses;
  final String roleLabel;

  const CourseManagementAdmin({
    super.key,
    required this.courses,
    required this.roleLabel,
  });

  @override
  State<CourseManagementAdmin> createState() => _CourseManagementAdminState();
}

class _CourseManagementAdminState extends State<CourseManagementAdmin> {
  String _search = '';

  final _codeCtrl = TextEditingController();
  final _titleCtrl = TextEditingController();
  final _deptCtrl = TextEditingController();
  final _semCtrl = TextEditingController(text: '1');
  final _creditCtrl = TextEditingController(text: '3');

  @override
  void dispose() {
    _codeCtrl.dispose();
    _titleCtrl.dispose();
    _deptCtrl.dispose();
    _semCtrl.dispose();
    _creditCtrl.dispose();
    super.dispose();
  }

  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Add Course'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                _field(_codeCtrl, 'Course Code'),
                _field(_titleCtrl, 'Course Title'),
                _field(_deptCtrl, 'Department (CSE / ECE / AI-DS etc)'),
                _field(_semCtrl, 'Semester', isNum: true),
                _field(_creditCtrl, 'Credits', isNum: true),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                _clear();
                Navigator.pop(ctx);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                _addCourse();
                Navigator.pop(ctx);
              },
              child: const Text('Add'),
            )
          ],
        );
      },
    );
  }

  Widget _field(TextEditingController c, String hint, {bool isNum = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: c,
        keyboardType: isNum ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(labelText: hint),
      ),
    );
  }

  void _clear() {
    _codeCtrl.clear();
    _titleCtrl.clear();
    _deptCtrl.clear();
    _semCtrl.text = '1';
    _creditCtrl.text = '3';
  }

  void _addCourse() {
    if (_codeCtrl.text.trim().isEmpty || _titleCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Code & title required')),
      );
      return;
    }

    final course = Course(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      code: _codeCtrl.text.trim(),
      title: _titleCtrl.text.trim(),
      department: _deptCtrl.text.trim(),
      semester: int.tryParse(_semCtrl.text) ?? 1,
      credits: int.tryParse(_creditCtrl.text) ?? 3,
    );

    FakeDb.courses.add(course);
    setState(() {});
    _clear();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Course ${course.code} added')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final visibleCourses = widget.courses.where((c) {
      if (_search.isEmpty) return true;
      final q = _search.toLowerCase();
      return c.code.toLowerCase().contains(q) ||
          c.title.toLowerCase().contains(q) ||
          c.department.toLowerCase().contains(q);
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${widget.roleLabel} – Manage Courses',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        const Text(
          'Add, view, or organize department-wise courses (demo).',
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 16),

        // Search + Add
        Row(
          children: [
            Expanded(
              child: TextField(
                decoration: const InputDecoration(
                  hintText: 'Search by code, title, department',
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (v) => setState(() => _search = v),
              ),
            ),
            const SizedBox(width: 8),
            FilledButton.icon(
              onPressed: _showAddDialog,
              icon: const Icon(Icons.add),
              label: const Text('Add'),
            )
          ],
        ),

        const SizedBox(height: 12),

        // Course List
        Expanded(
          child: visibleCourses.isEmpty
              ? const Center(
                  child: Text(
                    'No courses match your filter.',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  itemCount: visibleCourses.length,
                  itemBuilder: (ctx, i) {
                    final c = visibleCourses[i];

                    final enrolled = FakeDb.users
                        .where((u) => u.role == UserRole.student)
                        .where((s) => FakeDb.isStudentEnrolled(s.id, c.id))
                        .length;

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: ListTile(
                        title: Text('${c.code} - ${c.title}'),
                        subtitle: Text(
                          'Sem ${c.semester} • ${c.department} • ${c.credits} credits\n'
                          'Enrolled: $enrolled students',
                          style: const TextStyle(fontSize: 12),
                        ),
                        trailing: Wrap(
                          spacing: 10,
                          children: const [
                            Icon(Icons.edit_outlined),
                            Icon(Icons.delete_outline),
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
}

