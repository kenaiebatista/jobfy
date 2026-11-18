import 'package:jobfy/core/session/user_session_controller.dart';
import 'package:jobfy/core/theme/app_breakpoints.dart';
import 'package:jobfy/core/theme/build_context_x.dart';
import 'package:jobfy/features/company/data/repositories/company_repository_impl.dart';
import 'package:jobfy/features/company/domain/entities/company_entity.dart';
import 'package:jobfy/features/company/domain/repositories/company_repository.dart';
import 'package:jobfy/features/company/domain/usecases/get_company_jobs_usecase.dart';
import 'package:jobfy/features/company/domain/usecases/get_company_usecase.dart';
import 'package:jobfy/features/company/domain/usecases/get_job_candidates_usecase.dart';
import 'package:jobfy/features/company/domain/usecases/publish_job_usecase.dart';
import 'package:jobfy/features/company/domain/usecases/set_candidate_status_usecase.dart';
import 'package:jobfy/features/company/domain/usecases/set_job_status_usecase.dart';
import 'package:jobfy/features/company/domain/usecases/update_job_usecase.dart';
import 'package:jobfy/features/company/presentation/company_labels.dart';
import 'package:jobfy/features/company/presentation/controllers/company_controller.dart';
import 'package:jobfy/features/company/presentation/widgets/job_form.dart';
import 'package:jobfy/features/user/presentation/user_labels.dart';
import 'package:jobfy/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

String companyErrorMessage(AppLocalizations l10n, String code) => switch (code) {
      'companyRegisterError' => l10n.companyRegisterError,
      'companyLoadError' => l10n.companyLoadError,
      'companyJobPublishError' => l10n.companyJobPublishError,
      'companyJobUpdateError' => l10n.companyJobUpdateError,
      'companyJobStatusError' => l10n.companyJobStatusError,
      'companyCandidateStatusError' => l10n.companyCandidateStatusError,
      'companyCandidateFilterError' => l10n.companyCandidateFilterError,
      'companyMessageSendError' => l10n.companyMessageSendError,
      _ => code,
    };

class CompanyPage extends StatefulWidget {
  /// Where the data comes from. Defaults to [CompanyRepositoryImpl]
  /// (MySQL/fake/remote per AppConfig); tests pass their own.
  final CompanyRepository? repository;

  const CompanyPage({super.key, this.repository});

  @override
  State<CompanyPage> createState() => _CompanyPageState();
}

class _CompanyPageState extends State<CompanyPage> {
  late final CompanyController _controller;

