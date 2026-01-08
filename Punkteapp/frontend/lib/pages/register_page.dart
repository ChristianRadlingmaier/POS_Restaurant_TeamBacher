import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool loading = false;

  static const String baseUrl = "localhost:8080";

  Future<void> register() async {
    setState(() => loading = true);

    final url = Uri.parse("$baseUrl/api/auth/register");

    final body = jsonEncode({
      "firstname": nameController.text.split(" ").first,
      "lastname": nameController.text.contains(" ")
          ? nameController.text.split(" ").last
          : "",
      "email": emailController.text.trim(),
      "password": passwordController.text.trim(),
    });
    print(body);

    try {
      final res = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: body,
      );

      if (res.statusCode == 200) {
        final json = jsonDecode(res.body);
        final token = json["token"];

        if (token != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString("token", token);
        }

        if (!mounted) return;
        Navigator.pushReplacementNamed(context, "/home");
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Registrierung fehlgeschlagen")),
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
      appBar: AppBar(title: const Text("Registrierung")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Name"),
            ),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: "E-Mail"),
            ),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: "Passwort"),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: loading ? null : register,
              child: loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Registrieren"),
            ),
          ],
        ),
      ),
    );
  }
}
