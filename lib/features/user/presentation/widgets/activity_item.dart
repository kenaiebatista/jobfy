import 'package:jobfy/core/theme/build_context_x.dart';
import 'package:jobfy/features/user/domain/entities/user_profile_entity.dart';
import 'package:flutter/material.dart';

class ActivityItem extends StatelessWidget {
  final ActivityEntity activity;

  const ActivityItem({super.key, required this.activity});

  IconData get _icon => switch (activity.type) {
        ActivityType.application => Icons.send_outlined,
        ActivityType.profileView => Icons.visibility_outlined,
        ActivityType.match => Icons.bolt_outlined,
        ActivityType.profile => Icons.person_outline,
        ActivityType.job => Icons.notifications_outlined,
      };

  Color _color(BuildContext context) {
    final colors = context.colors;
    return switch (activity.type) {
      ActivityType.application => colors.accent,
      ActivityType.profileView => colors.accent,
      ActivityType.match => colors.warning,
      ActivityType.profile => colors.success,
      ActivityType.job => colors.textMuted,
    };
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final color = _color(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(_icon, color: color, size: 17),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 2,
              children: [
                Text(
                  activity.description,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: colors.textPrimary,
                  ),
                ),
                Text(
                  activity.time,
                  style: TextStyle(
                    fontSize: 11,
                    color: colors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
