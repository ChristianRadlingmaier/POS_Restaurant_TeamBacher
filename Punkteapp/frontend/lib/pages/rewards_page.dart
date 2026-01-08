import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/drawer_menu.dart';

class RewardsPage extends StatefulWidget {
  const RewardsPage({super.key});

  @override
  State<RewardsPage> createState() => _RewardsPageState();
}

class _RewardsPageState extends State<RewardsPage> {
  static const String baseUrl = "http://localhost:8080";

  List<Map<String, dynamic>> rewards = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadRewards();
  }

  Future<void> _loadRewards() async {
    setState(() => loading = true);
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    if (token == null) {
      setState(() => loading = false);
      return;
    }

    final url = Uri.parse("$baseUrl/api/user/rewards");

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

        // ⚠️ Passen je nach Backend-Struktur
        rewards = data.map((e) {
          return {
            "id": e["id"],
            "title": e["title"] ?? e["name"] ?? "Belohnung",
            "points": e["points"] ?? e["requiredPoints"] ?? 0,
            "desc": e["description"] ?? "",
          };
        }).toList();

        setState(() {});
      } else {
        // Fehlerbehandlung optional
      }
    } catch (_) {
      // Fehlerbehandlung
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  Future<void> _redeemReward(Map<String, dynamic> reward) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    if (token == null) return;

    final url = Uri.parse("$baseUrl/api/user/redeem");

    try {
      final res = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          // ⚠️ an Backend anpassen: z.B. "rewardId"
          "rewardId": reward["id"],
        }),
      );

      if (!mounted) return;

      if (res.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("${reward["title"]} wurde eingelöst!")),
        );
        _loadRewards(); // optional neu laden
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Einlösen fehlgeschlagen.")),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Fehler: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Belohnungen")),
      drawer: const DrawerMenu(),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
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
                onPressed: () => _redeemReward(reward),
                child: const Text("Einlösen"),
              ),
            ),
          );
        },
      ),
    );
  }
}
