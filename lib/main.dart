import 'package:flutter/material.dart';
import 'pages/home_page.dart';

void main() {
  runApp(const DualViewApp());
}

class DualViewApp extends StatelessWidget {
  const DualViewApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DualView',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF1E1E1E),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}
