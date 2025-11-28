import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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

  Future<void> register() async {
    setState(() => loading = true);

    final url = Uri.parse("http://192.168.5.155:8080/api/auth/register");
    // ↑ DEINE IPv4 eintragen

    final body = jsonEncode({
      "firstname": nameController.text.split(" ").first,
      "lastname": nameController.text.contains(" ")
          ? nameController.text.split(" ").last
          : "",
      "email": emailController.text,
      "password": passwordController.text,
    });


    final res = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: body,
    );

    setState(() => loading = false);

    if (res.statusCode == 200) {
      final json = jsonDecode(res.body);

      print("TOKEN: ${json["token"]}");

      Navigator.pushReplacementNamed(context, "/home");
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Registrierung fehlgeschlagen")),
      );
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
