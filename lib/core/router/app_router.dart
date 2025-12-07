import 'package:go_router/go_router.dart';
import '../../features/home/presentation/screens/main_layout.dart';

// Configuración simple del router
final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const MainLayout(),
    ),
  ],
);
