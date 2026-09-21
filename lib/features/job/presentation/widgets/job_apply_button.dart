import 'package:aplicativo_jobfy/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class JobApplyButton extends StatelessWidget {
  final bool candidatado;
  final bool enviando;
  final VoidCallback onPressed;
  final double height;
  final double fontSize;

  const JobApplyButton({
    super.key,
    required this.candidatado,
    required this.enviando,
    required this.onPressed,
    this.height = 36,
    this.fontSize = 12,
  });

  @override
  Widget build(BuildContext context) {
    final desabilitado = candidatado || enviando;

    return SizedBox(
      height: height,
      child: ElevatedButton(
        onPressed: desabilitado ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          disabledBackgroundColor: candidatado
              ? AppColors.success.withValues(alpha: 0.12)
              : Colors.black,
          disabledForegroundColor:
              candidatado ? AppColors.success : Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(height > 40 ? 12 : 8),
          ),
          elevation: 0,
        ),
        child: enviando
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (candidatado) ...[
                    Icon(Icons.check_circle_outline, size: fontSize + 4),
                    const SizedBox(width: 6),
                  ],
                  Text(
                    candidatado ? 'Candidatado' : 'Candidatar',
                    style: TextStyle(fontSize: fontSize),
                  ),
                ],
              ),
      ),
    );
  }
}
