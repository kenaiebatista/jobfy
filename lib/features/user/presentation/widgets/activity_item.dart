import 'package:aplicativo_jobfy/core/theme/app_colors.dart';
import 'package:aplicativo_jobfy/domain/entities/user_profile_entity.dart';
import 'package:flutter/material.dart';

class ActivityItem extends StatelessWidget {
  final ActivityEntity activity;

  const ActivityItem({super.key, required this.activity});

  IconData get _icon => switch (activity.tipo) {
        'candidatura' => Icons.send_outlined,
        'visualizacao' => Icons.visibility_outlined,
        'match' => Icons.bolt_outlined,
        'perfil' => Icons.person_outline,
        _ => Icons.notifications_outlined,
      };

  Color get _color => switch (activity.tipo) {
        'candidatura' => AppColors.accent,
        'visualizacao' => AppColors.accentLight,
        'match' => AppColors.warning,
        'perfil' => AppColors.success,
        _ => AppColors.textMuted,
      };

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
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
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.descricao,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  activity.tempo,
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
