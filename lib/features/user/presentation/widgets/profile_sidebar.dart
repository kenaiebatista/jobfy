import 'package:aplicativo_jobfy/core/theme/app_colors.dart';
import 'package:aplicativo_jobfy/domain/entities/user_profile_entity.dart';
import 'package:aplicativo_jobfy/shared/widgets/glow_circle.dart';
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

  static const _navItems = [
    (icon: Icons.dashboard_outlined, label: 'Dashboard'),
    (icon: Icons.work_outline, label: 'Vagas'),
    (icon: Icons.description_outlined, label: 'Currículo'),
    (icon: Icons.chat_bubble_outline, label: 'Mensagens'),
    (icon: Icons.settings_outlined, label: 'Configurações'),
  ];

  @override
  Widget build(BuildContext context) {
    final initials = profile.nome.isNotEmpty
        ? profile.nome.trim().split(' ').take(2).map((w) => w[0]).join()
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
              Expanded(child: _buildNav()),
              const Divider(color: Colors.white12, height: 1),
              _buildLogout(context),
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
          const SizedBox(height: 14),
          Text(
            profile.nome,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            profile.cargo,
            style: const TextStyle(color: AppColors.textLight, fontSize: 12),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.location_on_outlined,
                  color: AppColors.textMuted, size: 13),
              const SizedBox(width: 3),
              Text(
                profile.localizacao,
                style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _ProgressBar(percent: profile.perfilCompleto),
        ],
      ),
    );
  }

  Widget _buildNav() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      itemCount: _navItems.length,
      itemBuilder: (context, i) {
        final item = _navItems[i];
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

  Widget _buildLogout(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: _NavItem(
        icon: Icons.logout,
        label: 'Sair',
        isSelected: false,
        isDanger: true,
        onTap: () => context.go('/'),
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
            children: [
              Icon(widget.icon, color: baseColor, size: 18),
              const SizedBox(width: 12),
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
      children: [
        Row(
          children: [
            const Text(
              'Perfil completo',
              style: TextStyle(color: AppColors.textLight, fontSize: 11),
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
        const SizedBox(height: 6),
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
