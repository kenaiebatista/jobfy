import 'package:jobfy/core/routes/app_router.dart';
import 'package:jobfy/core/settings/settings_controller.dart';
import 'package:jobfy/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const JobfyApp());
}

class JobfyApp extends StatelessWidget {
  const JobfyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SettingsController()..load(),
      child: Consumer<SettingsController>(
        builder: (context, settings, _) {
          return MaterialApp.router(
            title: 'Jobfy',
            debugShowCheckedModeBanner: false,
            routerConfig: appRouter,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: settings.themeMode,
          );
        },
      ),
    );
  }
}
