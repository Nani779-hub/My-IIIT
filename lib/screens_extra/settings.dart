import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    bool dummyNotif = true;
    bool dummyDark = false;

    return StatefulBuilder(
      builder: (ctx, setState) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Settings',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              'Prototype settings. In full system, this will connect to user preferences.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Card(
              child: SwitchListTile(
                title: const Text('Enable notifications'),
                subtitle:
                    const Text('Receive academic & registration alerts.'),
                value: dummyNotif,
                onChanged: (v) => setState(() => dummyNotif = v),
              ),
            ),
            const SizedBox(height: 8),
            Card(
              child: SwitchListTile(
                title: const Text('Dark mode (placeholder)'),
                subtitle:
                    const Text('UI theme preference (for future version).'),
                value: dummyDark,
                onChanged: (v) => setState(() => dummyDark = v),
              ),
            ),
            const SizedBox(height: 8),
            const Card(
              child: Padding(
                padding: EdgeInsets.all(12.0),
                child: Text(
                  'Note: This is a demo settings page. In the real system, these values\n'
                  'would be stored in the backend or local secure storage.',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

