import 'package:jobfy/core/session/user_session_controller.dart';
import 'package:jobfy/core/theme/app_breakpoints.dart';
import 'package:jobfy/core/theme/build_context_x.dart';
import 'package:jobfy/features/company/data/repositories/company_repository_impl.dart';
import 'package:jobfy/features/company/domain/entities/company_entity.dart';
import 'package:jobfy/features/company/domain/usecases/filter_candidates_usecase.dart';
import 'package:jobfy/features/company/domain/usecases/get_company_jobs_usecase.dart';
import 'package:jobfy/features/company/domain/usecases/get_company_usecase.dart';
import 'package:jobfy/features/company/domain/usecases/publish_job_usecase.dart';
import 'package:jobfy/features/company/domain/usecases/rate_candidate_usecase.dart';
import 'package:jobfy/features/company/domain/usecases/send_message_usecase.dart';
import 'package:jobfy/features/company/presentation/company_labels.dart';
import 'package:jobfy/features/company/presentation/controllers/company_controller.dart';
import 'package:jobfy/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

String companyErrorMessage(AppLocalizations l10n, String code) => switch (code) {
      'companyRegisterError' => l10n.companyRegisterError,
      'companyLoadError' => l10n.companyLoadError,
      'companyJobPublishError' => l10n.companyJobPublishError,
      'companyCandidateFilterError' => l10n.companyCandidateFilterError,
      'companyCandidateRateError' => l10n.companyCandidateRateError,
      'companyMessageSendError' => l10n.companyMessageSendError,
      _ => code,
    };

class CompanyPage extends StatefulWidget {
  const CompanyPage({super.key});

  @override
  State<CompanyPage> createState() => _CompanyPageState();
}

class _CompanyPageState extends State<CompanyPage> {
  late final CompanyController _controller;

  @override
  void initState() {
    super.initState();
    final repo = CompanyRepositoryImpl();
    _controller = CompanyController(
      getCompanyUsecase: GetCompanyUsecase(repo),
      getCompanyJobsUsecase: GetCompanyJobsUsecase(repo),
      publishJobUsecase: PublishJobUsecase(repo),
      filterCandidatesUsecase: FilterCandidatesUsecase(repo),
      rateCandidateUsecase: RateCandidateUsecase(repo),
      sendMessageUsecase: SendMessageUsecase(repo),
    );
    // The router only opens this page with a signed-in company.
    final companyId = context.read<UserSessionController>().companyId;
    if (companyId != null) _controller.load(companyId);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.canPop() ? context.pop() : context.go('/'),
        ),
        title: const Text('Jobfy'),
        actions: [
          IconButton(
            tooltip: AppLocalizations.of(context)!.navLogout,
            icon: const Icon(Icons.logout),
            onPressed: () {
              final session = context.read<UserSessionController>();
              context.go('/');
              session.clear();
            },
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          final company = _controller.company;
          if (company == null) {
            if (_controller.status == CompanyStatus.error) {
              return Center(
                child: Text(
                  companyErrorMessage(AppLocalizations.of(context)!, _controller.error ?? ''),
                  style: TextStyle(color: context.colors.danger),
                ),
              );
            }
            return const Center(child: CircularProgressIndicator());
          }
          return _CompanyDashboard(controller: _controller, company: company);
        },
      ),
    );
  }
}

class _CompanyDashboard extends StatefulWidget {
  final CompanyController controller;
  final CompanyEntity company;

  const _CompanyDashboard({required this.controller, required this.company});

  @override
  State<_CompanyDashboard> createState() => _CompanyDashboardState();
}

