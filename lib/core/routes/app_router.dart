import 'package:jobfy/core/session/user_session_controller.dart';
import 'package:jobfy/features/auth/presentation/pages/login_page.dart';
import 'package:jobfy/features/auth/presentation/pages/register_page.dart';
import 'package:jobfy/features/home/presentation/pages/home_page.dart';
import 'package:jobfy/features/jobs/presentation/pages/jobs_page.dart';
import 'package:jobfy/features/settings/presentation/pages/settings_page.dart';
import 'package:jobfy/features/user/presentation/pages/user_area_page.dart';
import 'package:jobfy/features/company/presentation/pages/company_page.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

/// Screens that need a signed-in user. Without one (e.g. after a restart,
/// since the session lives in memory) they send you to the login screen.
const _signedInOnly = {'/user', '/jobs', '/settings'};

final appRouter = GoRouter(
  redirect: (context, state) {
    final signedIn = context.read<UserSessionController>().isSignedIn;
    if (!signedIn && _signedInOnly.contains(state.matchedLocation)) {
      return '/login';
    }
    return null;
  },
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
    ),
    GoRoute(
      path: '/settings',
      builder: (_, __) => const SettingsPage(),
    ),
    GoRoute(
      path: '/jobs',
      builder: (_, __) => const JobsPage(),
    ),
  ],
);
