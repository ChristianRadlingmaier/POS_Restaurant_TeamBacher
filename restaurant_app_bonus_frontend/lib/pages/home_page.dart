import 'package:flutter/material.dart';
import '../widgets/drawer_menu.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    int points = 150; // Beispielwert

    return Scaffold(
      appBar: AppBar(title: const Text("Meine Punkte")),
      drawer: const DrawerMenu(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Gesammelte Punkte", style: TextStyle(fontSize: 22)),
            const SizedBox(height: 10),
            Text(
              "$points",
              style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/rewards'),
              child: const Text("Belohnungen ansehen"),
            ),
          ],
        ),
      ),
    );
  }
}
