import 'package:flutter/material.dart';
import 'app_shell.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const MayfairApp());
}

class MayfairApp extends StatelessWidget {
  const MayfairApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mayfair Rwanda',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const AppShell(),
    );
  }
}
