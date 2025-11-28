import 'package:flutter/material.dart';
import 'pages/login_page.dart';
import 'pages/register_page.dart';
import 'pages/home_page.dart';
import 'pages/rewards_page.dart';
import 'pages/profile_page.dart';
import 'pages/admin_page.dart';

void main() {
  runApp(const BonusRestaurantApp());
}

class BonusRestaurantApp extends StatelessWidget {
  const BonusRestaurantApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bonus Restaurant App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/home': (context) => const HomePage(),
        '/rewards': (context) => const RewardsPage(),
        '/profile': (context) => const ProfilePage(),
        '/admin': (context) => const AdminPage(),
      },
    );
  }
}
