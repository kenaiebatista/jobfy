import 'package:aplicativo_jobfy/core/theme/app_colors.dart';
import 'package:aplicativo_jobfy/domain/entities/job_entity.dart';
import 'package:aplicativo_jobfy/features/job/presentation/utils/tempo_relativo.dart';
import 'package:aplicativo_jobfy/features/job/presentation/widgets/job_apply_button.dart';
import 'package:aplicativo_jobfy/features/job/presentation/widgets/job_tag.dart';
import 'package:flutter/material.dart';

class JobCard extends StatelessWidget {
  final JobEntity job;
  final bool salva;
  final bool candidatado;
  final bool enviando;
  final VoidCallback onTap;
  final VoidCallback onSalvar;
  final VoidCallback onCandidatar;

  const JobCard({
    super.key,
    required this.job,
    required this.salva,
    required this.candidatado,
    required this.enviando,
    required this.onTap,
    required this.onSalvar,
    required this.onCandidatar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.accent.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.business_outlined,
                        color: AppColors.accent,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            job.titulo,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            job.empresa,
                            style: const TextStyle(
                              fontSize: 12.5,
                              color: AppColors.textMuted,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: onSalvar,
                      tooltip: salva ? 'Remover dos salvos' : 'Salvar vaga',
                      visualDensity: VisualDensity.compact,
                      icon: Icon(
                        salva ? Icons.bookmark : Icons.bookmark_border,
                        color: salva ? AppColors.accent : AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    JobMatchBadge(percent: job.matchPercent),
                    JobTag(icon: Icons.location_on_outlined, label: job.local),
                    JobTag(icon: Icons.work_outline, label: job.tipo),
                    JobTag(icon: Icons.trending_up, label: job.nivel),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            job.salario,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            tempoRelativo(job.publicadaEm),
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    JobApplyButton(
                      candidatado: candidatado,
                      enviando: enviando,
                      onPressed: onCandidatar,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
