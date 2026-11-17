import 'package:jobfy/core/theme/app_breakpoints.dart';
import 'package:jobfy/core/theme/build_context_x.dart';
import 'package:jobfy/features/resume/presentation/pages/resume_page.dart';
import 'package:jobfy/features/user/data/repositories/user_repository_impl.dart';
import 'package:jobfy/features/user/domain/entities/user_profile_entity.dart';
import 'package:jobfy/features/user/domain/repositories/user_repository.dart';
import 'package:jobfy/features/user/domain/usecases/get_user_profile_usecase.dart';
import 'package:jobfy/features/user/presentation/user_labels.dart';
import 'package:jobfy/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// A candidate's profile as the company sees it (opened from the job's
/// candidate list), with a button to generate their resume as a PDF.
class CandidatePage extends StatefulWidget {
  /// The candidate's `users.user_id`.
  final String userId;

  /// Where the profile comes from. Defaults to [UserRepositoryImpl]; tests
  /// pass their own.
  final UserRepository? userRepository;

  const CandidatePage({super.key, required this.userId, this.userRepository});

  @override
  State<CandidatePage> createState() => _CandidatePageState();
}

class _CandidatePageState extends State<CandidatePage> {
  late final Future<UserProfileEntity> _profile;

  @override
  void initState() {
    super.initState();
    final usecase = GetUserProfileUsecase(widget.userRepository ?? UserRepositoryImpl());
    _profile = usecase(widget.userId);
  }

  void _openResume(UserProfileEntity profile) {
    Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: Text(profile.name)),
        body: ResumePreview(profile: profile),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;

    return FutureBuilder<UserProfileEntity>(
        future: _profile,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(l10n.companyCandidateLoadError, style: TextStyle(color: colors.danger)),
            );
          }
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final profile = snapshot.data!;
          return _CandidateProfile(profile: profile, onGenerateResume: () => _openResume(profile));
        },
        );
  }
}

class _CandidateProfile extends StatelessWidget {
  final UserProfileEntity profile;
  final VoidCallback onGenerateResume;

  const _CandidateProfile({required this.profile, required this.onGenerateResume});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final titleStyle = TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: colors.textPrimary);

    final rows = <(IconData, String, String?)>[
      (Icons.email_outlined, l10n.emailLabel, profile.email),
      (Icons.call_outlined, l10n.phoneLabel, profile.phone),
      (Icons.cake_outlined, l10n.birthDateLabel, profile.birthDate == null ? null : formatDate(profile.birthDate!)),
      (Icons.person_outline, l10n.genderLabel, profile.gender == null ? null : l10n.gender(profile.gender!)),
      (
        Icons.school_outlined,
        l10n.educationLevelLabel,
        profile.educationLevel == null ? null : l10n.educationLevel(profile.educationLevel!),
      ),
    ];

    return SingleChildScrollView(
      padding: EdgeInsets.all(context.pagePadding),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 16,
            children: [
              _Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 12,
                  children: [
                    Row(
                      spacing: 12,
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: colors.accent,
                          child: Text(
                            profile.name.isNotEmpty ? profile.name[0].toUpperCase() : '?',
                            style: TextStyle(color: colors.onAccent, fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                profile.name,
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: colors.textPrimary),
                              ),
                              if (profile.role.isNotEmpty)
                                Text(profile.role, style: TextStyle(fontSize: 13, color: colors.textMuted)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Text(l10n.registerSectionPersonal, style: titleStyle),
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
                                        (value ?? '').isEmpty ? l10n.notInformed : value!,
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: (value ?? '').isEmpty ? colors.textMuted : colors.textPrimary,
                                          fontStyle: (value ?? '').isEmpty ? FontStyle.italic : FontStyle.normal,
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
                  ],
                ),
              ),
              _Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 12,
                  children: [
                    Text(l10n.skillsTitle, style: titleStyle),
                    if (profile.skills.isEmpty)
                      Text(l10n.noSkillsYet, style: TextStyle(fontSize: 13, color: colors.textMuted))
                    else
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final s in profile.skills)
                            Chip(
                              label: Text('${s.name} · ${l10n.skillLevel(s.level)}', style: const TextStyle(fontSize: 12)),
                              visualDensity: VisualDensity.compact,
                            ),
                        ],
                      ),
                  ],
                ),
              ),
              _Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 12,
                  children: [
                    Text(l10n.resumeExperience, style: titleStyle),
                    if (profile.experiences.isEmpty)
                      Text(l10n.notInformed, style: TextStyle(fontSize: 13, color: colors.textMuted))
                    else
                      for (final e in profile.experiences)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 2,
                          children: [
                            Text(
                              '${e.jobTitle} · ${e.companyName}',
                              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: colors.textPrimary),
                            ),
                            Text(
                              '${formatMonthYear(e.startDate)} – '
                              '${e.endDate == null ? l10n.experiencePresent : formatMonthYear(e.endDate!)}',
                              style: TextStyle(fontSize: 12, color: colors.textMuted),
                            ),
                            if ((e.description ?? '').isNotEmpty)
                              Text(e.description!, style: TextStyle(fontSize: 13, color: colors.textPrimary)),
                          ],
                        ),
                  ],
                ),
              ),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: onGenerateResume,
                  icon: const Icon(Icons.picture_as_pdf_outlined, size: 18),
                  label: Text(l10n.companyGenerateResume, style: const TextStyle(fontSize: 15)),
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
