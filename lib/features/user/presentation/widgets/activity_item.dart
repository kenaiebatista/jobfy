import 'package:jobfy/core/theme/app_colors.dart';
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

  Color get _color => switch (activity.type) {
        ActivityType.application => AppColors.accent,
        ActivityType.profileView => AppColors.accentLight,
        ActivityType.match => AppColors.warning,
        ActivityType.profile => AppColors.success,
        ActivityType.job => AppColors.textMuted,
      };

  @override
  Widget build(BuildContext context) {
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
              color: _color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(_icon, color: _color, size: 17),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 2,
              children: [
                Text(
                  activity.description,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  activity.time,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted,
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
