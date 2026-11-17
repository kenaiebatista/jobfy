import 'package:jobfy/core/session/user_session_controller.dart';
import 'package:jobfy/core/theme/app_breakpoints.dart';
import 'package:jobfy/core/theme/build_context_x.dart';
import 'package:jobfy/features/company/presentation/widgets/company_sidebar.dart';
import 'package:jobfy/features/user/domain/entities/user_profile_entity.dart';
import 'package:jobfy/features/user/presentation/widgets/profile_sidebar.dart';
import 'package:jobfy/l10n/app_localizations.dart';
import 'package:jobfy/shared/widgets/theme_toggle_button.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

/// The frame of every signed-in screen, for users and companies alike: the
/// sidebar on the left and, beside it, the top bar above the page. It is
/// the router's `ShellRoute`, so it stays put while navigating: only
/// [child], the page itself, changes.
///
/// On laptops/desktops the sidebar is docked. Below
/// [AppBreakpoints.mobile] (phones and tablets) there is no room for it, so
/// it opens as a drawer from the menu button at the left of the top bar.
///
/// For a user, the page is only shown once the profile (shown in the
/// sidebar) has loaded; until then the area shows a spinner or an error.
class AppShell extends StatefulWidget {
  /// Path of the current page (e.g. `/jobs/3`), to highlight its sidebar entry.
  final String location;
  final Widget child;

  const AppShell({super.key, required this.location, required this.child});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    final session = context.read<UserSessionController>();
    if (!session.isCompanySignedIn) session.ensureLoaded();
  }

  SidebarSection _userSection(String path) {
    if (path.startsWith('/jobs')) return SidebarSection.jobs;
    if (path.startsWith('/resume')) return SidebarSection.resume;
    if (path.startsWith('/messages')) return SidebarSection.messages;
    if (path.startsWith('/settings')) return SidebarSection.settings;
    return SidebarSection.dashboard;
  }

  CompanySection _companySection(String path) {
    if (path.startsWith('/messages')) return CompanySection.messages;
    if (path.startsWith('/settings')) return CompanySection.settings;
    return CompanySection.dashboard;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final session = context.watch<UserSessionController>();
    final compact = context.isCompactLayout;
    final isCompany = session.isCompanySignedIn;
    final profile = session.profile;
    // Picking an entry in the drawer closes it (the shell stays on screen).
    void closeDrawer() => _scaffoldKey.currentState?.closeDrawer();

    final Widget? sidebar = isCompany
        ? CompanySidebar(current: _companySection(widget.location), onNavTap: closeDrawer)
        : profile == null
            ? null
            : ProfileSidebar(
                profile: profile,
                current: _userSection(widget.location),
                onNavTap: closeDrawer,
              );

    final String initial = (isCompany ? session.companyName : profile?.name)?.trim() ?? '';

    final Widget page;
    if (!isCompany && profile == null) {
      page = Center(
        child: session.status == UserSessionStatus.error
            ? Text(l10n.userAreaLoadError)
            : const CircularProgressIndicator(),
      );
    } else {
      page = widget.child;
    }

    final content = Column(
      children: [
        _TopBar(
          showMenu: compact && sidebar != null,
          showSearch: !isCompany,
          initial: initial.isEmpty ? '?' : initial[0].toUpperCase(),
        ),
        Expanded(child: page),
      ],
    );

    return Scaffold(
      key: _scaffoldKey,
      drawer: compact && sidebar != null
          ? Drawer(
              width: ProfileSidebar.width,
              backgroundColor: Colors.transparent,
              shape: const RoundedRectangleBorder(),
              child: sidebar,
            )
          : null,
      body: !compact && sidebar != null
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [sidebar, Expanded(child: content)],
            )
          : content,
    );
  }
}

/// Logo, search (users only), theme toggle and the avatar, above every page.
class _TopBar extends StatelessWidget {
  final bool showMenu;
  final bool showSearch;
  final String initial;

  const _TopBar({
    required this.showMenu,
    required this.showSearch,
    required this.initial,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context)!;
    final compact = context.isMobile;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.pagePadding,
        vertical: context.responsive(mobile: 6.0, laptop: 14.0),
      ),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(bottom: BorderSide(color: colors.surfaceBorder)),
      ),
      child: Row(
        spacing: 8,
        children: [
          // Phones/tablets: the sidebar lives in a drawer opened from here.
          if (showMenu) MenuButton(color: colors.textPrimary),
          Icon(Icons.lightbulb_circle, size: 28, color: colors.textPrimary),
          if (!compact)
            Text(
              l10n.appName,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: colors.textPrimary,
              ),
            ),
          const Spacer(),
          if (showSearch)
            // Phones only get the search icon; the pill's label doesn't fit.
            if (compact)
              IconButton(
                icon: Icon(Icons.search, color: colors.textPrimary),
                onPressed: () => context.go('/jobs'),
                style: IconButton.styleFrom(backgroundColor: colors.background),
              )
            else
              InkWell(
                onTap: () => context.go('/jobs'),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: colors.background,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: colors.surfaceBorder),
                  ),
                  child: Row(
                    spacing: 6,
                    children: [
                      Icon(Icons.search, size: 16, color: colors.textMuted),
                      Text(
                        l10n.searchJobsPlaceholder,
                        style: TextStyle(fontSize: 13, color: colors.textMuted),
                      ),
                    ],
                  ),
                ),
              ),
          ThemeToggleButton(color: colors.textPrimary),
          if (showSearch)
            IconButton(
              icon: Icon(Icons.notifications_outlined, color: colors.textPrimary),
              onPressed: () {},
              style: IconButton.styleFrom(backgroundColor: colors.background),
            ),
          CircleAvatar(
            radius: 18,
            backgroundColor: colors.accent,
            child: Text(
              initial,
              style: TextStyle(
                color: colors.onAccent,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Hamburger button that opens the enclosing Scaffold's drawer. Renders
/// nothing on wide screens, where the sidebar is always visible.
class MenuButton extends StatelessWidget {
  const MenuButton({super.key, this.color});

  final Color? color;

  @override
  Widget build(BuildContext context) {
    if (!context.isCompactLayout) return const SizedBox.shrink();
    return IconButton(
      icon: Icon(Icons.menu, color: color),
      onPressed: () => Scaffold.of(context).openDrawer(),
    );
  }
}

/// Builds [builder] with the signed-in user's profile once it is loaded,
/// and a spinner (or the error) until then. The pages of the sidebar
/// screens are shown by [AppShell] only after this, so they can rely on it.
class ProfileGate extends StatelessWidget {
  final UserProfileEntity? profile;
  final bool isError;
  final Widget Function(BuildContext context, UserProfileEntity profile) builder;

  const ProfileGate({
    super.key,
    required this.profile,
    required this.builder,
    this.isError = false,
  });

  @override
  Widget build(BuildContext context) {
    final profile = this.profile;
    if (profile == null) {
      if (isError) {
        return Center(child: Text(AppLocalizations.of(context)!.userAreaLoadError));
      }
      return const Center(child: CircularProgressIndicator());
    }
    return builder(context, profile);
  }
}
