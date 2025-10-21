import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Anmeldung")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const TextField(
              decoration: InputDecoration(labelText: "E-Mail"),
            ),
            const TextField(
              decoration: InputDecoration(labelText: "Passwort"),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              // ⬇️ führt nach erfolgreichem Login direkt zur RewardsPage
              onPressed: () => Navigator.pushReplacementNamed(context, '/rewards'),
              child: const Text("Einloggen"),
            ),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/register'),
              child: const Text("Noch kein Konto? Registrieren"),
            ),
          ],
        ),
      ),
    );
  }
}
