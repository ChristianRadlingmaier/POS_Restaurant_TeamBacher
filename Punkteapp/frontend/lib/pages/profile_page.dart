import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/drawer_menu.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  static const String baseUrl = "http://localhost:8080";

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  bool loading = true;
  bool saving = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
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

        // ⚠️ Feldnamen anpassen: z.B. "firstname"/"lastname"
        final firstName = json["firstname"] ?? "";
        final lastName = json["lastname"] ?? "";
        final email = json["email"] ?? "";

        setState(() {
          nameController.text = "$firstName $lastName".trim();
          emailController.text = email;
        });
      }
    } catch (_) {
      // Fehler optional
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  Future<void> _saveProfile() async {
    setState(() => saving = true);

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    if (token == null) {
      setState(() => saving = false);
      return;
    }

    final parts = nameController.text.trim().split(" ");
    final firstName = parts.isNotEmpty ? parts.first : "";
    final lastName = parts.length > 1 ? parts.sublist(1).join(" ") : "";

    final url = Uri.parse("$baseUrl/api/user/profile");

    try {
      final res = await http.put(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          // ⚠️ an dein DTO anpassen
          "firstname": firstName,
          "lastname": lastName,
          "email": emailController.text.trim(),
        }),
      );

      if (!mounted) return;

      if (res.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profil gespeichert.")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Speichern fehlgeschlagen.")),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Fehler: $e")),
      );
    } finally {
      if (mounted) {
        setState(() => saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Profil")),
      drawer: const DrawerMenu(),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Name"),
            ),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: "E-Mail"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: saving ? null : _saveProfile,
              child: saving
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Änderungen speichern"),
            ),
          ],
        ),
      ),
    );
  }
}