class _CompanyDashboardState extends State<_CompanyDashboard> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _contractTypeController = TextEditingController();
  final _salaryController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _contractTypeController.dispose();
    _salaryController.dispose();
    super.dispose();
  }

  void _publishJob() {
    if (_titleController.text.trim().isEmpty) return;
    widget.controller.publishJob(JobEntity(
      id: '',
      companyId: widget.company.companyId,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      location: _locationController.text.trim(),
      contractType: _contractTypeController.text.trim(),
      salary: _salaryController.text.trim(),
    ));
    _titleController.clear();
    _descriptionController.clear();
    _locationController.clear();
    _contractTypeController.clear();
    _salaryController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;

    return SingleChildScrollView(
      padding: EdgeInsets.all(context.pagePadding),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: context.responsive(mobile: 720.0, desktop: 880.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: context.responsive(mobile: 16.0, laptop: 24.0),
            children: [
              Text(
                l10n.companyWelcome(widget.company.displayName),
                style: TextStyle(
                  fontSize: context.responsive(mobile: 22.0, laptop: 26.0),
                  fontWeight: FontWeight.bold,
                ),
              ),
              _CompanyInfoCard(company: widget.company),
              _Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 12,
                  children: [
                    Text(
                      l10n.companyPublishJobTitle,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: colors.textPrimary),
                    ),
                    TextField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: l10n.jobTitleLabel,
                        hintText: l10n.jobTitleHint,
                      ),
                    ),
                    TextField(
                      controller: _descriptionController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: l10n.jobDescriptionLabel,
                        hintText: l10n.jobDescriptionHint,
                      ),
                    ),
                    // Side by side from tablet up; stacked on phones.
                    Flex(
                      direction:
                          context.isMobile ? Axis.vertical : Axis.horizontal,
                      spacing: 12,
                      children: [
                        for (final field in [
                          TextField(
                            controller: _locationController,
                            decoration: InputDecoration(
                              labelText: l10n.jobLocationLabel,
                              hintText: l10n.jobLocationHint,
                            ),
                          ),
                          TextField(
                            controller: _contractTypeController,
                            decoration: InputDecoration(
                              labelText: l10n.jobContractTypeLabel,
                              hintText: l10n.jobContractTypeHint,
                            ),
                          ),
                        ])
                          context.isMobile ? field : Expanded(child: field),
                      ],
                    ),
                    TextField(
                      controller: _salaryController,
                      decoration: InputDecoration(
                        labelText: l10n.jobSalaryLabel,
                        hintText: l10n.jobSalaryHint,
                      ),
                    ),
                    if (widget.controller.error == 'companyJobPublishError')
                      Text(
                        companyErrorMessage(l10n, widget.controller.error!),
                        style: TextStyle(color: colors.danger, fontSize: 13),
                      ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        onPressed: _publishJob,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colors.accent,
                          foregroundColor: colors.onAccent,
                        ),
                        child: Text(l10n.companyPublishJobButton),
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 12,
                children: [
                  Text(
                    l10n.companyJobsTitle,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: colors.textPrimary),
                  ),
                  if (widget.controller.jobs.isEmpty)
                    Text(
                      l10n.companyNoJobsYet,
                      style: TextStyle(color: colors.textMuted, fontSize: 13),
                    )
                  else
                    ...widget.controller.jobs.map((job) => _JobCard(
                          job: job,
                          onViewCandidates: () => _showCandidates(context, job),
                        )),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCandidates(BuildContext context, JobEntity job) {
    widget.controller.filterCandidates(job.id);
    showDialog(
      context: context,
      builder: (_) => _CandidatesDialog(controller: widget.controller, job: job),
    );
  }
}

/// The signed-in company's data (`companies` + account email).
class _CompanyInfoCard extends StatelessWidget {
  final CompanyEntity company;

  const _CompanyInfoCard({required this.company});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    String? opt(String? v) => (v == null || v.trim().isEmpty) ? null : v.trim();
    final place = [opt(company.city), opt(company.state)].whereType<String>().join(' - ');
    final zip = opt(company.zipCode);
    final rows = <(IconData, String, String?)>[
      (Icons.business_outlined, l10n.companyLegalNameLabel, opt(company.companyName)),
      (Icons.storefront_outlined, l10n.companyTradeNameLabel, opt(company.tradeName)),
      (Icons.badge_outlined, l10n.companyCnpjLabel, formatCnpj(company.cnpj)),
      (Icons.email_outlined, l10n.emailLabel, opt(company.email)),
      (Icons.call_outlined, l10n.companyPhoneLabel, opt(company.phone)),
      (Icons.work_outline, l10n.companyBusinessAreaLabel, opt(company.businessArea)),
      (Icons.location_on_outlined, l10n.companyAddressLabel, opt(company.address)),
      (Icons.location_city_outlined, '${l10n.companyCityLabel} / ${l10n.companyStateLabel}', place.isEmpty ? null : place),
      (Icons.markunread_mailbox_outlined, l10n.companyZipCodeLabel, zip == null ? null : formatZipCode(zip)),
    ];

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [
          Text(
            l10n.companySectionData,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: colors.textPrimary),
          ),
          Wrap(
            spacing: 24,
            runSpacing: 12,
            children: [
              for (final (icon, label, value) in rows)
                SizedBox(
                  width: 260,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 10,
                    children: [
                      Icon(icon, size: 16, color: colors.textMuted),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(label, style: TextStyle(fontSize: 11, color: colors.textMuted)),
                            Text(
                              value ?? l10n.notInformed,
                              style: TextStyle(
                                fontSize: 13,
                                color: value == null ? colors.textMuted : colors.textPrimary,
                                fontStyle: value == null ? FontStyle.italic : FontStyle.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          if (opt(company.description) != null) ...[
            Text(l10n.companyDescriptionLabel, style: TextStyle(fontSize: 11, color: colors.textMuted)),
            Text(company.description!, style: TextStyle(fontSize: 13, color: colors.textPrimary, height: 1.4)),
          ],
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;

  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.surfaceBorder),
      ),
      child: child,
    );
  }
}

class _JobCard extends StatelessWidget {
  final JobEntity job;
  final VoidCallback onViewCandidates;

  const _JobCard({required this.job, required this.onViewCandidates});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.surfaceBorder),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 2,
              children: [
                Text(
                  job.title,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: colors.textPrimary),
                ),
                Text(
                  [
                    job.location,
                    if (job.workMode != null) job.workMode!,
                    l10n.contractTypeFromDb(job.contractType),
                    job.salary,
                    if (job.status != null) l10n.jobStatus(job.status),
                  ].where((p) => p.isNotEmpty).join(' · '),
                  style: TextStyle(fontSize: 12, color: colors.textMuted),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: onViewCandidates,
            child: Text(l10n.companyViewCandidates),
          ),
        ],
      ),
    );
  }
}

