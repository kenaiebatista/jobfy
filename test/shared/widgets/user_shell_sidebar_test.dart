import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jobfy/core/session/user_session_controller.dart';
import 'package:jobfy/core/settings/settings_controller.dart';
import 'package:jobfy/core/theme/app_theme.dart';
import 'package:jobfy/features/jobs/presentation/pages/jobs_page.dart';
import 'package:jobfy/features/settings/presentation/pages/settings_page.dart';
import 'package:jobfy/features/user/data/repositories/user_repository_impl.dart';
import 'package:jobfy/features/user/domain/usecases/get_user_profile_usecase.dart';
import 'package:jobfy/features/user/presentation/widgets/profile_sidebar.dart';
import 'package:jobfy/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

/// Regression test: the sidebar used to only appear on the dashboard.
/// Jobs and Settings now keep it too, at a narrower fixed width.
void main() {
  Widget wrap(Widget home) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => UserSessionController(
            GetUserProfileUsecase(UserRepositoryImpl()),
          ),
        ),
        ChangeNotifierProvider(create: (_) => SettingsController()),
      ],
      child: MaterialApp(
        theme: AppTheme.light,
        locale: const Locale('en'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: home,
      ),
    );
  }

  testWidgets('ProfileSidebar is narrower than the old 260px width', (tester) async {
    expect(ProfileSidebar.width, lessThan(260));
  });

  testWidgets('JobsPage shows the sidebar with Jobs highlighted', (tester) async {
    await tester.pumpWidget(wrap(const JobsPage()));
    await tester.pumpAndSettle();

    expect(find.byType(ProfileSidebar), findsOneWidget);
    final sidebar = tester.widget<ProfileSidebar>(find.byType(ProfileSidebar));
    expect(sidebar.current, SidebarSection.jobs);
  });

  testWidgets('SettingsPage shows the sidebar with Settings highlighted', (tester) async {
    await tester.pumpWidget(wrap(const SettingsPage()));
    await tester.pumpAndSettle();

    expect(find.byType(ProfileSidebar), findsOneWidget);
    final sidebar = tester.widget<ProfileSidebar>(find.byType(ProfileSidebar));
    expect(sidebar.current, SidebarSection.settings);
  });
}
