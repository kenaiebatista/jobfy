import 'package:aplicativo_jobfy/core/routes/app_router.dart';
import 'package:aplicativo_jobfy/core/settings/app_settings_controller.dart';
import 'package:aplicativo_jobfy/core/theme/app_theme.dart';
import 'package:aplicativo_jobfy/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await appSettings.load();
  runApp(const JobfyApp());
}

class JobfyApp extends StatelessWidget {
  const JobfyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appSettings,
      builder: (context, _) {
        return MaterialApp.router(
          title: 'Jobfy',
          debugShowCheckedModeBanner: false,
          routerConfig: appRouter,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: appSettings.themeMode,
          locale: appSettings.locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        );
      },
    );
  }
}
