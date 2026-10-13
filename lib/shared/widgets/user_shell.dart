import 'package:jobfy/core/theme/app_breakpoints.dart';
import 'package:jobfy/features/user/domain/entities/user_profile_entity.dart';
import 'package:jobfy/features/user/presentation/widgets/profile_sidebar.dart';
import 'package:jobfy/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// Wraps [builder]'s content with the persistent user sidebar shared by
/// every authenticated screen (dashboard, jobs, settings), so navigation
/// and the signed-in profile stay visible while browsing between them.
///
/// On laptops/desktops the sidebar is fixed on the left. Below
/// [AppBreakpoints.mobile] (phones and tablets) there is no room for it, so
/// it is omitted here and the page's Scaffold shows it as a drawer instead
/// (see [drawer] and [MenuButton]).
///
/// Shows a spinner (or an error message) in place of the sidebar+content
/// while the shared [UserSessionController] profile is still loading.
class UserShell extends StatelessWidget {
  final UserProfileEntity? profile;
  final bool isError;
  final SidebarSection current;
  final Widget Function(BuildContext context, UserProfileEntity profile) builder;

  const UserShell({
    super.key,
    required this.profile,
    required this.current,
    required this.builder,
    this.isError = false,
  });

  /// The sidebar as a navigation drawer for the page's `Scaffold.drawer`.
  /// Null on wide screens (the sidebar is already docked) or while the
  /// profile is loading.
  static Widget? drawer(
    BuildContext context, {
    required UserProfileEntity? profile,
    required SidebarSection current,
  }) {
    if (profile == null || !context.isCompactLayout) return null;
    return Drawer(
      width: ProfileSidebar.width,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(),
      child: ProfileSidebar(profile: profile, current: current, onNavTap: () {}),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = this.profile;
    if (profile == null) {
      if (isError) {
        return Center(child: Text(AppLocalizations.of(context)!.userAreaLoadError));
      }
      return const Center(child: CircularProgressIndicator());
    }

    if (context.isCompactLayout) return builder(context, profile);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProfileSidebar(profile: profile, current: current, onNavTap: () {  },),
        Expanded(child: builder(context, profile)),
      ],
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
