import 'package:jobfy/core/theme/app_breakpoints.dart';
import 'package:jobfy/core/theme/app_colors.dart';
import 'package:jobfy/l10n/app_localizations.dart';
import 'package:jobfy/shared/widgets/glow_circle.dart';
import 'package:jobfy/shared/widgets/header_widget.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
          // Scrollable so the hero still fits on short landscape phones.
          LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 900),
                    child: Padding(
                      padding: EdgeInsets.all(context.pagePadding),
                      child: _buildHero(context, l10n),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHero(BuildContext context, AppLocalizations l10n) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: context.responsive(mobile: 14.0, laptop: 20.0),
      children: [
        Text(
          l10n.homeHeadline,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: context.responsive(
              mobile: 32.0,
              tablet: 42.0,
              laptop: 52.0,
            ),
            fontWeight: FontWeight.bold,
            height: 1.2,
          ),
        ),
        Text(
          l10n.homeSubheadline,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.textLight,
            fontSize: context.responsive(mobile: 14.0, laptop: 16.0),
            height: 1.7,
          ),
        ),
        const SizedBox(height: 20),
        // Wrap: the two buttons sit side by side when they fit and stack
        // on narrow phones instead of overflowing.
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 16,
          runSpacing: 12,
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
              child: Text(
                l10n.homeCtaPrimary,
                style: const TextStyle(fontSize: 15),
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
              child: Text(
                l10n.homeCtaSecondary,
                style: const TextStyle(fontSize: 15),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
