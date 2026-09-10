import 'package:jobfy/core/session/user_session_controller.dart';
import 'package:jobfy/core/theme/build_context_x.dart';
import 'package:jobfy/features/jobs/data/repositories/job_repository_impl.dart';
import 'package:jobfy/features/jobs/domain/entities/job_listing_entity.dart';
import 'package:jobfy/features/jobs/domain/usecases/apply_to_job_usecase.dart';
import 'package:jobfy/features/jobs/domain/usecases/search_jobs_usecase.dart';
import 'package:jobfy/features/jobs/presentation/controllers/job_controller.dart';
import 'package:jobfy/features/user/presentation/widgets/profile_sidebar.dart';
import 'package:jobfy/l10n/app_localizations.dart';
import 'package:jobfy/shared/widgets/user_shell.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class JobsPage extends StatefulWidget {
  const JobsPage({super.key});

  @override
  State<JobsPage> createState() => _JobsPageState();
}

class _JobsPageState extends State<JobsPage> {
  final _queryController = TextEditingController();
  final _locationController = TextEditingController();
  late final JobController _controller;

  @override
  void initState() {
    super.initState();
    final repo = JobRepositoryImpl();
    _controller = JobController(
      SearchJobsUsecase(repo),
      ApplyToJobUsecase(repo),
    );
    _controller.search();
    context.read<UserSessionController>().ensureLoaded('usr_001');
  }

  @override
  void dispose() {
    _queryController.dispose();
    _locationController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _runSearch() {
    _controller.search(
      query: _queryController.text.trim(),
      location: _locationController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final session = context.watch<UserSessionController>();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () =>
              context.canPop() ? context.pop() : context.go('/user'),
        ),
        title: Text(l10n.jobsPageTitle),
      ),
      body: UserShell(
        profile: session.profile,
        isError: session.status == UserSessionStatus.error,
        current: SidebarSection.jobs,
        builder: (context, profile) => Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    spacing: 12,
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextField(
                          controller: _queryController,
                          decoration: InputDecoration(
                            hintText: l10n.searchJobsPlaceholder,
                            prefixIcon: const Icon(Icons.search, size: 18),
                          ),
                          onSubmitted: (_) => _runSearch(),
                        ),
                      ),
                      Expanded(
                        child: TextField(
                          controller: _locationController,
                          decoration: InputDecoration(
                            hintText: l10n.jobsLocationHint,
                            prefixIcon: const Icon(
                              Icons.location_on_outlined,
                              size: 18,
                            ),
                          ),
                          onSubmitted: (_) => _runSearch(),
                        ),
                      ),
                      IconButton.filled(
                        onPressed: _runSearch,
                        icon: const Icon(Icons.arrow_forward),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListenableBuilder(
                    listenable: _controller,
                    builder: (context, _) {
                      if (_controller.isLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (_controller.error != null) {
                        return Center(
                          child: Text(
                            l10n.jobSearchError,
                            style: TextStyle(color: colors.danger),
                          ),
                        );
                      }
                      if (_controller.jobs.isEmpty) {
                        return Center(
                          child: Text(
                            l10n.jobsNoResults,
                            style: TextStyle(color: colors.textMuted),
                          ),
                        );
                      }
                      return ListView.separated(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                        itemCount: _controller.jobs.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, i) => _JobListingCard(
                          job: _controller.jobs[i],
                          controller: _controller,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _JobListingCard extends StatelessWidget {
  final JobListingEntity job;
  final JobController controller;

  const _JobListingCard({required this.job, required this.controller});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final applied = controller.hasApplied(job.id);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.surfaceBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      job.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: colors.textPrimary,
                      ),
                    ),
                    Text(
                      job.company,
                      style: TextStyle(fontSize: 13, color: colors.textMuted),
                    ),
                  ],
                ),
              ),
              if (job.matchPercent != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: colors.success.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${job.matchPercent}%',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: colors.success,
                    ),
                  ),
                ),
            ],
          ),
          Row(
            spacing: 8,
            children: [
              _Tag(icon: Icons.location_on_outlined, label: job.location),
              _Tag(icon: Icons.work_outline, label: job.type),
            ],
          ),
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 8,
            children: [
              Text(
                job.salary,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                spacing: 8,
                children: [
                  TextButton(
                    onPressed: () => _showDetails(context, l10n),
                    child: Text(l10n.jobViewDetails),
                  ),
                  ElevatedButton(
                    onPressed: applied ? null : () => _apply(context, l10n),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.accent,
                      foregroundColor: colors.onAccent,
                    ),
                    child: Text(
                      applied ? l10n.jobAlreadyApplied : l10n.applyButton,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _apply(BuildContext context, AppLocalizations l10n) async {
    final messenger = ScaffoldMessenger.of(context);
    final ok = await controller.apply(job.id);
    messenger.showSnackBar(
      SnackBar(content: Text(ok ? l10n.jobApplySuccess : l10n.jobApplyError)),
    );
  }

  void _showDetails(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(job.title),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 8,
            children: [
              Text('${job.company} · ${job.location} · ${job.type}'),
              Text(
                job.salary,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              Text(job.description),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.settingsBack),
          ),
        ],
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
          Text(label, style: TextStyle(fontSize: 11, color: colors.textMuted)),
        ],
      ),
    );
  }
}
