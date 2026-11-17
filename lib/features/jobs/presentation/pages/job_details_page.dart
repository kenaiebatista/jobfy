import 'package:jobfy/core/session/user_session_controller.dart';
import 'package:jobfy/core/theme/app_breakpoints.dart';
import 'package:jobfy/core/theme/build_context_x.dart';
import 'package:jobfy/features/company/presentation/company_labels.dart';
import 'package:jobfy/features/jobs/data/repositories/job_repository_impl.dart';
import 'package:jobfy/features/jobs/domain/entities/job_details_entity.dart';
import 'package:jobfy/features/jobs/domain/repositories/job_repository.dart';
import 'package:jobfy/features/jobs/domain/usecases/apply_to_job_usecase.dart';
import 'package:jobfy/features/jobs/domain/usecases/get_job_details_usecase.dart';
import 'package:jobfy/features/jobs/presentation/controllers/job_details_controller.dart';
import 'package:jobfy/features/user/presentation/user_labels.dart';
import 'package:jobfy/l10n/app_localizations.dart';
import 'package:jobfy/shared/widgets/app_shell.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Opened from the job list: everything about one job and its company,
/// with the button to apply.
class JobDetailsPage extends StatefulWidget {
  final String jobId;

  /// Where the job comes from. Defaults to [JobRepositoryImpl] (MySQL or
  /// remote per AppConfig); tests pass their own.
  final JobRepository? repository;

  const JobDetailsPage({super.key, required this.jobId, this.repository});

  @override
  State<JobDetailsPage> createState() => _JobDetailsPageState();
}

class _JobDetailsPageState extends State<JobDetailsPage> {
  late final JobDetailsController _controller;

  @override
  void initState() {
    super.initState();
    final repo = widget.repository ?? JobRepositoryImpl();
    _controller = JobDetailsController(
      GetJobDetailsUsecase(repo),
      ApplyToJobUsecase(repo),
    );
    final session = context.read<UserSessionController>();
    _controller.load(widget.jobId, userId: session.userId);
    session.ensureLoaded();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _apply() async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final session = context.read<UserSessionController>();
    final userId = session.userId;
    if (userId == null) return;

    final ok = await _controller.apply(userId);
    messenger.showSnackBar(
      SnackBar(content: Text(ok ? l10n.jobApplySuccess : l10n.jobApplyError)),
    );
    // The dashboard counts the user's applications.
    if (ok) session.reload();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final session = context.watch<UserSessionController>();

    return ProfileGate(
        profile: session.profile,
        isError: session.status == UserSessionStatus.error,
        builder: (context, profile) => ListenableBuilder(
          listenable: _controller,
          builder: (context, _) {
            final job = _controller.job;
            switch (_controller.status) {
              case JobDetailsStatus.loading:
                return const Center(child: CircularProgressIndicator());
              case JobDetailsStatus.notFound:
                return Center(
                  child: Text(l10n.jobNotFound, style: TextStyle(color: colors.textMuted)),
                );
              case JobDetailsStatus.error:
                return Center(
                  child: Text(l10n.jobDetailsLoadError, style: TextStyle(color: colors.danger)),
                );
              case JobDetailsStatus.loaded:
                return _JobDetails(
                  job: job!,
                  isApplying: _controller.isApplying,
                  onApply: _apply,
                );
            }
          },
        ),
      );
  }
}

class _JobDetails extends StatelessWidget {
  final JobDetailsEntity job;
  final bool isApplying;
  final VoidCallback onApply;

