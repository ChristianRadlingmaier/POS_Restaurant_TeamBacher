import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool loading = false;

  static const String baseUrl = "http://localhost:8080";

  Future<void> login() async {
    setState(() => loading = true);

    final url = Uri.parse("$baseUrl/api/auth/login");

    final body = jsonEncode({
      "email": emailController.text.trim(),
      "password": passwordController.text.trim(),
    });

    try {
      final res = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: body,
      );

      if (res.statusCode == 200) {
        final json = jsonDecode(res.body);

        final token = json["token"];
        final role = json["role"]; // optional, falls dein Backend das liefert
        if (token == null) throw Exception("Kein Token erhalten.");

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("token", token);
        if (role != null) {
          await prefs.setString("role", role.toString());
        }

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Login erfolgreich!")),
        );

        // Optional: Admin direkt ins Admin-Dashboard
        if (role == "ADMIN") {
          Navigator.pushReplacementNamed(context, "/admin");
        } else {
          Navigator.pushReplacementNamed(context, "/home");
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Falsche E-Mail oder Passwort.")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Fehler: $e")),
      );
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Anmeldung")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: "E-Mail"),
            ),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Passwort"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: loading ? null : login,
              child: loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Einloggen"),
            ),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, "/register"),
              child: const Text("Noch kein Konto? Registrieren"),
            ),
          ],
        ),
      ),
    );
  }
}
