import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:jobfy/core/session/user_session_controller.dart';
import 'package:jobfy/core/settings/settings_controller.dart';
import 'package:jobfy/core/theme/app_theme.dart';
import 'package:jobfy/features/company/presentation/widgets/company_sidebar.dart';
import 'package:jobfy/features/user/data/datasources/user_fake_data_source.dart';
import 'package:jobfy/features/user/data/repositories/user_repository_impl.dart';
import 'package:jobfy/features/user/domain/usecases/get_user_profile_usecase.dart';
import 'package:jobfy/features/user/presentation/widgets/profile_sidebar.dart';
import 'package:jobfy/l10n/app_localizations.dart';
import 'package:jobfy/shared/widgets/app_shell.dart';
import 'package:provider/provider.dart';

import '../../helpers/empty_job_data_source.dart';

/// Every signed-in screen (users and companies) sits in the same frame: the
/// sidebar on the left (docked, or a drawer on phones, opened from a menu
/// button at the left of the top bar) and the top bar above the page. The
/// frame stays put while navigating: only the page changes.
const _wide = Size(1400, 900);
const _phone = Size(400, 800);

UserSessionController _session({required bool company}) {
  final session = UserSessionController(
    GetUserProfileUsecase(UserRepositoryImpl(UserFakeDataSource(EmptyJobDataSource()))),
  );
  company ? session.startCompany('1', name: 'Tech Nova Ltda') : session.start('usr_001');
  return session;
}

Widget _app(UserSessionController session, {Widget? home, GoRouter? router}) {
  final shared = MultiProvider(
    providers: [
      ChangeNotifierProvider.value(value: session),
      ChangeNotifierProvider(create: (_) => SettingsController()),
    ],
    child: Builder(
      builder: (context) {
        const delegates = [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ];
        return router == null
            ? MaterialApp(
                theme: AppTheme.light,
                locale: const Locale('en'),
                supportedLocales: AppLocalizations.supportedLocales,
                localizationsDelegates: delegates,
                home: home,
              )
            : MaterialApp.router(
                theme: AppTheme.light,
                locale: const Locale('en'),
                supportedLocales: AppLocalizations.supportedLocales,
                localizationsDelegates: delegates,
                routerConfig: router,
              );
      },
    ),
  );
  return shared;
}

/// Same shape as the real router: one ShellRoute around the signed-in pages.
GoRouter _router() => GoRouter(
      initialLocation: '/jobs',
      routes: [
        ShellRoute(
          builder: (_, state, child) => AppShell(location: state.uri.path, child: child),
          routes: [
            for (final path in ['/jobs', '/resume'])
              GoRoute(
                path: path,
                pageBuilder: (_, state) => NoTransitionPage<void>(
                  key: state.pageKey,
                  child: Center(child: Text('page $path')),
                ),
              ),
          ],
        ),
      ],
    );

void main() {
  void setSize(WidgetTester tester, Size size) {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }

  testWidgets('user, wide: sidebar docked on the left, top bar beside it, no arrow or menu button', (tester) async {
    setSize(tester, _wide);
    await tester.pumpWidget(_app(_session(company: false), home: const AppShell(location: '/jobs', child: Text('page'))));
    await tester.pumpAndSettle();

    final sidebar = tester.widget<ProfileSidebar>(find.byType(ProfileSidebar));
    expect(sidebar.current, SidebarSection.jobs);
    expect(tester.getTopLeft(find.byType(ProfileSidebar)), Offset.zero);
    expect(tester.getSize(find.byType(ProfileSidebar)).height, 900); // full height
    // The top bar starts where the sidebar ends and has the logo.
    expect(tester.getTopLeft(find.byIcon(Icons.lightbulb_circle)).dx, greaterThan(ProfileSidebar.width));
    expect(find.text('page'), findsOneWidget);
    expect(find.byIcon(Icons.arrow_back), findsNothing);
    expect(find.byIcon(Icons.menu), findsNothing);
  });

  testWidgets('company, wide: its sidebar with the name, same frame and top bar', (tester) async {
    setSize(tester, _wide);
    await tester.pumpWidget(_app(_session(company: true), home: const AppShell(location: '/messages', child: Text('page'))));
    await tester.pumpAndSettle();

    final sidebar = tester.widget<CompanySidebar>(find.byType(CompanySidebar));
    expect(sidebar.current, CompanySection.messages);
    expect(tester.getTopLeft(find.byType(CompanySidebar)), Offset.zero);
    expect(find.descendant(of: find.byType(CompanySidebar), matching: find.text('Tech Nova Ltda')), findsOneWidget);
    expect(tester.getTopLeft(find.byIcon(Icons.lightbulb_circle)).dx, greaterThan(CompanySidebar.width));
    expect(find.byIcon(Icons.arrow_back), findsNothing);
  });

  for (final company in [false, true]) {
    testWidgets('phone, ${company ? 'company' : 'user'}: the menu button is at the left of the top bar and opens the sidebar', (tester) async {
      setSize(tester, _phone);
      await tester.pumpWidget(_app(_session(company: company), home: const AppShell(location: '/jobs', child: Text('page'))));
      await tester.pumpAndSettle();

      final sidebar = company ? find.byType(CompanySidebar) : find.byType(ProfileSidebar);
      expect(sidebar, findsNothing);
      expect(find.byIcon(Icons.arrow_back), findsNothing);
      final menu = tester.getTopLeft(find.byIcon(Icons.menu));
      expect(menu.dx, lessThan(tester.getTopLeft(find.byIcon(Icons.lightbulb_circle)).dx));

      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      expect(sidebar, findsOneWidget);
      expect(tester.getTopLeft(sidebar).dx, 0);
    });
  }

  testWidgets('navigating swaps only the page: sidebar and top bar stay, the highlight moves', (tester) async {
    setSize(tester, _wide);
    await tester.pumpWidget(_app(_session(company: false), router: _router()));
    await tester.pumpAndSettle();

    final shell = tester.element(find.byType(AppShell));
    final sidebarAt = tester.getTopLeft(find.byType(ProfileSidebar));
    final logoAt = tester.getTopLeft(find.byIcon(Icons.lightbulb_circle));
    expect(find.text('page /jobs'), findsOneWidget);
    expect(tester.widget<ProfileSidebar>(find.byType(ProfileSidebar)).current, SidebarSection.jobs);

    await tester.tap(find.descendant(of: find.byType(ProfileSidebar), matching: find.text('Resume')));
    await tester.pump(); // no transition: the new page is there right away

    expect(find.text('page /resume'), findsOneWidget);
    expect(find.text('page /jobs'), findsNothing);
    expect(tester.element(find.byType(AppShell)), same(shell)); // the frame wasn't rebuilt from scratch
    expect(tester.getTopLeft(find.byType(ProfileSidebar)), sidebarAt);
    expect(tester.getTopLeft(find.byIcon(Icons.lightbulb_circle)), logoAt);
    expect(tester.widget<ProfileSidebar>(find.byType(ProfileSidebar)).current, SidebarSection.resume);
  });

  testWidgets('phone: picking an entry in the drawer goes there and closes the drawer', (tester) async {
    setSize(tester, _phone);
    await tester.pumpWidget(_app(_session(company: false), router: _router()));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();
    await tester.tap(find.descendant(of: find.byType(ProfileSidebar), matching: find.text('Resume')));
    await tester.pumpAndSettle();

    expect(find.text('page /resume'), findsOneWidget);
    expect(find.byType(ProfileSidebar), findsNothing); // drawer closed
  });
}
