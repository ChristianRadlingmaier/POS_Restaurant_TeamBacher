import 'package:flutter/material.dart';
import '../widgets/drawer_menu.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Profil")),
      drawer: const DrawerMenu(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: const [
            TextField(decoration: InputDecoration(labelText: "Name")),
            TextField(decoration: InputDecoration(labelText: "E-Mail")),
            SizedBox(height: 20),
            ElevatedButton(onPressed: null, child: Text("Änderungen speichern")),
          ],
        ),
      ),
    );
  }
}