  @override
  void initState() {
    super.initState();
    final repo = widget.repository ?? CompanyRepositoryImpl();
    _controller = CompanyController(
      getCompanyUsecase: GetCompanyUsecase(repo),
      getCompanyJobsUsecase: GetCompanyJobsUsecase(repo),
      publishJobUsecase: PublishJobUsecase(repo),
      updateJobUsecase: UpdateJobUsecase(repo),
      setJobStatusUsecase: SetJobStatusUsecase(repo),
      setCandidateStatusUsecase: SetCandidateStatusUsecase(repo),
      getJobCandidatesUsecase: GetJobCandidatesUsecase(repo),
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
    return ListenableBuilder(
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
  Future<bool> _publishJob(NewJobEntity job) async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final ok = await widget.controller.publishJob(job);
    if (ok) messenger.showSnackBar(SnackBar(content: Text(l10n.companyJobPublished)));
    return ok;
  }

  Future<void> _editJob(JobEntity job) {
    return showDialog<void>(
      context: context,
      builder: (_) => _EditJobDialog(
        controller: widget.controller,
        companyId: widget.company.companyId,
        job: job,
      ),
    );
  }

  /// Closes (after asking), pauses or reopens the job.
  Future<void> _setStatus(JobEntity job, JobStatus status) async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);

    if (status == JobStatus.closed) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(l10n.companyCloseJob),
          content: Text(l10n.companyCloseJobConfirm),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l10n.dialogCancel),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: TextButton.styleFrom(foregroundColor: ctx.colors.danger),
              child: Text(l10n.companyCloseJob),
            ),
          ],
        ),
      );
      if (confirmed != true || !mounted) return;
    }

    final ok = await widget.controller.setJobStatus(job.id, status);
    messenger.showSnackBar(SnackBar(
      content: Text(ok
          ? (status == JobStatus.closed ? l10n.companyJobClosed : l10n.companyJobReopened)
          : companyErrorMessage(l10n, widget.controller.error ?? '')),
    ));
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
                    JobForm(
                      companyId: widget.company.companyId,
                      submitLabel: l10n.companyPublishJobButton,
                      isBusy: widget.controller.isPublishing,
                      errorText: widget.controller.error == 'companyJobPublishError'
                          ? companyErrorMessage(l10n, widget.controller.error!)
                          : null,
                      onSubmit: _publishJob,
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
                          onEdit: () => _editJob(job),
                          onSetStatus: (status) => _setStatus(job, status),
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
    widget.controller.loadCandidates(job.id);
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
  final VoidCallback onEdit;
  final ValueChanged<JobStatus> onSetStatus;

  const _JobCard({
    required this.job,
    required this.onViewCandidates,
    required this.onEdit,
    required this.onSetStatus,
  });

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
            child: Text('${l10n.companyViewCandidates} (${job.candidateCount})'),
          ),
          PopupMenuButton<String>(
            tooltip: l10n.companyJobOptions,
            onSelected: (action) => switch (action) {
              'edit' => onEdit(),
              'close' => onSetStatus(JobStatus.closed),
              _ => onSetStatus(JobStatus.open),
            },
            itemBuilder: (_) => [
              PopupMenuItem(value: 'edit', child: Text(l10n.companyEditJob)),
              if (job.status == JobStatus.closed.name)
                PopupMenuItem(value: 'reopen', child: Text(l10n.companyReopenJob))
              else
                PopupMenuItem(value: 'close', child: Text(l10n.companyCloseJob)),
            ],
          ),
        ],
      ),
    );
  }
}

/// Edit form of one job, in a dialog; closes itself once the job is saved.
class _EditJobDialog extends StatelessWidget {
  final CompanyController controller;
  final String companyId;
  final JobEntity job;

