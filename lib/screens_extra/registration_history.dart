import 'package:flutter/material.dart';
import '../data/registration.dart';

class RegistrationHistory extends StatelessWidget {
  final String roll;

  const RegistrationHistory({super.key, required this.roll});

  Color _statusColor(RegistrationStatus status) {
    switch (status) {
      case RegistrationStatus.pending:
        return Colors.orange;
      case RegistrationStatus.hodApproved:
        return Colors.blue;
      case RegistrationStatus.academicApproved:
        return Colors.green;
    }
  }

  String _statusText(RegistrationStatus status) {
    switch (status) {
      case RegistrationStatus.pending:
        return 'Pending';
      case RegistrationStatus.hodApproved:
        return 'HOD Approved';
      case RegistrationStatus.academicApproved:
        return 'Academic Approved';
    }
  }

  @override
  Widget build(BuildContext context) {
    final myRegs = registrations.where((r) => r.roll == roll).toList();

    if (myRegs.isEmpty) {
      return const Center(
        child: Text(
          'No registration history found for this roll.',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Registration History',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          'Roll: $roll',
          style: const TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.builder(
            itemCount: myRegs.length,
            itemBuilder: (ctx, i) {
              final r = myRegs[i];
              final color = _statusColor(r.status);
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: color.withOpacity(0.1),
                    child: Icon(Icons.app_registration_rounded, color: color),
                  ),
                  title: Text('Semester ${r.semester}'),
                  subtitle: Text('Total credits: ${r.credits}'),
                  trailing: Chip(
                    label: Text(
                      _statusText(r.status),
                      style: const TextStyle(fontSize: 11),
                    ),
                    backgroundColor: color.withOpacity(0.12),
                    side: BorderSide(color: color.withOpacity(0.4)),
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