class _CandidatesDialog extends StatefulWidget {
  final CompanyController controller;
  final JobEntity job;

  const _CandidatesDialog({required this.controller, required this.job});

  @override
  State<_CandidatesDialog> createState() => _CandidatesDialogState();
}

class _CandidatesDialogState extends State<_CandidatesDialog> {
  final _roleFilterController = TextEditingController();
  double _minMatch = 0;

  @override
  void dispose() {
    _roleFilterController.dispose();
    super.dispose();
  }

  void _applyFilter() {
    widget.controller.filterCandidates(
      widget.job.id,
      roleFilter: _roleFilterController.text.trim().isEmpty ? null : _roleFilterController.text.trim(),
      minMatch: _minMatch == 0 ? null : _minMatch.round(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520, maxHeight: 640),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 16,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.companyCandidatesTitle(widget.job.title),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              TextField(
                controller: _roleFilterController,
                decoration: InputDecoration(labelText: l10n.companyRoleFilterLabel),
                onSubmitted: (_) => _applyFilter(),
              ),
              StatefulBuilder(
                builder: (context, setLocalState) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.companyMinMatchLabel(_minMatch.round()),
                      style: const TextStyle(fontSize: 13),
                    ),
                    Slider(
                      value: _minMatch,
                      max: 100,
                      divisions: 20,
                      onChanged: (v) => setLocalState(() => _minMatch = v),
                      onChangeEnd: (_) => _applyFilter(),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListenableBuilder(
                  listenable: widget.controller,
                  builder: (context, _) {
                    final candidates = widget.controller.candidates;
                    if (candidates.isEmpty) {
                      return Center(
                        child: Text(
                          l10n.companyNoCandidates,
                          style: TextStyle(color: colors.textMuted, fontSize: 13),
                        ),
                      );
                    }
                    return ListView.separated(
                      itemCount: candidates.length,
                      separatorBuilder: (_, __) => const Divider(height: 16),
                      itemBuilder: (context, i) => _CandidateRow(
                        candidate: candidates[i],
                        controller: widget.controller,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CandidateRow extends StatelessWidget {
  final CandidateEntity candidate;
  final CompanyController controller;

  const _CandidateRow({required this.candidate, required this.controller});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(candidate.name, style: TextStyle(fontWeight: FontWeight.w600, color: colors.textPrimary)),
              Text(
                '${candidate.desiredRole} · ${candidate.matchPercent}%'
                '${candidate.rating != null ? ' · ★ ${candidate.rating}' : ''}',
                style: TextStyle(fontSize: 12, color: colors.textMuted),
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: l10n.companyRateCandidate,
          icon: const Icon(Icons.star_outline),
          onPressed: () => _showRateDialog(context, l10n),
        ),
        IconButton(
          tooltip: l10n.companyMessageCandidate,
          icon: const Icon(Icons.mail_outline),
          onPressed: () => _showMessageDialog(context, l10n),
        ),
      ],
    );
  }

  void _showRateDialog(BuildContext context, AppLocalizations l10n) {
    final ratingController = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.companyRateCandidate),
        content: TextField(
          controller: ratingController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(labelText: l10n.companyRatingLabel),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              final rating = double.tryParse(ratingController.text.replaceAll(',', '.'));
              if (rating == null) return;
              Navigator.pop(dialogContext);
              final messenger = ScaffoldMessenger.of(context);
              final ok = await controller.rateCandidate(candidate.id, rating);
              messenger.showSnackBar(SnackBar(
                content: Text(ok
                    ? l10n.companyRatingSaved
                    : companyErrorMessage(l10n, controller.error ?? '')),
              ));
            },
            child: Text(l10n.companySend),
          ),
        ],
      ),
    );
  }

  void _showMessageDialog(BuildContext context, AppLocalizations l10n) {
    final messageController = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.companyMessageCandidate),
        content: TextField(
          controller: messageController,
          maxLines: 3,
          decoration: InputDecoration(
            labelText: l10n.companyMessageLabel,
            hintText: l10n.companyMessageHint,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              final text = messageController.text.trim();
              if (text.isEmpty) return;
              Navigator.pop(dialogContext);
              final messenger = ScaffoldMessenger.of(context);
              final ok = await controller.sendMessage(candidate.id, text);
              messenger.showSnackBar(SnackBar(
                content: Text(ok
                    ? l10n.companyMessageSent
                    : companyErrorMessage(l10n, controller.error ?? '')),
              ));
            },
            child: Text(l10n.companySend),
          ),
        ],
      ),
    );
  }
}
