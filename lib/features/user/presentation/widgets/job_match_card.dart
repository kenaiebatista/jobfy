import 'package:jobfy/core/theme/build_context_x.dart';
import 'package:jobfy/features/user/domain/entities/user_profile_entity.dart';
import 'package:jobfy/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class JobMatchCard extends StatefulWidget {
  final JobMatchEntity job;

  const JobMatchCard({super.key, required this.job});

  @override
  State<JobMatchCard> createState() => _JobMatchCardState();
}

class _JobMatchCardState extends State<JobMatchCard> {
  bool _hovered = false;

  Color _matchColor(BuildContext context) {
    final colors = context.colors;
    final p = widget.job.matchPercent;
    if (p >= 90) return colors.success;
    if (p >= 70) return colors.warning;
    return colors.textMuted;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final matchColor = _matchColor(context);
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _hovered ? colors.accent.withValues(alpha: 0.4) : colors.surfaceBorder,
          ),
          boxShadow: [
            BoxShadow(
              color: _hovered
                  ? colors.accent.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.03),
              blurRadius: _hovered ? 16 : 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 10,
          children: [
            Row(
              spacing: 12,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: colors.accent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.business_outlined,
                    color: colors.accent,
                    size: 20,
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.job.title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: colors.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        widget.job.company,
                        style: TextStyle(
                          fontSize: 12,
                          color: colors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: matchColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${widget.job.matchPercent}%',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: matchColor,
                    ),
                  ),
                ),
              ],
            ),
            Row(
              spacing: 8,
              children: [
                _Tag(icon: Icons.location_on_outlined, label: widget.job.location),
                _Tag(icon: Icons.work_outline, label: widget.job.type),
              ],
            ),
            Row(
              children: [
                Text(
                  widget.job.salary,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: colors.textPrimary,
                  ),
                ),
                const Spacer(),
                SizedBox(
                  height: 32,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.accent,
                      foregroundColor: colors.onAccent,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.applyButton,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final IconData icon;
  final String label;

  const _Tag({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: colors.surfaceBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 4,
        children: [
          Icon(icon, size: 11, color: colors.textMuted),
          Text(
            label,
            style: TextStyle(fontSize: 11, color: colors.textMuted),
          ),
        ],
      ),
    );
  }
}
