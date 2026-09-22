import 'package:aplicativo_jobfy/core/theme/app_colors.dart';
import 'package:aplicativo_jobfy/data/repositories/user_repository_impl.dart';
import 'package:aplicativo_jobfy/domain/entities/user_profile_entity.dart';
import 'package:aplicativo_jobfy/domain/usecases/user_usecase.dart';
import 'package:aplicativo_jobfy/features/user/presentation/controllers/user_controller.dart';
import 'package:aplicativo_jobfy/features/user/presentation/widgets/activity_item.dart';
import 'package:aplicativo_jobfy/features/user/presentation/widgets/job_match_card.dart';
import 'package:aplicativo_jobfy/features/user/presentation/widgets/profile_sidebar.dart';
import 'package:aplicativo_jobfy/features/user/presentation/widgets/stats_card.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class UserAreaPage extends StatefulWidget {
  const UserAreaPage({super.key});

  @override
  State<UserAreaPage> createState() => _UserAreaPageState();
}

class _UserAreaPageState extends State<UserAreaPage> {
  late final UserController _controller;

  @override
  void initState() {
    super.initState();
    _controller = UserController(UserUsecase(UserRepositoryImpl()));
    _controller.loadProfile('usr_001');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleNav(int index) {
    if (index == 1) {
      context.push('/jobs');
      return;
    }
    _controller.selectNav(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          if (_controller.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.accent),
            );
          }

          final profile = _controller.profile;
          if (profile == null) {
            return const Center(child: Text('Erro ao carregar perfil.'));
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ProfileSidebar(
                profile: profile,
                selectedIndex: _controller.selectedNavIndex,
                onNavTap: _handleNav,
              ),
              Expanded(
                child: _MainContent(
                  profile: profile,
                  navIndex: _controller.selectedNavIndex,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _MainContent extends StatelessWidget {
  final UserProfileEntity profile;
  final int navIndex;

  const _MainContent({required this.profile, required this.navIndex});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _TopBar(profile: profile),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(28, 0, 28, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 28),
                _WelcomeBanner(profile: profile),
                const SizedBox(height: 28),
                _StatsRow(profile: profile),
                const SizedBox(height: 28),
                _SkillsRow(profile: profile),
                const SizedBox(height: 28),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: _VagasSection(vagas: profile.vagasRecomendadas),
                    ),
                    const SizedBox(width: 20),
                    SizedBox(
                      width: 300,
                      child: _AtividadeSection(atividades: profile.atividades),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _TopBar extends StatelessWidget {
  final UserProfileEntity profile;

  const _TopBar({required this.profile});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.cardBorder)),
      ),
      child: Row(
        children: [
          const Icon(Icons.lightbulb_circle, size: 28),
          const SizedBox(width: 8),
          const Text(
            'Jobfy',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.backgroundLight,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Row(
              children: [
                const Icon(Icons.search, size: 16, color: AppColors.textMuted),
                const SizedBox(width: 6),
                const Text(
                  'Buscar vagas...',
                  style:
                      TextStyle(fontSize: 13, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
            style: IconButton.styleFrom(
              backgroundColor: AppColors.backgroundLight,
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.accent,
            child: Text(
              profile.nome.isNotEmpty ? profile.nome[0].toUpperCase() : '?',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WelcomeBanner extends StatelessWidget {
  final UserProfileEntity profile;

  const _WelcomeBanner({required this.profile});

  @override
  Widget build(BuildContext context) {
    final firstName = profile.nome.trim().split(' ').first;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [AppColors.backgroundDark, Color(0xFF1E3A5F)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Olá, $firstName! 👋',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Você tem novas vagas compatíveis com seu perfil.',
                  style: TextStyle(
                    color: AppColors.textLight,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => context.push('/jobs'),
                  icon: const Icon(Icons.bolt_outlined, size: 16),
                  label: const Text(
                    'Ver vagas recomendadas',
                    style: TextStyle(fontSize: 13),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
            child: Column(
              children: [
                const Icon(Icons.insights, color: Colors.white, size: 36),
                const SizedBox(height: 8),
                Text(
                  '${profile.matchScore}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  'Match médio',
                  style: TextStyle(
                    color: AppColors.textLight,
                    fontSize: 12,
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

class _StatsRow extends StatelessWidget {
  final UserProfileEntity profile;

  const _StatsRow({required this.profile});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: StatsCard(
            valor: '${profile.candidaturas}',
            titulo: 'Candidaturas',
            subtitulo: 'este mês',
            icon: Icons.send_outlined,
            iconColor: AppColors.accent,
            iconBg: AppColors.accent.withValues(alpha: 0.1),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: StatsCard(
            valor: '${profile.matchScore}%',
            titulo: 'Match Score',
            subtitulo: 'média geral',
            icon: Icons.bolt_outlined,
            iconColor: AppColors.warning,
            iconBg: AppColors.warning.withValues(alpha: 0.1),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: StatsCard(
            valor: '${profile.visualizacoes}',
            titulo: 'Visualizações',
            subtitulo: 'do seu perfil',
            icon: Icons.visibility_outlined,
            iconColor: AppColors.success,
            iconBg: AppColors.success.withValues(alpha: 0.1),
          ),
        ),
      ],
    );
  }
}

class _SkillsRow extends StatelessWidget {
  final UserProfileEntity profile;

  const _SkillsRow({required this.profile});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Row(
        children: [
          const Icon(Icons.auto_awesome, color: AppColors.accent, size: 20),
          const SizedBox(width: 10),
          const Text(
            'Habilidades',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Wrap(
              spacing: 8,
              runSpacing: 6,
              children: profile.habilidades
                  .map((h) => _SkillTag(label: h))
                  .toList(),
            ),
          ),
          TextButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.add, size: 16),
            label: const Text('Adicionar', style: TextStyle(fontSize: 13)),
            style: TextButton.styleFrom(foregroundColor: AppColors.accent),
          ),
        ],
      ),
    );
  }
}

class _SkillTag extends StatelessWidget {
  final String label;

  const _SkillTag({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.25)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.accent,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _VagasSection extends StatelessWidget {
  final List<JobMatchEntity> vagas;

  const _VagasSection({required this.vagas});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Vagas Recomendadas',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => context.push('/jobs'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.accent,
                ),
                child: const Text(
                  'Ver todas',
                  style: TextStyle(fontSize: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ...vagas.map((j) => Padding(
                padding: const EdgeInsets.only(top: 12),
                child: JobMatchCard(job: j),
              )),
        ],
      ),
    );
  }
}

class _AtividadeSection extends StatelessWidget {
  final List<ActivityEntity> atividades;

  const _AtividadeSection({required this.atividades});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Atividade Recente',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: AppColors.cardBorder),
          ...atividades.map((a) => Column(
                children: [
                  ActivityItem(activity: a),
                  const Divider(height: 1, color: AppColors.cardBorder),
                ],
              )),
        ],
      ),
    );
  }
}
