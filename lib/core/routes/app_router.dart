import 'package:jobfy/features/auth/presentation/pages/login_page.dart';
import 'package:jobfy/features/auth/presentation/pages/register_page.dart';
import 'package:jobfy/features/home/presentation/pages/home_page.dart';
import 'package:jobfy/features/user/presentation/pages/user_area_page.dart';
import 'package:jobfy/features/company/presentation/pages/company_page.dart';
import 'package:go_router/go_router.dart';

final appRouter = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (_, __) => const HomePage(),
    ),
    GoRoute(
      path: '/login',
      builder: (_, __) => const LoginPage(),
    ),
    GoRoute(
      path: '/register',
      builder: (_, __) => const RegisterPage(),
    ),
    GoRoute(
      path: '/user',
      builder: (_, __) => const UserAreaPage(),
    ),
    GoRoute(
      path: '/company',
      builder: (_, __) => const CompanyPage(),
    )
  ],
);
