import 'package:aplicativo_jobfy/core/theme/app_colors.dart';
import 'package:aplicativo_jobfy/data/repositories/job_repository_impl.dart';
import 'package:aplicativo_jobfy/domain/entities/job_entity.dart';
import 'package:aplicativo_jobfy/domain/usecases/job_usecase.dart';
import 'package:aplicativo_jobfy/features/job/presentation/controllers/job_controller.dart';
import 'package:aplicativo_jobfy/features/job/presentation/widgets/job_card.dart';
import 'package:aplicativo_jobfy/features/job/presentation/widgets/job_details_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class JobPage extends StatefulWidget {
  const JobPage({super.key});

  @override
  State<JobPage> createState() => _JobPageState();
}

class _JobPageState extends State<JobPage> {
  late final JobController _controller;
  final _buscaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = JobController(JobUsecase(JobRepositoryImpl()));
    _controller.loadJobs();
  }

  @override
  void dispose() {
    _buscaController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _limparBusca() {
    _buscaController.clear();
    _controller.setBusca('');
  }

  Future<void> _candidatar(JobEntity job) async {
    final ok = await _controller.candidatar(job.id);
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: ok ? AppColors.success : AppColors.danger,
          content: Text(
            ok
                ? 'Candidatura enviada para ${job.empresa}!'
                : 'Não foi possível enviar a candidatura.',
          ),
        ),
      );
  }

  void _abrirDetalhes(JobEntity job) {
    JobDetailsSheet.show(
      context,
      job: job,
      controller: _controller,
      onCandidatar: () => _candidatar(job),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.backgroundLight,
        body: ListenableBuilder(
          listenable: _controller,
          builder: (context, _) {
            return Column(
              children: [
                _Header(
                  total: _controller.jobsFiltradas.length,
                  buscaController: _buscaController,
                  onBuscaChanged: _controller.setBusca,
                  onLimpar: _limparBusca,
                ),
                _FilterChips(
                  selecionado: _controller.tipoSelecionado,
                  onSelected: _controller.selecionarTipo,
                ),
                Expanded(child: _buildBody()),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_controller.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.accent),
      );
    }

    if (_controller.status == JobStatus.error) {
      return _ErrorState(onRetry: () => _controller.loadJobs());
    }

    final jobs = _controller.jobsFiltradas;
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return RefreshIndicator(
      color: AppColors.accent,
      onRefresh: () => _controller.loadJobs(refresh: true),
      child: jobs.isEmpty
          ? const _EmptyState()
          : ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(16, 4, 16, 24 + bottomInset),
              itemCount: jobs.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final job = jobs[i];
                return JobCard(
                  job: job,
                  salva: _controller.estaSalva(job.id),
                  candidatado: _controller.jaCandidatou(job.id),
                  enviando: _controller.estaEnviando(job.id),
                  onTap: () => _abrirDetalhes(job),
                  onSalvar: () => _controller.toggleSalva(job.id),
                  onCandidatar: () => _candidatar(job),
                );
              },
            ),
    );
  }
}

class _Header extends StatelessWidget {
  final int total;
  final TextEditingController buscaController;
  final ValueChanged<String> onBuscaChanged;
  final VoidCallback onLimpar;

  const _Header({
    required this.total,
    required this.buscaController,
    required this.onBuscaChanged,
    required this.onLimpar,
  });

  @override
  Widget build(BuildContext context) {
    final semBorda = OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide.none,
    );

    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        MediaQuery.paddingOf(context).top + 16,
        20,
        20,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.backgroundDark, AppColors.backgroundDark2],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.lightbulb_circle, color: Colors.white, size: 26),
              SizedBox(width: 8),
              Text(
                'Jobfy',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'Vagas',
            style: TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            total == 1 ? '1 vaga para você' : '$total vagas para você',
            style: const TextStyle(color: AppColors.textLight, fontSize: 13),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: buscaController,
            onChanged: onBuscaChanged,
            textInputAction: TextInputAction.search,
            style: const TextStyle(fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Cargo, empresa ou local',
              prefixIcon: const Icon(
                Icons.search,
                size: 20,
                color: AppColors.textMuted,
              ),
              suffixIcon: buscaController.text.isEmpty
                  ? null
                  : IconButton(
                      onPressed: onLimpar,
                      tooltip: 'Limpar busca',
                      icon: const Icon(
                        Icons.close,
                        size: 18,
                        color: AppColors.textMuted,
                      ),
                    ),
              filled: true,
              fillColor: Colors.white,
              border: semBorda,
              enabledBorder: semBorda,
              focusedBorder: semBorda,
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChips extends StatelessWidget {
  final String selecionado;
  final ValueChanged<String> onSelected;

  const _FilterChips({required this.selecionado, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        itemCount: JobController.tiposFiltro.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final tipo = JobController.tiposFiltro[i];
          final ativo = tipo == selecionado;
          return ChoiceChip(
            label: Text(tipo),
            selected: ativo,
            onSelected: (_) => onSelected(tipo),
            showCheckmark: false,
            backgroundColor: Colors.white,
            selectedColor: AppColors.accent,
            side: BorderSide(
              color: ativo ? AppColors.accent : AppColors.cardBorder,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            labelStyle: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: ativo ? Colors.white : Colors.black87,
            ),
          );
        },
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    // ListView para o pull-to-refresh continuar funcionando sem resultados.
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(32, 64, 32, 32),
      children: const [
        Icon(Icons.search_off, size: 56, color: AppColors.textMuted),
        SizedBox(height: 16),
        Text(
          'Nenhuma vaga encontrada',
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        SizedBox(height: 6),
        Text(
          'Tente ajustar a busca ou os filtros.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13, color: AppColors.textMuted),
        ),
      ],
    );
  }
}

class _ErrorState extends StatelessWidget {
  final VoidCallback onRetry;

  const _ErrorState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 56, color: AppColors.danger),
            const SizedBox(height: 16),
            const Text(
              'Erro ao carregar vagas.',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 44,
              child: ElevatedButton(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text('Tentar novamente'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
