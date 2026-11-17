import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jobfy/core/session/user_session_controller.dart';
import 'package:jobfy/core/theme/app_theme.dart';
import 'package:jobfy/features/messages/data/datasources/messages_fake_data_source.dart';
import 'package:jobfy/features/messages/data/repositories/messages_repository_impl.dart';
import 'package:jobfy/features/messages/presentation/pages/messages_page.dart';
import 'package:jobfy/features/user/data/datasources/user_fake_data_source.dart';
import 'package:jobfy/features/user/data/repositories/user_repository_impl.dart';
import 'package:jobfy/features/user/domain/usecases/get_user_profile_usecase.dart';
import 'package:jobfy/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../helpers/empty_job_data_source.dart';

/// The fake chat has two conversations: TechNova (open) and Verde Agro
/// (no approval: history only).
Future<void> _pump(
  WidgetTester tester, {
  required bool company,
  Size size = const Size(1100, 900),
  String? openPartnerId,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  final session = UserSessionController(
    GetUserProfileUsecase(UserRepositoryImpl(UserFakeDataSource(EmptyJobDataSource()))),
  );
  company ? session.startCompany('1') : session.start('usr_001');

  await tester.pumpWidget(
    ChangeNotifierProvider.value(
      value: session,
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
        home: Scaffold(
          body: MessagesPage(
            repository: MessagesRepositoryImpl(MessagesFakeDataSource()),
            openPartnerId: openPartnerId,
            pollInterval: const Duration(days: 1),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('a company sees its conversations and writes in an open one', (tester) async {
    await _pump(tester, company: true);

    expect(find.text('TechNova Soluções Digitais'), findsOneWidget);
    expect(find.text('Verde Agro Analytics'), findsOneWidget);
    expect(find.text('Select a conversation'), findsOneWidget);
    expect(find.byType(Badge), findsNothing); // the unread count is a plain chip
    expect(find.text('1'), findsOneWidget); // 1 unread from TechNova

    await tester.tap(find.text('TechNova Soluções Digitais'));
    await tester.pumpAndSettle();

    expect(find.text('Olá! Sua candidatura foi aprovada. Podemos agendar uma conversa?'), findsWidgets);
    expect(find.text('1'), findsNothing); // opened: no longer unread

    await tester.enterText(find.byType(TextField).last, 'Sim, quinta à tarde.');
    await tester.tap(find.byTooltip('Send'));
    await tester.pumpAndSettle();

    expect(find.text('Sim, quinta à tarde.'), findsWidgets);
    expect(tester.widget<TextField>(find.byType(TextField).last).controller!.text, isEmpty);
  });

  testWidgets('a conversation without approval is read-only', (tester) async {
    await _pump(tester, company: false);

    await tester.tap(find.text('Verde Agro Analytics'));
    await tester.pumpAndSettle();

    expect(find.text('Obrigado pelo interesse na vaga.'), findsWidgets);
    expect(find.text('Messages can only be sent while the application is approved.'), findsOneWidget);
    expect(find.byTooltip('Send'), findsNothing);
    expect(find.text('Write a message...'), findsNothing);
  });

  testWidgets('the search narrows the list', (tester) async {
    await _pump(tester, company: true);

    await tester.enterText(find.byType(TextField).first, 'verde');
    await tester.pump();

    expect(find.text('Verde Agro Analytics'), findsOneWidget);
    expect(find.text('TechNova Soluções Digitais'), findsNothing);

    await tester.enterText(find.byType(TextField).first, 'zzz');
    await tester.pump();
    expect(find.text('No conversations found.'), findsOneWidget);
  });

  testWidgets('opens the partner asked for (the company\'s "Send message")', (tester) async {
    await _pump(tester, company: true, openPartnerId: 'p1');

    expect(find.text('Select a conversation'), findsNothing);
    expect(find.text('Write a message...'), findsOneWidget);
  });

  testWidgets('on a phone the list and the thread are two screens', (tester) async {
    await _pump(tester, company: true, size: const Size(400, 800));

    expect(find.text('Select a conversation'), findsNothing); // list only
    await tester.tap(find.text('TechNova Soluções Digitais'));
    await tester.pumpAndSettle();

    expect(find.text('Search conversations...'), findsNothing); // thread only
    expect(find.text('Write a message...'), findsOneWidget);

    await tester.tap(find.byTooltip('Back').last);
    await tester.pumpAndSettle();
    expect(find.text('Search conversations...'), findsOneWidget);
  });
}
