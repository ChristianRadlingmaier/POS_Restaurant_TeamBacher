import 'package:flutter/material.dart';
import '../widgets/drawer_menu.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final List<Map<String, dynamic>> rewards = [
    {"title": "Gratis Kaffee", "points": 100},
    {"title": "10% Rabatt", "points": 200},
  ];

  final TextEditingController titleController = TextEditingController();
  final TextEditingController pointsController = TextEditingController();

  // Dummy Userliste mit Punkten
  final List<Map<String, dynamic>> users = [
    {"name": "Max Mustermann", "points": 250},
    {"name": "Lisa Müller", "points": 400},
  ];

  void _addReward() {
    if (titleController.text.isNotEmpty && pointsController.text.isNotEmpty) {
      setState(() {
        rewards.add({
          "title": titleController.text,
          "points": int.tryParse(pointsController.text) ?? 0,
        });
      });
      titleController.clear();
      pointsController.clear();
    }
  }

  void _deleteReward(int index) {
    setState(() {
      rewards.removeAt(index);
    });
  }

  void _addPointsToUser(int index, int value) {
    setState(() {
      users[index]["points"] += value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Admin Dashboard")),
      drawer: const DrawerMenu(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("🎁 Belohnungen verwalten", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: "Belohnungstitel"),
              ),
              TextField(
                controller: pointsController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Benötigte Punkte"),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _addReward,
                child: const Text("Belohnung hinzufügen"),
              ),
              const SizedBox(height: 20),
              ...rewards.asMap().entries.map((entry) {
                int index = entry.key;
                var reward = entry.value;
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 5),
                  child: ListTile(
                    title: Text("${reward["title"]} (${reward["points"]} Punkte)"),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteReward(index),
                    ),
                  ),
                );
              }),
              const SizedBox(height: 30),
              const Divider(),
              const SizedBox(height: 10),
              const Text("👤 User Punkteverwaltung", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              ...users.asMap().entries.map((entry) {
                int index = entry.key;
                var user = entry.value;
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 5),
                  child: ListTile(
                    title: Text(user["name"] as String),
                    subtitle: Text("Punkte: ${user["points"]}"),
                    trailing: Wrap(
                      spacing: 10,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.add_circle, color: Colors.green),
                          onPressed: () => _addPointsToUser(index, 50),
                        ),
                        IconButton(
                          icon: const Icon(Icons.remove_circle, color: Colors.orange),
                          onPressed: () => _addPointsToUser(index, -50),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
