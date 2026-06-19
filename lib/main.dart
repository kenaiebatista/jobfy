import 'package:aplicativo_jobfy/core/routes/app_router.dart';
import 'package:aplicativo_jobfy/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const JobfyApp());
}

class JobfyApp extends StatelessWidget {
  const JobfyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Jobfy',
      debugShowCheckedModeBanner: false,
      routerConfig: appRouter,
      theme: AppTheme.theme,
    );
  }
}
