import 'package:jobfy/core/theme/app_colors.dart';
import 'package:jobfy/features/user/domain/entities/user_profile_entity.dart';
import 'package:jobfy/l10n/app_localizations.dart';
import 'package:jobfy/shared/widgets/glow_circle.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Which part of the authenticated app is currently showing, so the
/// sidebar (shared across the dashboard, jobs and settings screens) can
/// highlight the right entry regardless of which page rendered it.
enum SidebarSection { dashboard, jobs, resume, messages, settings }

class ProfileSidebar extends StatelessWidget {
  final UserProfileEntity profile;
  final SidebarSection current;

  const ProfileSidebar({
    super.key,
    required this.profile,
    required this.current,
  });

  List<({IconData icon, String label, SidebarSection section, String? route})> _navItems(
    AppLocalizations l10n,
  ) =>
      [
        (icon: Icons.dashboard_outlined, label: l10n.navDashboard, section: SidebarSection.dashboard, route: '/user'),
        (icon: Icons.work_outline, label: l10n.navJobs, section: SidebarSection.jobs, route: '/jobs'),
        (icon: Icons.description_outlined, label: l10n.navResume, section: SidebarSection.resume, route: null),
        (icon: Icons.chat_bubble_outline, label: l10n.navMessages, section: SidebarSection.messages, route: null),
      ];

  static const double width = 216;

  @override
  Widget build(BuildContext context) {
    final initials = profile.name.isNotEmpty
        ? profile.name.trim().split(' ').take(2).map((w) => w[0]).join()
        : '?';

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
              _buildProfile(initials),
              const Divider(color: Colors.white12, height: 1),
              Expanded(child: _buildNav(context)),
              const Divider(color: Colors.white12, height: 1),
              _buildSettingsAndLogout(context),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfile(String initials) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 22, 16, 20),
      child: Column(
        spacing: 3,
        children: [
          Stack(
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
                    initials.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 15,
                  height: 15,
                  decoration: BoxDecoration(
                    color: AppColors.success,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.backgroundDark, width: 2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            profile.name,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            profile.role,
            style: const TextStyle(color: AppColors.textLight, fontSize: 11),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 3,
            children: [
              const Icon(Icons.location_on_outlined,
                  color: AppColors.textMuted, size: 12),
              Flexible(
                child: Text(
                  profile.location,
                  style: const TextStyle(color: AppColors.textMuted, fontSize: 10),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _ProgressBar(percent: profile.profileCompletion),
        ],
      ),
    );
  }

  Widget _buildNav(BuildContext context) {
    final items = _navItems(AppLocalizations.of(context)!);
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      itemCount: items.length,
      itemBuilder: (context, i) {
        final item = items[i];
        return _NavItem(
          icon: item.icon,
          label: item.label,
          isSelected: current == item.section,
          onTap: item.route == null ? () {} : () => context.go(item.route!),
        );
      },
    );
  }

  Widget _buildSettingsAndLogout(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        spacing: 2,
        children: [
          _NavItem(
            icon: Icons.settings_outlined,
            label: l10n.navSettings,
            isSelected: current == SidebarSection.settings,
            onTap: () => context.go('/settings'),
          ),
          _NavItem(
            icon: Icons.logout,
            label: l10n.navLogout,
            isSelected: false,
            isDanger: true,
            onTap: () => context.go('/'),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final bool isDanger;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.isDanger = false,
  });

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final Color baseColor = widget.isDanger
        ? AppColors.danger
        : widget.isSelected
            ? Colors.white
            : AppColors.textLight;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          margin: const EdgeInsets.symmetric(vertical: 2),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? AppColors.accent.withValues(alpha: 0.2)
                : _hovered
                    ? Colors.white.withValues(alpha: 0.06)
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
            border: widget.isSelected
                ? Border.all(color: AppColors.accent.withValues(alpha: 0.5))
                : null,
          ),
          child: Row(
            spacing: 10,
            children: [
              Icon(widget.icon, color: baseColor, size: 16),
              Expanded(
                child: Text(
                  widget.label,
                  style: TextStyle(
                    color: baseColor,
                    fontSize: 13,
                    fontWeight: widget.isSelected
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (widget.isSelected)
                Container(
                  width: 5,
                  height: 5,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.accentLight,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final int percent;

  const _ProgressBar({required this.percent});

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 6,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                AppLocalizations.of(context)!.profileCompletion,
                style: const TextStyle(color: AppColors.textLight, fontSize: 10),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              '$percent%',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percent / 100,
            minHeight: 5,
            backgroundColor: Colors.white12,
            valueColor:
                const AlwaysStoppedAnimation<Color>(AppColors.accentLight),
          ),
        ),
      ],
    );
  }
}
