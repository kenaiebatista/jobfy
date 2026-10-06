import 'package:aplicativo_jobfy/core/routes/app_router.dart';
import 'package:aplicativo_jobfy/core/settings/app_settings_controller.dart';
import 'package:aplicativo_jobfy/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:aplicativo_jobfy/features/settings/domain/entities/user_preferences_entity.dart';
import 'package:aplicativo_jobfy/features/settings/presentation/pages/settings_page.dart';
import 'package:aplicativo_jobfy/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await appSettings.setThemeMode(ThemeMode.light);
    await appSettings.setLocale(const Locale('pt'));
  });

  Future<void> abrir(WidgetTester tester, String rota) async {
    tester.view.physicalSize = const Size(1400, 2600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const JobfyApp());
    appRouter.go(rota);
    await tester.pumpAndSettle();
  }

  testWidgets('home abre em português', (tester) async {
    await abrir(tester, '/');
    expect(find.text('Começar agora'), findsOneWidget);
  });

  testWidgets('tema escuro é aplicado e salvo', (tester) async {
    await abrir(tester, '/settings');

    await tester.tap(find.text('Escuro'));
    await tester.pumpAndSettle();

    final ctx = tester.element(find.byType(SettingsPage));
    expect(Theme.of(ctx).brightness, Brightness.dark);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('app.theme_mode'), 'dark');
  });

  testWidgets('trocar idioma traduz o app e é salvo', (tester) async {
    await abrir(tester, '/settings');

    await tester.ensureVisible(find.text('English'));
    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();

    expect(find.text('Language'), findsOneWidget);
    expect(find.text('Notifications'), findsOneWidget);

    await tester.ensureVisible(find.text('Español'));
    await tester.tap(find.text('Español'));
    await tester.pumpAndSettle();

    expect(find.text('Idioma'), findsOneWidget);
    expect(find.text('Notificaciones'), findsOneWidget);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('app.locale'), 'es');
  });

  testWidgets('preferências de notificação ficam salvas', (tester) async {
    await abrir(tester, '/settings');

    final toggle = find.byType(Switch).first;
    await tester.ensureVisible(toggle);
    await tester.tap(toggle);
    await tester.pumpAndSettle();

    final salvas = await SettingsRepositoryImpl().getPreferences();
    expect(salvas.notifNovasVagas, isFalse);
  });

  test('tipos de vaga são lidos de volta', () async {
    final repo = SettingsRepositoryImpl();
    await repo.savePreferences(
      const UserPreferencesEntity(tiposVaga: {TipoVaga.hibrido}),
    );
    expect((await repo.getPreferences()).tiposVaga, {TipoVaga.hibrido});
  });
}
