import 'package:flutter/material.dart';
import 'package:life_weeks/core/constants/app_contstants.dart';
import 'package:life_weeks/features/life_calendar/presentation/welcome_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Life Weeks Calendar',
      theme: AppContstants.customTheme,
      home: const WelcomeScreen(),
    );
  }
}
