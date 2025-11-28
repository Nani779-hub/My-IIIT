import 'package:flutter/material.dart';
import '../data/notices.dart';

class NoticesScreen extends StatelessWidget {
  const NoticesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (noticeDb.isEmpty) {
      return const Center(
        child: Text(
          'No notices available.',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Notices',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        const Text(
          'Official updates related to registration, exams and campus.',
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.builder(
            itemCount: noticeDb.length,
            itemBuilder: (ctx, index) {
              final n = noticeDb[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: ListTile(
                  title: Text(n.title),
                  subtitle: Text(
                    'Published on: ${n.date}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  leading: const Icon(Icons.campaign_outlined),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