  const _EditJobDialog({required this.controller, required this.companyId, required this.job});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640, maxHeight: 760),
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
                      l10n.companyEditJobTitle,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              Flexible(
                child: SingleChildScrollView(
                  child: ListenableBuilder(
                    listenable: controller,
                    builder: (context, _) => JobForm(
                      companyId: companyId,
                      initial: job,
                      submitLabel: l10n.companySaveJobButton,
                      isBusy: controller.isPublishing,
                      errorText: controller.error == 'companyJobUpdateError'
                          ? companyErrorMessage(l10n, controller.error!)
                          : null,
                      onSubmit: (updated) async {
                        final messenger = ScaffoldMessenger.of(context);
                        final ok = await controller.updateJob(job.id, updated);
                        if (ok && context.mounted) {
                          Navigator.pop(context);
                          messenger.showSnackBar(SnackBar(content: Text(l10n.companyJobUpdated)));
                        }
                        return ok;
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Who applied to one job, with a search by name. Tapping a candidate
/// opens their profile.
class _CandidatesDialog extends StatefulWidget {
  final CompanyController controller;
  final JobEntity job;

  const _CandidatesDialog({required this.controller, required this.job});

  @override
  State<_CandidatesDialog> createState() => _CandidatesDialogState();
}

class _CandidatesDialogState extends State<_CandidatesDialog> {
  String _nameFilter = '';

  Future<void> _answer(CandidateEntity candidate, ApplicationStatus status) async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final ok = await widget.controller.setCandidateStatus(widget.job.id, candidate, status);
    if (!ok) {
      messenger.showSnackBar(SnackBar(
        content: Text(companyErrorMessage(l10n, widget.controller.error ?? '')),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;

    Widget message(String text, {Color? color}) => Center(
          child: Text(text, style: TextStyle(color: color ?? colors.textMuted, fontSize: 13)),
        );

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
                decoration: InputDecoration(
                  hintText: l10n.companyCandidateSearchHint,
                  prefixIcon: const Icon(Icons.search, size: 18),
                ),
                onChanged: (v) => setState(() => _nameFilter = v.trim().toLowerCase()),
              ),
              Expanded(
                child: ListenableBuilder(
                  listenable: widget.controller,
                  builder: (context, _) {
                    if (widget.controller.isLoadingCandidates) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (widget.controller.error == 'companyCandidateFilterError') {
                      return message(l10n.companyCandidateFilterError, color: colors.danger);
                    }
                    final all = widget.controller.candidates;
                    if (all.isEmpty) return message(l10n.companyNoCandidates);
                    final candidates =
                        all.where((c) => c.name.toLowerCase().contains(_nameFilter)).toList();
                    if (candidates.isEmpty) return message(l10n.companyNoCandidatesFound);
                    return ListView.separated(
                      itemCount: candidates.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, i) => _CandidateRow(
                        candidate: candidates[i],
                        onAnswer: (status) => _answer(candidates[i], status),
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

enum _CandidateAction { approve, reject, backToReview, message }

class _CandidateRow extends StatelessWidget {
  final CandidateEntity candidate;
  final ValueChanged<ApplicationStatus> onAnswer;

  const _CandidateRow({required this.candidate, required this.onAnswer});

  void _onAction(BuildContext context, _CandidateAction action) {
    switch (action) {
      case _CandidateAction.approve:
        onAnswer(ApplicationStatus.approved);
      case _CandidateAction.reject:
        onAnswer(ApplicationStatus.rejected);
      case _CandidateAction.backToReview:
        onAnswer(ApplicationStatus.underReview);
      case _CandidateAction.message:
        // Close the dialog, then open the chat with this candidate.
        final router = GoRouter.of(context);
        Navigator.pop(context);
        router.push('/messages?with=${candidate.id}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final appliedAt = candidate.appliedAt;
    final status = candidate.status;
    final statusColor = switch (status) {
      'approved' => colors.success,
      'rejected' => colors.danger,
      'withdrawn' => colors.textMuted,
      _ => colors.warning,
    };

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: colors.accent,
        child: Text(
          candidate.name.isNotEmpty ? candidate.name[0].toUpperCase() : '?',
          style: TextStyle(color: colors.onAccent, fontWeight: FontWeight.bold),
        ),
      ),
      title: Row(
        spacing: 8,
        children: [
          Flexible(
            child: Text(
              candidate.name,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontWeight: FontWeight.w600, color: colors.textPrimary),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              l10n.applicationStatus(status),
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: statusColor),
            ),
          ),
        ],
      ),
      subtitle: Text(
        [
          candidate.email,
          if (appliedAt != null) l10n.companyCandidateAppliedOn(formatDate(appliedAt)),
        ].join(' · '),
        style: TextStyle(fontSize: 12, color: colors.textMuted),
      ),
      // Same answer buttons for any status but the current one; a withdrawn
      // application can't be answered.
      trailing: status == ApplicationStatus.withdrawn.dbValue
          ? Icon(Icons.chevron_right, color: colors.textMuted)
          : PopupMenuButton<_CandidateAction>(
              tooltip: l10n.companyAnswerCandidate,
              onSelected: (action) => _onAction(context, action),
              itemBuilder: (_) => [
                // Messages are only possible after the approval.
                if (status == ApplicationStatus.approved.dbValue)
                  PopupMenuItem(value: _CandidateAction.message, child: Text(l10n.companySendMessage)),
                if (status != ApplicationStatus.approved.dbValue)
                  PopupMenuItem(value: _CandidateAction.approve, child: Text(l10n.companyApproveCandidate)),
                if (status != ApplicationStatus.rejected.dbValue)
                  PopupMenuItem(value: _CandidateAction.reject, child: Text(l10n.companyRejectCandidate)),
                if (status != ApplicationStatus.underReview.dbValue)
                  PopupMenuItem(value: _CandidateAction.backToReview, child: Text(l10n.companyBackToReview)),
              ],
            ),
      onTap: () => context.push('/company/candidates/${candidate.id}'),
    );
  }
}
