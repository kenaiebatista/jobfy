import 'package:jobfy/core/theme/app_colors.dart';
import 'package:jobfy/features/company/data/repositories/company_repository_impl.dart';
import 'package:jobfy/features/company/domain/entities/company_entity.dart';
import 'package:jobfy/features/company/domain/usecases/filter_candidates_usecase.dart';
import 'package:jobfy/features/company/domain/usecases/publish_job_usecase.dart';
import 'package:jobfy/features/company/domain/usecases/rate_candidate_usecase.dart';
import 'package:jobfy/features/company/domain/usecases/register_company_usecase.dart';
import 'package:jobfy/features/company/domain/usecases/send_message_usecase.dart';
import 'package:jobfy/features/company/presentation/controllers/company_controller.dart';
import 'package:jobfy/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

String companyErrorMessage(AppLocalizations l10n, String code) => switch (code) {
      'companyRegisterError' => l10n.companyRegisterError,
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
      registerCompanyUsecase: RegisterCompanyUsecase(repo),
      publishJobUsecase: PublishJobUsecase(repo),
      filterCandidatesUsecase: FilterCandidatesUsecase(repo),
      rateCandidateUsecase: RateCandidateUsecase(repo),
      sendMessageUsecase: SendMessageUsecase(repo),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.canPop() ? context.pop() : context.go('/'),
        ),
        title: const Text('Jobfy'),
      ),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          final company = _controller.company;
          if (company == null) {
            return _CompanyRegistrationForm(controller: _controller);
          }
          return _CompanyDashboard(controller: _controller, company: company, colors: colors);
        },
      ),
    );
  }
}

class _CompanyRegistrationForm extends StatefulWidget {
  final CompanyController controller;

  const _CompanyRegistrationForm({required this.controller});

  @override
  State<_CompanyRegistrationForm> createState() => _CompanyRegistrationFormState();
}

class _CompanyRegistrationFormState extends State<_CompanyRegistrationForm> {
  final _nameController = TextEditingController();
  final _cnpjController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _cnpjController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _submit() {
    widget.controller.registerCompany(CompanyEntity(
      companyId: '',
      companyName: _nameController.text.trim(),
      cnpj: _cnpjController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isLoading = widget.controller.isLoading;
    final error = widget.controller.error;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 16,
            children: [
              Text(
                l10n.companyRegisterTitle,
                style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              Text(
                l10n.companyRegisterSubtitle,
                style: const TextStyle(fontSize: 14, color: AppColors.textMuted),
              ),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: l10n.companyNameLabel,
                  hintText: l10n.companyNameHint,
                  prefixIcon: const Icon(Icons.business_outlined, size: 18),
                ),
              ),
              TextField(
                controller: _cnpjController,
                decoration: InputDecoration(
                  labelText: l10n.companyCnpjLabel,
                  hintText: l10n.companyCnpjHint,
                  prefixIcon: const Icon(Icons.badge_outlined, size: 18),
                ),
              ),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: l10n.emailLabel,
                  hintText: l10n.emailHint,
                  prefixIcon: const Icon(Icons.email_outlined, size: 18),
                ),
              ),
              TextField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: l10n.companyPhoneLabel,
                  hintText: l10n.companyPhoneHint,
                  prefixIcon: const Icon(Icons.call_outlined, size: 18),
                ),
              ),
              if (error != null)
                Text(
                  companyErrorMessage(l10n, error),
                  style: const TextStyle(color: AppColors.danger, fontSize: 13),
                ),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : Text(l10n.companyRegisterButton),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CompanyDashboard extends StatefulWidget {
  final CompanyController controller;
  final CompanyEntity company;
  final ColorScheme colors;

  const _CompanyDashboard({
    required this.controller,
    required this.company,
    required this.colors,
  });

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
    final colors = widget.colors;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 24,
            children: [
              Text(
                l10n.companyWelcome(widget.company.companyName),
                style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              _Card(
                colors: colors,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 12,
                  children: [
                    Text(
                      l10n.companyPublishJobTitle,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: colors.onSurface),
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
                    Row(
                      spacing: 12,
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _locationController,
                            decoration: InputDecoration(
                              labelText: l10n.jobLocationLabel,
                              hintText: l10n.jobLocationHint,
                            ),
                          ),
                        ),
                        Expanded(
                          child: TextField(
                            controller: _contractTypeController,
                            decoration: InputDecoration(
                              labelText: l10n.jobContractTypeLabel,
                              hintText: l10n.jobContractTypeHint,
                            ),
                          ),
                        ),
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
                        style: const TextStyle(color: AppColors.danger, fontSize: 13),
                      ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        onPressed: _publishJob,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          foregroundColor: Colors.white,
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
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: colors.onSurface),
                  ),
                  if (widget.controller.jobs.isEmpty)
                    Text(
                      l10n.companyNoJobsYet,
                      style: TextStyle(color: colors.onSurfaceVariant, fontSize: 13),
                    )
                  else
                    ...widget.controller.jobs.map((job) => _JobCard(
                          job: job,
                          colors: colors,
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

class _Card extends StatelessWidget {
  final ColorScheme colors;
  final Widget child;

  const _Card({required this.colors, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: child,
    );
  }
}

class _JobCard extends StatelessWidget {
  final JobEntity job;
  final ColorScheme colors;
  final VoidCallback onViewCandidates;

  const _JobCard({required this.job, required this.colors, required this.onViewCandidates});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.outlineVariant),
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
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: colors.onSurface),
                ),
                Text(
                  '${job.location} · ${job.contractType} · ${job.salary}',
                  style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant),
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
    final colors = Theme.of(context).colorScheme;

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
                          style: TextStyle(color: colors.onSurfaceVariant, fontSize: 13),
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
    final colors = Theme.of(context).colorScheme;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(candidate.name, style: TextStyle(fontWeight: FontWeight.w600, color: colors.onSurface)),
              Text(
                '${candidate.desiredRole} · ${candidate.matchPercent}%'
                '${candidate.rating != null ? ' · ★ ${candidate.rating}' : ''}',
                style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant),
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
