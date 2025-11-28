import 'package:flutter/material.dart';

import '../models/app_user.dart';
import '../services/auth_service.dart';

/// All sections that can be opened from the drawer.
/// HomeScreen v3 switches on this enum.
enum DrawerSection {
  dashboard,
  profile,
  notices,
  courseRegistration,
  manageCourses,
  students,
  faculty,
  departments,
  approvals,
  history,
  settings,
}

class AppDrawer extends StatelessWidget {
  final AppUser user;
  final DrawerSection selected;
  final void Function(DrawerSection) onSelect;

  const AppDrawer({
    super.key,
    required this.user,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final role = user.role;

    final List<Widget> items = [];

    void addItem(DrawerSection section, String title, IconData icon) {
      final isActive = selected == section;
      items.add(
        ListTile(
          leading: Icon(
            icon,
            color: isActive ? Theme.of(context).colorScheme.primary : null,
          ),
          title: Text(
            title,
            style: TextStyle(
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
          selected: isActive,
          onTap: () => onSelect(section),
        ),
      );
    }

    // Common items for all roles
    addItem(DrawerSection.dashboard, 'Dashboard', Icons.dashboard_outlined);
    addItem(DrawerSection.profile, 'My Profile', Icons.person_outline);
    addItem(DrawerSection.notices, 'Notices', Icons.campaign_outlined);

    // Role-specific items
    if (role == UserRole.student) {
      addItem(DrawerSection.courseRegistration,
          'Course Registration', Icons.app_registration_rounded);
      addItem(
          DrawerSection.history, 'Registration History', Icons.history_rounded);
    } else {
      addItem(DrawerSection.manageCourses,
          'Manage Courses', Icons.menu_book_outlined);
    }

    if (role == UserRole.academic || role == UserRole.hod) {
      addItem(DrawerSection.students, 'Students', Icons.groups_outlined);
      addItem(DrawerSection.faculty, 'Faculty', Icons.school_outlined);
    }

    if (role == UserRole.academic) {
      addItem(
          DrawerSection.departments, 'Departments', Icons.business_outlined);
      addItem(DrawerSection.approvals, 'Pending Approvals',
          Icons.playlist_add_check_rounded);
    } else if (role == UserRole.hod) {
      addItem(DrawerSection.approvals, 'Pending Approvals',
          Icons.playlist_add_check_rounded);
    }

    addItem(DrawerSection.settings, 'Settings', Icons.settings_outlined);

    return Drawer(
      child: Column(
        children: [
          _buildHeader(context),
          const SizedBox(height: 8),
          ...items,
          const Spacer(),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.logout_rounded),
            title: const Text('Logout'),
            onTap: () async {
              // Proper logout using AuthService like App 1
              await AuthService.instance.logout();
              if (!context.mounted) return;
              Navigator.of(context)
                  .pushNamedAndRemoveUntil('/login', (route) => false);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0052CC), Color(0xFF2563EB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          child: Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: Colors.white.withOpacity(0.1),
                child: Text(
                  user.name.substring(0, 1).toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${user.roleLabel} • ${user.department}',
                      maxLines: 2,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

