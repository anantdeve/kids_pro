import 'package:go_router/go_router.dart';
import '../../presentation/splash/screens/splash_screen.dart';
import '../../presentation/home/screens/main_screen.dart';
import '../../presentation/learning/screens/abc_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const MainScreen(),
    ),
    GoRoute(
      path: '/abc',
      builder: (context, state) => const AbcScreen(),
    ),
    // TODO: Add other routes here (numbers, colors, animals, etc.)
  ],
);
