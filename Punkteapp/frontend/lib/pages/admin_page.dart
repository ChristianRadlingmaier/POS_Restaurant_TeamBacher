import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/drawer_menu.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  static const String baseUrl = "http://192.168.5.155:8080";

  List<Map<String, dynamic>> rewards = [];
  List<Map<String, dynamic>> users = [];

  final TextEditingController titleController = TextEditingController();
  final TextEditingController pointsController = TextEditingController();

  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }

  Future<void> _loadData() async {
    setState(() => loading = true);
    await Future.wait([_loadRewards(), _loadUsers()]);
    if (mounted) setState(() => loading = false);
  }

  Future<void> _loadRewards() async {
    final token = await _getToken();
    if (token == null) return;

    // ⚠️ Wenn dein Backend keinen GET /rewards hat, ggf. anpassen
    final url = Uri.parse("$baseUrl/api/admin/rewards");

    try {
      final res = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (res.statusCode == 200) {
        final List<dynamic> data = jsonDecode(res.body);
        setState(() {
          rewards = data.map((e) {
            return {
              "id": e["id"],
              "title": e["title"] ?? e["name"] ?? "Belohnung",
              "points": e["points"] ?? e["requiredPoints"] ?? 0,
            };
          }).toList();
        });
      }
    } catch (_) {}
  }

  Future<void> _loadUsers() async {
    final token = await _getToken();
    if (token == null) return;

    final url = Uri.parse("$baseUrl/api/admin/users");

    try {
      final res = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (res.statusCode == 200) {
        final List<dynamic> data = jsonDecode(res.body);
        setState(() {
          users = data.map((u) {
            final firstName = u["firstname"] ?? "";
            final lastName = u["lastname"] ?? "";
            return {
              "id": u["id"],
              "name": "$firstName $lastName".trim(),
              "points": u["points"] ?? 0,
            };
          }).toList();
        });
      }
    } catch (_) {}
  }

  Future<void> _addReward() async {
    if (titleController.text.isEmpty || pointsController.text.isEmpty) return;

    final token = await _getToken();
    if (token == null) return;

    final url = Uri.parse("$baseUrl/api/admin/rewards");

    try {
      final res = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "title": titleController.text.trim(),
          "points": int.tryParse(pointsController.text) ?? 0,
          // ggf. description o.ä. ergänzen
        }),
      );

      if (res.statusCode == 200 || res.statusCode == 201) {
        titleController.clear();
        pointsController.clear();
        _loadRewards();
      }
    } catch (_) {}
  }

  Future<void> _deleteReward(int index) async {
    final token = await _getToken();
    if (token == null) return;

    final reward = rewards[index];
    final id = reward["id"];
    if (id == null) return;

    final url = Uri.parse("$baseUrl/api/admin/rewards/$id");

    try {
      final res = await http.delete(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (res.statusCode == 200 || res.statusCode == 204) {
        setState(() {
          rewards.removeAt(index);
        });
      }
    } catch (_) {}
  }

  Future<void> _addPointsToUser(int index, int delta) async {
    final token = await _getToken();
    if (token == null) return;

    final user = users[index];
    final id = user["id"];
    if (id == null) return;

    final newPoints = (user["points"] as int) + delta;

    final url = Uri.parse("$baseUrl/api/admin/users/$id/points");

    try {
      final res = await http.put(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          // ⚠️ an dein Backend anpassen:
          // z.B. {"points": newPoints}
          "points": newPoints,
        }),
      );

      if (res.statusCode == 200) {
        setState(() {
          users[index]["points"] = newPoints;
        });
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Admin Dashboard")),
      drawer: const DrawerMenu(),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("🎁 Belohnungen verwalten",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
              const Text("👤 User Punkteverwaltung",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
