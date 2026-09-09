import 'package:jobfy/core/theme/app_colors.dart';
import 'package:jobfy/features/user/domain/entities/user_profile_entity.dart';
import 'package:jobfy/l10n/app_localizations.dart';
import 'package:jobfy/shared/widgets/glow_circle.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ProfileSidebar extends StatelessWidget {
  final UserProfileEntity profile;
  final int selectedIndex;
  final ValueChanged<int> onNavTap;

  const ProfileSidebar({
    super.key,
    required this.profile,
    required this.selectedIndex,
    required this.onNavTap,
  });

  List<({IconData icon, String label})> _navItems(AppLocalizations l10n) => [
        (icon: Icons.dashboard_outlined, label: l10n.navDashboard),
        (icon: Icons.work_outline, label: l10n.navJobs),
        (icon: Icons.description_outlined, label: l10n.navResume),
        (icon: Icons.chat_bubble_outline, label: l10n.navMessages),
        (icon: Icons.settings_outlined, label: l10n.navSettings),
      ];

  @override
  Widget build(BuildContext context) {
    final initials = profile.name.isNotEmpty
        ? profile.name.trim().split(' ').take(2).map((w) => w[0]).join()
        : '?';

    return SizedBox(
      width: 260,
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
            child: GlowCircle(size: 280, color: Color(0x331D4ED8)),
          ),
          const Positioned(
            bottom: 40, right: -60,
            child: GlowCircle(size: 250, color: Color(0x264F46E5)),
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
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
      child: Column(
        spacing: 4,
        children: [
          Stack(
            children: [
              Container(
                width: 72,
                height: 72,
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
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: AppColors.success,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.backgroundDark, width: 2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            profile.name,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            profile.role,
            style: const TextStyle(color: AppColors.textLight, fontSize: 12),
            textAlign: TextAlign.center,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 3,
            children: [
              const Icon(Icons.location_on_outlined,
                  color: AppColors.textMuted, size: 13),
              Text(
                profile.location,
                style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _ProgressBar(percent: profile.profileCompletion),
        ],
      ),
    );
  }

  Widget _buildNav(BuildContext context) {
    final items = _navItems(AppLocalizations.of(context)!);
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      itemCount: items.length,
      itemBuilder: (context, i) {
        final item = items[i];
        final isSelected = selectedIndex == i;
        return _NavItem(
          icon: item.icon,
          label: item.label,
          isSelected: isSelected,
          onTap: () => onNavTap(i),
        );
      },
    );
  }

  Widget _buildSettingsAndLogout(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        spacing: 2,
        children: [
          _NavItem(
            icon: Icons.settings_outlined,
            label: l10n.navSettings,
            isSelected: false,
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
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          margin: const EdgeInsets.symmetric(vertical: 2),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? AppColors.accent.withValues(alpha: 0.2)
                : _hovered
                    ? Colors.white.withValues(alpha: 0.06)
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: widget.isSelected
                ? Border.all(color: AppColors.accent.withValues(alpha: 0.5))
                : null,
          ),
          child: Row(
            spacing: 12,
            children: [
              Icon(widget.icon, color: baseColor, size: 18),
              Text(
                widget.label,
                style: TextStyle(
                  color: baseColor,
                  fontSize: 14,
                  fontWeight: widget.isSelected
                      ? FontWeight.w600
                      : FontWeight.normal,
                ),
              ),
              if (widget.isSelected) ...[
                const Spacer(),
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.accentLight,
                  ),
                ),
              ],
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
            Text(
              AppLocalizations.of(context)!.profileCompletion,
              style: const TextStyle(color: AppColors.textLight, fontSize: 11),
            ),
            const Spacer(),
            Text(
              '$percent%',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
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
