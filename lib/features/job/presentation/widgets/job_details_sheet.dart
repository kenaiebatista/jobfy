import 'package:aplicativo_jobfy/core/theme/app_colors.dart';
import 'package:aplicativo_jobfy/domain/entities/job_entity.dart';
import 'package:aplicativo_jobfy/features/job/presentation/controllers/job_controller.dart';
import 'package:aplicativo_jobfy/features/job/presentation/utils/tempo_relativo.dart';
import 'package:aplicativo_jobfy/features/job/presentation/widgets/job_apply_button.dart';
import 'package:aplicativo_jobfy/features/job/presentation/widgets/job_tag.dart';
import 'package:flutter/material.dart';

class JobDetailsSheet extends StatelessWidget {
  final JobEntity job;
  final JobController controller;
  final VoidCallback onCandidatar;

  const JobDetailsSheet({
    super.key,
    required this.job,
    required this.controller,
    required this.onCandidatar,
  });

  static Future<void> show(
    BuildContext context, {
    required JobEntity job,
    required JobController controller,
    required VoidCallback onCandidatar,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.9,
      ),
      builder: (_) => JobDetailsSheet(
        job: job,
        controller: controller,
        onCandidatar: onCandidatar,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 10),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.cardBorder,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: _Content(job: job),
            ),
          ),
          _BottomBar(
            job: job,
            controller: controller,
            onCandidatar: onCandidatar,
          ),
        ],
      ),
    );
  }
}

class _Content extends StatelessWidget {
  final JobEntity job;

  const _Content({required this.job});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.business_outlined,
                color: AppColors.accent,
                size: 26,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    job.titulo,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    job.empresa,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
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
        const SizedBox(height: 20),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.backgroundLight,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Faixa salarial',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      job.salario,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                'Publicada ${tempoRelativo(job.publicadaEm)}',
                style: const TextStyle(
                  fontSize: 11.5,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Sobre a vaga',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        const SizedBox(height: 8),
        Text(
          job.descricao,
          style: const TextStyle(
            fontSize: 13.5,
            height: 1.6,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Requisitos',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        const SizedBox(height: 8),
        ...job.requisitos.map(
          (r) => Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 1),
                  child: Icon(
                    Icons.check_circle_outline,
                    size: 16,
                    color: AppColors.accent,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    r,
                    style: const TextStyle(
                      fontSize: 13.5,
                      height: 1.4,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _BottomBar extends StatelessWidget {
  final JobEntity job;
  final JobController controller;
  final VoidCallback onCandidatar;

  const _BottomBar({
    required this.job,
    required this.controller,
    required this.onCandidatar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.cardBorder)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          child: ListenableBuilder(
            listenable: controller,
            builder: (context, _) {
              final salva = controller.estaSalva(job.id);
              return Row(
                children: [
                  SizedBox(
                    width: 48,
                    height: 48,
                    child: OutlinedButton(
                      onPressed: () => controller.toggleSalva(job.id),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        side: BorderSide(
                          color: salva ? AppColors.accent : AppColors.cardBorder,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Icon(
                        salva ? Icons.bookmark : Icons.bookmark_border,
                        color: salva ? AppColors.accent : AppColors.textMuted,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      width: double.infinity,
                      child: JobApplyButton(
                        candidatado: controller.jaCandidatou(job.id),
                        enviando: controller.estaEnviando(job.id),
                        onPressed: () {
                          // Fecha o sheet antes, para o SnackBar da página
                          // não ficar atrás do modal.
                          Navigator.of(context).pop();
                          onCandidatar();
                        },
                        height: 48,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
