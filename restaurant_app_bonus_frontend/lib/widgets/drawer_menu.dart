import 'package:flutter/material.dart';

class DrawerMenu extends StatelessWidget {
  const DrawerMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.deepPurple),
            child: Text("Bonus App Menü", style: TextStyle(color: Colors.white, fontSize: 20)),
          ),
          ListTile(
            title: const Text("Startseite"),
            onTap: () => Navigator.pushReplacementNamed(context, '/home'),
          ),
          ListTile(
            title: const Text("Belohnungen"),
            onTap: () => Navigator.pushReplacementNamed(context, '/rewards'),
          ),
          ListTile(
            title: const Text("Profil"),
            onTap: () => Navigator.pushReplacementNamed(context, '/profile'),
          ),
          ListTile(
            title: const Text("Abmelden"),
            onTap: () => Navigator.pushReplacementNamed(context, '/login'),
          ),
          ListTile(
            title: const Text("Admin Dashboard"),
            onTap: () => Navigator.pushReplacementNamed(context, '/admin'),
          ),
        ],
      ),
    );
  }
}
