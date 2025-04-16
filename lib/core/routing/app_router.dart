import 'package:go_router/go_router.dart';
import 'package:life_weeks/features/life_calendar/presentation/calendar_screen.dart';
import 'package:life_weeks/features/splash/presentation/splash_screen.dart';
import 'package:life_weeks/features/welcome/presentation/welcome_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: SplashScreen.routeName,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: WelcomeScreen.routeName,
      builder: (context, state) => const WelcomeScreen(),
    ),
    GoRoute(
      path: CalendarScreen.routeName,
      builder: (context, state) => CalendarScreen(
        birthDate: null,
        onChangeDate: () {},
      ),
    ),
  ],
);

