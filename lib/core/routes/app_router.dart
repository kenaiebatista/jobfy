import 'package:jobfy/core/session/user_session_controller.dart';
import 'package:jobfy/features/auth/presentation/pages/login_page.dart';
import 'package:jobfy/features/auth/presentation/pages/register_page.dart';
import 'package:jobfy/features/home/presentation/pages/home_page.dart';
import 'package:jobfy/features/jobs/presentation/pages/jobs_page.dart';
import 'package:jobfy/features/resume/presentation/pages/resume_page.dart';
import 'package:jobfy/features/settings/presentation/pages/settings_page.dart';
import 'package:jobfy/features/user/presentation/pages/user_area_page.dart';
import 'package:jobfy/shared/widgets/app_shell.dart';
import 'package:flutter/material.dart';
import 'package:jobfy/features/company/presentation/pages/candidate_page.dart';
import 'package:jobfy/features/company/presentation/pages/company_page.dart';
import 'package:jobfy/features/jobs/presentation/pages/job_details_page.dart';
import 'package:jobfy/features/messages/presentation/pages/messages_page.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

/// Screens that need a signed-in user. Without one (e.g. after a restart,
/// since the session lives in memory) they send you to the login screen.
const _signedInOnly = {'/user', '/jobs', '/settings', '/resume', '/messages'};

/// [location] is [path] or one of its sub-screens (e.g. '/jobs/3').
bool _isUnder(String location, String path) =>
    location == path || location.startsWith('$path/');

bool _isUserScreen(String location) => _signedInOnly.any((p) => _isUnder(location, p));

/// Pages inside the [AppShell] swap in place, with no slide, so only the
/// page changes while the sidebar and the top bar stay where they are.
Page<void> _page(GoRouterState state, Widget child) =>
    NoTransitionPage<void>(key: state.pageKey, child: child);

final appRouter = GoRouter(
  redirect: (context, state) {
    final session = context.read<UserSessionController>();
    final location = state.matchedLocation;
    // A company has its own dashboard; of the user's screens it only shares
    // the settings and the chat.
    if (session.isCompanySignedIn) {
      final shared = _isUnder(location, '/settings') || _isUnder(location, '/messages');
      return _isUserScreen(location) && !shared ? '/company' : null;
    }
    if (!session.isSignedIn && _isUserScreen(location)) {
      return '/login';
    }
    // The company dashboard (and its candidate screens) need a signed-in company.
    if (_isUnder(location, '/company')) {
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
      // '/register?type=company' opens the form in company mode.
      builder: (_, state) => RegisterPage(
        startAsCompany: state.uri.queryParameters['type'] == 'company',
      ),
    ),
    ShellRoute(
      // Sidebar and top bar of every signed-in screen (users and companies).
      builder: (_, state, child) => AppShell(location: state.uri.path, child: child),
      routes: [
        GoRoute(
          path: '/user',
          pageBuilder: (_, state) => _page(state, const UserAreaPage()),
        ),
        GoRoute(
          path: '/company',
          pageBuilder: (_, state) => _page(state, const CompanyPage()),
          routes: [
            GoRoute(
              path: 'candidates/:userId',
              pageBuilder: (_, state) =>
                  _page(state, CandidatePage(userId: state.pathParameters['userId']!)),
            ),
          ],
        ),
        GoRoute(
          path: '/settings',
          pageBuilder: (_, state) => _page(state, const SettingsPage()),
        ),
        GoRoute(
          path: '/jobs',
          pageBuilder: (_, state) => _page(state, const JobsPage()),
          routes: [
            GoRoute(
              path: ':id',
              pageBuilder: (_, state) =>
                  _page(state, JobDetailsPage(jobId: state.pathParameters['id']!)),
            ),
          ],
        ),
        GoRoute(
          path: '/messages',
          // '/messages?with=<partner id>' opens that conversation.
          pageBuilder: (_, state) => _page(
            state,
            MessagesPage(openPartnerId: state.uri.queryParameters['with']),
          ),
        ),
        GoRoute(
          path: '/resume',
          pageBuilder: (_, state) => _page(state, const ResumePage()),
        ),
      ],
    ),
  ],
);
