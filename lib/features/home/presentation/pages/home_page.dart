import 'package:aplicativo_jobfy/core/theme/app_breakpoints.dart';
import 'package:aplicativo_jobfy/core/theme/app_colors.dart';
import 'package:aplicativo_jobfy/shared/widgets/glow_circle.dart';
import 'package:aplicativo_jobfy/shared/widgets/header_widget.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.sizeOf(context).width < AppBreakpoints.mobile;

    return Scaffold(
      appBar: const HeaderWidget(),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.backgroundDark, AppColors.backgroundDark2],
              ),
            ),
          ),
          const Positioned(
            top: -60, right: -80,
            child: GlowCircle(size: 400, color: Color(0x331D4ED8)),
          ),
          const Positioned(
            bottom: 40, left: -60,
            child: GlowCircle(size: 350, color: Color(0x264F46E5)),
          ),
          Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: isMobile ? 24 : 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Encontre o emprego\ndos seus sonhos.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isMobile ? 34 : 52,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'A Jobfy usa inteligência para conectar talentos\na oportunidades reais no mercado.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textLight,
                      fontSize: isMobile ? 14 : 16,
                      height: 1.7,
                    ),
                  ),
                  const SizedBox(height: 40),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      ElevatedButton(
                        onPressed: () => context.go('/register'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Começar agora',
                          style: TextStyle(fontSize: 15),
                        ),
                      ),
                      OutlinedButton(
                        onPressed: () => context.go('/login'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                          side: const BorderSide(color: Colors.white38),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Já tenho conta',
                          style: TextStyle(fontSize: 15),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
