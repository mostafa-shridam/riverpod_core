import 'package:go_router/go_router.dart';
import 'package:riverpod_core/features/home/presentation/home.dart';

class AppRouter {
  static final AppRouter instance = AppRouter._();

  AppRouter._();

  final GoRouter router = GoRouter(
    initialLocation: HomePage.routeName,
    routes: [
      GoRoute(
        path: HomePage.routeName,
        name: HomePage.routeName,
        builder: (context, state) => const HomePage(),
      ),
    ],
  );
}
