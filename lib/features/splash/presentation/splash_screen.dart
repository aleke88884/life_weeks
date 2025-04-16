import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:life_weeks/features/life_calendar/presentation/calendar_screen.dart';
import 'package:life_weeks/features/welcome/presentation/welcome_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  static const String routeName = '/splash';

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    // Запускаем анимацию и навигацию по её завершении
    _controller.forward().then((_) => _navigateNext());
  }

  Future<void> _navigateNext() async {
    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();
    final hasSeenWelcome = prefs.getBool('hasSeenWelcome') ?? false;

    if (!mounted) return;
    if (hasSeenWelcome) {
      context.go(CalendarScreen.routeName);
    } else {
      context.go(WelcomeScreen.routeName);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E2F),
      body: Stack(
        alignment: Alignment.center,
        children: [
          Center(
            child: Padding(
              padding: EdgeInsets.only(left: 16, right: 16, top: 100.h),
              child: _buildGrid(),
            ),
          ),
          Center(
            child: Container(
              width: 200.w,
              height: 250.h,
              decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.circular(16.r), // можно поэкспериментировать
                image: const DecorationImage(
                  image: AssetImage('assets/img/icon.png'),
                  fit: BoxFit.cover,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildGrid() {
    const totalSquares = 500;
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(), // Отключаем прокрутку
      itemCount: totalSquares,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 30,
        mainAxisSpacing: 2,
        crossAxisSpacing: 2,
      ),
      itemBuilder: (context, index) {
        return FadeTransition(
          opacity: _animation,
          child: Container(
            width: 4.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: Colors.white
                  .withValues(alpha: (index / totalSquares).clamp(0.8, 1)),
              borderRadius: BorderRadius.circular(4.r),
            ),
          ),
        );
      },
    );
  }
}
