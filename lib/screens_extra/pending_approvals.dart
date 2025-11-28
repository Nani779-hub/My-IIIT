import 'package:flutter/material.dart';
import '../data/registration.dart';

class PendingApprovals extends StatelessWidget {
  const PendingApprovals({super.key});

  @override
  Widget build(BuildContext context) {
    final pending = registrations
        .where((r) => r.status == RegistrationStatus.pending)
        .toList();

    if (pending.isEmpty) {
      return const Center(
        child: Text(
          'No pending registration approvals.',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Pending Approvals',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        const Text(
          'Prototype view of registration requests waiting for approval.',
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.builder(
            itemCount: pending.length,
            itemBuilder: (ctx, i) {
              final r = pending[i];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: ListTile(
                  leading: const Icon(Icons.pending_actions_outlined),
                  title: Text('Roll: ${r.roll}'),
                  subtitle: Text(
                    'Semester ${r.semester} • ${r.credits} credits',
                    style: const TextStyle(fontSize: 12),
                  ),
                  trailing: const Text(
                    'Pending',
                    style: TextStyle(color: Colors.orange),
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

