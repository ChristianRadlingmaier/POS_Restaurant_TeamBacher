import 'package:flutter/material.dart';
import '../widgets/drawer_menu.dart';

class RewardsPage extends StatelessWidget {
  const RewardsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 🔹 Dummy-Daten (5 Belohnungen)
    final List<Map<String, dynamic>> rewards = [
      {"title": "Gratis Kaffee", "points": 100, "desc": "Genieße einen kostenlosen Kaffee bei deinem nächsten Besuch."},
      {"title": "10% Rabatt", "points": 200, "desc": "Erhalte 10% Rabatt auf deine gesamte Rechnung."},
      {"title": "Gratis Dessert", "points": 300, "desc": "Wähle ein Dessert deiner Wahl kostenlos aus."},
      {"title": "Gratis Getränk", "points": 150, "desc": "Ein kostenloses Getränk deiner Wahl zum Menü."},
      {"title": "20% Rabatt auf das Menü", "points": 500, "desc": "Erhalte 20% Rabatt auf dein gesamtes Menü."},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("Belohnungen")),
      drawer: const DrawerMenu(),
      body: ListView.builder(
        itemCount: rewards.length,
        itemBuilder: (context, index) {
          final reward = rewards[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            elevation: 3,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              title: Text(
                reward["title"] as String,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              subtitle: Text(
                "${reward["points"]} Punkte\n${reward["desc"]}",
                style: const TextStyle(height: 1.4),
              ),
              isThreeLine: true,
              trailing: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("${reward["title"]} wurde eingelöst!")),
                  );
                },
                child: const Text("Einlösen"),
              ),
            ),
          );
        },
      ),
    );
  }
}
