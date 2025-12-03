import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class StudentRecord {
  final int id;
  final String rollNo;
  final String name;
  final String department;
  final int semester;

  StudentRecord({
    required this.id,
    required this.rollNo,
    required this.name,
    required this.department,
    required this.semester,
  });
}

class StudentDb {
  StudentDb._();
  static final StudentDb instance = StudentDb._();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'my_iiit_students.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE students (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            roll_no TEXT UNIQUE,
            name TEXT,
            department TEXT,
            semester INTEGER,
            password TEXT
          )
        ''');
      },
    );
  }

  /// Seed 4000 demo students only if table is empty
  Future<void> seedDemoStudentsIfEmpty() async {
    final db = await database;
    final countResult =
        await db.rawQuery('SELECT COUNT(*) AS cnt FROM students');
    final count = (countResult.first['cnt'] as int?) ?? 0;

    if (count > 0) {
      // Already seeded
      return;
    }

    final batch = db.batch();

    for (var i = 1; i <= 4000; i++) {
      final roll =
          'CS24B${i.toString().padLeft(4, '0')}'; // CS24B0001 ... CS24B4000
      final dept = (i % 4 == 0)
          ? 'ECE'
          : (i % 3 == 0)
              ? 'CSE-AI&DS'
              : 'CSE';
      final sem = (i % 8) + 1;

      batch.insert('students', {
        'roll_no': roll,
        'name': 'Student $i',
        'department': dept,
        'semester': sem,
        'password': 'pass$sem',
      });
    }

    await batch.commit(noResult: true);
  }

  Future<int> getStudentCount() async {
    final db = await database;
    final res = await db.rawQuery('SELECT COUNT(*) AS cnt FROM students');
    return (res.first['cnt'] as int?) ?? 0;
  }

  /// 🔹 New: get students semester-wise (and optionally department-wise)
  Future<List<StudentRecord>> getStudents({
    String? department,
    int? semester,
    int limit = 200,
  }) async {
    final db = await database;

    final where = <String>[];
    final whereArgs = <Object?>[];

    if (department != null) {
      where.add('department = ?');
      whereArgs.add(department);
    }
    if (semester != null) {
      where.add('semester = ?');
      whereArgs.add(semester);
    }

    final res = await db.query(
      'students',
      where: where.isEmpty ? null : where.join(' AND '),
      whereArgs: whereArgs.isEmpty ? null : whereArgs,
      orderBy: 'semester ASC, roll_no ASC',
      limit: limit, // to avoid loading all 4000 at once on screen
    );

    return res
        .map(
          (row) => StudentRecord(
            id: row['id'] as int,
            rollNo: row['roll_no'] as String,
            name: row['name'] as String,
            department: row['department'] as String,
            semester: row['semester'] as int,
          ),
        )
        .toList();
  }

  /// Optional helper to see first N students (not used now)
  Future<List<StudentRecord>> getSampleStudents({int limit = 20}) async {
    final db = await database;
    final res = await db.query(
      'students',
      orderBy: 'id ASC',
      limit: limit,
    );
    return res
        .map(
          (row) => StudentRecord(
            id: row['id'] as int,
            rollNo: row['roll_no'] as String,
            name: row['name'] as String,
            department: row['department'] as String,
            semester: row['semester'] as int,
          ),
        )
        .toList();
  }
}

