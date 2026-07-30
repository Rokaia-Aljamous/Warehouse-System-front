import 'package:flutter/material.dart';
import 'features/auth/views/login_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Warehouse Hub',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Inter',
        scaffoldBackgroundColor: const Color(0xFF1E3A5F),
      ),
      home: const LoginView(),
    );
  }
}