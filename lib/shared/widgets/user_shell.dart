import 'package:jobfy/features/user/domain/entities/user_profile_entity.dart';
import 'package:jobfy/features/user/presentation/widgets/profile_sidebar.dart';
import 'package:jobfy/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// Wraps [builder]'s content with the persistent user sidebar shared by
/// every authenticated screen (dashboard, jobs, settings), so navigation
/// and the signed-in profile stay visible while browsing between them.
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

  @override
  Widget build(BuildContext context) {
    final profile = this.profile;
    if (profile == null) {
      if (isError) {
        return Center(child: Text(AppLocalizations.of(context)!.userAreaLoadError));
      }
      return const Center(child: CircularProgressIndicator());
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProfileSidebar(profile: profile, current: current),
        Expanded(child: builder(context, profile)),
      ],
    );
  }
}
