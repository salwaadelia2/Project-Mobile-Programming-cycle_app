import 'package:flutter/material.dart';
import 'package:project_uts/login.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '🌸 Siklus Menstruasi',
      theme: ThemeData(
        primarySwatch: Colors.pink,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFF8BBD0),
          primary: const Color(0xFFF48FB1),
          secondary: const Color(0xFFFCE4EC),
        ),
      ),
      home: const Login(),
    );
  }
}