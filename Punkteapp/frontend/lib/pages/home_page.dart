import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/drawer_menu.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const String baseUrl = "http://192.168.5.155:8080";
  int points = 0;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadMe();
  }

  Future<void> _loadMe() async {
    setState(() => loading = true);
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    if (token == null) {
      setState(() => loading = false);
      return;
    }

    final url = Uri.parse("$baseUrl/api/user/me");

    try {
      final res = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (res.statusCode == 200) {
        final json = jsonDecode(res.body);

        // ⚠️ Passen: Feldnamen im Backend (z.B. "points" oder "bonusPoints")
        setState(() {
          points = json["points"] ?? 0;
        });
      } else {
        // Fehlerbehandlung optional
      }
    } catch (_) {
      // Optional: Fehler loggen
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Meine Punkte")),
      drawer: const DrawerMenu(),
      body: Center(
        child: loading
            ? const CircularProgressIndicator()
            : Column(
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
