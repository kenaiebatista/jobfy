import 'package:jobfy/core/session/user_session_controller.dart';
import 'package:jobfy/core/theme/app_colors.dart';
import 'package:jobfy/features/user/presentation/widgets/profile_sidebar.dart';
import 'package:jobfy/l10n/app_localizations.dart';
import 'package:jobfy/shared/widgets/glow_circle.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

/// Which company screen is showing, so the sidebar highlights its entry.
enum CompanySection { dashboard, messages, settings }

/// The company's version of [ProfileSidebar]: same look and same place (the
/// left), with the company's own screens.
class CompanySidebar extends StatelessWidget {
  final CompanySection current;

  /// Called when an entry is picked, e.g. to close the drawer.
  final VoidCallback? onNavTap;

  /// Unread chat messages, shown on the Messages entry.
  final int unreadMessages;

  const CompanySidebar({
    super.key,
    required this.current,
    this.onNavTap,
    this.unreadMessages = 0,
  });

  static const double width = ProfileSidebar.width;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final name = context.watch<UserSessionController>().companyName ?? l10n.appName;
    final words = name.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty);
    final initials = words.isEmpty ? '?' : words.take(2).map((w) => w[0]).join().toUpperCase();

    return SizedBox(
      width: width,
      child: Stack(
        fit: StackFit.expand,
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
            top: -60, left: -60,
            child: GlowCircle(size: 220, color: Color(0x331D4ED8)),
          ),
          const Positioned(
            bottom: 40, right: -60,
            child: GlowCircle(size: 200, color: Color(0x264F46E5)),
          ),
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 22, 16, 20),
                child: Column(
                  spacing: 10,
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [AppColors.accent, AppColors.accent2],
                        ),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.2),
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          initials,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    Text(
                      name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const Divider(color: Colors.white12, height: 1),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  children: [
                    SidebarNavItem(
                      icon: Icons.dashboard_outlined,
                      label: l10n.navDashboard,
                      isSelected: current == CompanySection.dashboard,
                      onTap: () {
                        onNavTap?.call();
                        context.go('/company');
                      },
                    ),
                    SidebarNavItem(
                      icon: Icons.chat_bubble_outline,
                      label: l10n.navMessages,
                      isSelected: current == CompanySection.messages,
                      badge: unreadMessages,
                      onTap: () {
                        onNavTap?.call();
                        context.go('/messages');
                      },
                    ),
                  ],
                ),
              ),
              const Divider(color: Colors.white12, height: 1),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  spacing: 2,
                  children: [
                    SidebarNavItem(
                      icon: Icons.settings_outlined,
                      label: l10n.navSettings,
                      isSelected: current == CompanySection.settings,
                      onTap: () {
                        onNavTap?.call();
                        context.go('/settings');
                      },
                    ),
                    SidebarNavItem(
                      icon: Icons.logout,
                      label: l10n.navLogout,
                      isSelected: false,
                      isDanger: true,
                      onTap: () {
                        final session = context.read<UserSessionController>();
                        context.go('/');
                        session.clear();
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
