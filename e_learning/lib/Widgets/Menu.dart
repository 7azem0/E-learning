// ignore_for_file: deprecated_member_use, file_names

import 'package:flutter/material.dart';
import '../services/authentication_service.dart';

class Menu extends StatelessWidget {
  const Menu({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Modern Drawer Header
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF6366F1),
                  const Color(0xFF8B5CF6),
                ],
              ),
            ),
            child: DrawerHeader(
              decoration: const BoxDecoration(color: Colors.transparent),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(Icons.person, size: 40, color: Colors.white),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    AuthService().currentUser?.name ?? "User",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AuthService().currentUser?.email ?? "",
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Navigation Items
          _DrawerMenuItem(
            icon: Icons.home_outlined,
            label: "Home",
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/home');
            },
          ),
          _DrawerMenuItem(
            icon: Icons.school_outlined,
            label: "Courses",
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/courses');
            },
          ),
          _DrawerMenuItem(
            icon: Icons.person_outline,
            label: "Profile",
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/profile');
            },
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Divider(height: 1),
          ),

          // Logout
          _DrawerMenuItem(
            icon: Icons.logout_outlined,
            label: "Logout",
            isDestructive: true,
            onTap: () {
              Navigator.pop(context);
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  title: const Text('Logout'),
                  content: const Text('Are you sure you want to logout?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        await AuthService().logout();
                        if (context.mounted) {
                          Navigator.pop(context);
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            '/login',
                            (route) => false,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade400,
                      ),
                      child: const Text('Logout'),
                    ),
                  ],
                ),
              );
            },
          ),

          const Spacer(),

          // Footer
          Padding(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: Text(
                'EduHub v1.0',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade500,
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DrawerMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  const _DrawerMenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        leading: Icon(
          icon,
          color: isDestructive ? Colors.red.shade400 : const Color(0xFF6366F1),
        ),
        title: Text(
          label,
          style: TextStyle(
            color: isDestructive ? Colors.red.shade400 : Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
        onTap: onTap,
        hoverColor: isDestructive
            ? Colors.red.shade50
            : const Color(0xFF6366F1).withOpacity(0.1),
      ),
    );
  }
}