  const _JobDetails({
    required this.job,
    required this.isApplying,
    required this.onApply,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final place = [job.companyCity, job.companyState].whereType<String>().join(' - ');

    final String buttonLabel;
    if (job.hasApplied) {
      buttonLabel = l10n.jobAlreadyApplied;
    } else if (!job.isOpen) {
      buttonLabel = l10n.jobStatus(job.status);
    } else {
      buttonLabel = l10n.applyButton;
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(context.pagePadding),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 16,
            children: [
              _Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 4,
                  children: [
                    Text(
                      job.title,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: colors.textPrimary,
                      ),
                    ),
                    Text(
                      job.companyDisplayName,
                      style: TextStyle(fontSize: 14, color: colors.textMuted),
                    ),
                    if (job.publishedAt != null)
                      Text(
                        l10n.jobPublishedOn(formatDate(job.publishedAt!)),
                        style: TextStyle(fontSize: 12, color: colors.textMuted),
                      ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 24,
                      runSpacing: 12,
                      children: [
                        _InfoItem(icon: Icons.payments_outlined, label: l10n.jobSalary, value: job.salary),
                        _InfoItem(icon: Icons.schedule_outlined, label: l10n.jobWorkloadLabel, value: job.workload),
                        _InfoItem(icon: Icons.location_on_outlined, label: l10n.jobLocationLabel, value: job.location),
                        _InfoItem(icon: Icons.home_work_outlined, label: l10n.jobWorkModeLabel, value: job.workMode),
                        _InfoItem(
                          icon: Icons.description_outlined,
                          label: l10n.jobContractTypeLabel,
                          value: l10n.contractTypeFromDb(job.contractType),
                        ),
                        _InfoItem(icon: Icons.category_outlined, label: l10n.jobAreaLabel, value: job.area),
                      ],
                    ),
                  ],
                ),
              ),
              _TextSection(title: l10n.jobDescriptionLabel, text: job.description),
              _TextSection(title: l10n.jobRequirementsLabel, text: job.requirements),
              _TextSection(title: l10n.jobBenefitsLabel, text: job.benefits),
              _Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 12,
                  children: [
                    Text(
                      l10n.jobAboutCompany,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: colors.textPrimary),
                    ),
                    Wrap(
                      spacing: 24,
                      runSpacing: 12,
                      children: [
                        _InfoItem(icon: Icons.business_outlined, label: l10n.companyLegalNameLabel, value: job.companyName),
                        _InfoItem(icon: Icons.work_outline, label: l10n.companyBusinessAreaLabel, value: job.companyBusinessArea),
                        _InfoItem(
                          icon: Icons.location_city_outlined,
                          label: '${l10n.companyCityLabel} / ${l10n.companyStateLabel}',
                          value: place.isEmpty ? null : place,
                        ),
                        _InfoItem(icon: Icons.call_outlined, label: l10n.companyPhoneLabel, value: job.companyPhone),
                        _InfoItem(icon: Icons.email_outlined, label: l10n.emailLabel, value: job.companyEmail),
                      ],
                    ),
                    if (job.companyDescription != null)
                      Text(
                        job.companyDescription!,
                        style: TextStyle(fontSize: 13, color: colors.textPrimary, height: 1.4),
                      ),
                  ],
                ),
              ),
              if (job.hasApplied) _ApplicationStatus(status: job.applicationStatus!),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: job.hasApplied || !job.isOpen || isApplying ? null : onApply,
                  icon: isApplying
                      ? SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: colors.onAccent),
                        )
                      : Icon(job.hasApplied ? Icons.check : Icons.send_outlined, size: 18),
                  label: Text(buttonLabel, style: const TextStyle(fontSize: 15)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.accent,
                    foregroundColor: colors.onAccent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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

/// "Your application: Under review / Approved / Rejected".
class _ApplicationStatus extends StatelessWidget {
  final String status;

  const _ApplicationStatus({required this.status});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final (color, icon) = switch (status) {
      'approved' => (colors.success, Icons.check_circle_outline),
      'rejected' => (colors.danger, Icons.cancel_outlined),
      'withdrawn' => (colors.textMuted, Icons.remove_circle_outline),
      _ => (colors.warning, Icons.hourglass_empty),
    };
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        spacing: 10,
        children: [
          Icon(icon, size: 18, color: color),
          Expanded(
            child: Text(
              l10n.jobApplicationStatus(l10n.applicationStatus(status)),
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: color),
            ),
          ),
        ],
      ),
    );
  }
}

/// A titled block of free text (description, requirements, benefits).
/// Hidden when the company left it empty.
class _TextSection extends StatelessWidget {
  final String title;
  final String? text;

  const _TextSection({required this.title, required this.text});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    if ((text ?? '').trim().isEmpty) return const SizedBox.shrink();
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: [
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: colors.textPrimary),
          ),
          Text(text!, style: TextStyle(fontSize: 14, color: colors.textPrimary, height: 1.5)),
        ],
      ),
    );
  }
}

/// Icon, small label and value, like the company data card.
class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? value;

  const _InfoItem({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final missing = value == null || value!.trim().isEmpty;
    return SizedBox(
      width: 220,
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
                  missing ? l10n.notInformed : value!,
                  style: TextStyle(
                    fontSize: 13,
                    color: missing ? colors.textMuted : colors.textPrimary,
                    fontStyle: missing ? FontStyle.italic : FontStyle.normal,
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

class _Card extends StatelessWidget {
  final Widget child;

  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      width: double.infinity,
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
