import 'package:jobfy/core/session/user_session_controller.dart';
import 'package:jobfy/core/theme/app_breakpoints.dart';
import 'package:jobfy/core/theme/build_context_x.dart';
import 'package:jobfy/features/resume/domain/resume_requirements.dart';
import 'package:jobfy/features/resume/presentation/resume_pdf.dart';
import 'package:jobfy/features/user/domain/entities/user_profile_entity.dart';
import 'package:jobfy/features/user/presentation/widgets/profile_sidebar.dart';
import 'package:jobfy/l10n/app_localizations.dart';
import 'package:jobfy/shared/widgets/user_shell.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';

/// "Resume" tab. Every visit reloads the profile from the database and
/// generates the PDF again, so it always reflects the current data. The
/// PDF only lives in memory; the Share button lets the user send or save it.
class ResumePage extends StatefulWidget {
  const ResumePage({super.key});

  @override
  State<ResumePage> createState() => _ResumePageState();
}

class _ResumePageState extends State<ResumePage> {
  @override
  void initState() {
    super.initState();
    // Deferred so the reload's notifyListeners doesn't run mid-build.
    Future.microtask(() {
      if (mounted) context.read<UserSessionController>().reload();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final session = context.watch<UserSessionController>();

    return Scaffold(
      drawer: UserShell.drawer(
        context,
        profile: session.profile,
        current: SidebarSection.resume,
      ),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.canPop() ? context.pop() : context.go('/user'),
        ),
        title: Text(l10n.resumePageTitle),
        actions: const [MenuButton(color: Colors.white)],
      ),
      body: UserShell(
        profile: session.profile,
        isError: session.status == UserSessionStatus.error,
        current: SidebarSection.resume,
        builder: (context, profile) {
          if (session.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          final missing = missingResumeInfo(profile);
          if (missing.isNotEmpty) return _MissingInfo(missing: missing);
          return _ResumePreview(profile: profile);
        },
      ),
    );
  }
}

class _ResumePreview extends StatelessWidget {
  final UserProfileEntity profile;

  const _ResumePreview({required this.profile});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    // e.g. "curriculo-maria-silva.pdf" (name used when sharing).
    final fileSlug = profile.name.trim().toLowerCase().replaceAll(RegExp(r'\s+'), '-');

    return PdfPreview(
      build: (_) => buildResumePdf(profile, l10n),
      pdfFileName: 'curriculo-$fileSlug.pdf',
      allowSharing: true,
      allowPrinting: false,
      canChangePageFormat: false,
      canChangeOrientation: false,
      canDebug: false,
      maxPageWidth: 700,
      scrollViewDecoration: BoxDecoration(color: colors.background),
      actionBarTheme: PdfActionBarTheme(
        backgroundColor: colors.surface,
        iconColor: colors.accent,
      ),
      onError: (context, _) => Center(
        child: Text(l10n.resumeError, style: TextStyle(color: colors.danger)),
      ),
    );
  }
}

/// Shown instead of the PDF while the profile lacks required information,
/// with a shortcut to the settings screen where it can be filled in.
class _MissingInfo extends StatelessWidget {
  final List<ResumeRequirement> missing;

  const _MissingInfo({required this.missing});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;

    String label(ResumeRequirement r) => switch (r) {
          ResumeRequirement.phone => l10n.phoneLabel,
          ResumeRequirement.educationLevel => l10n.educationLevelLabel,
        };

    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(context.pagePadding),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 440),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colors.surfaceBorder),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 12,
            children: [
              Icon(Icons.description_outlined, size: 36, color: colors.accent),
              Text(
                l10n.resumeMissingTitle,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: colors.textPrimary,
                ),
              ),
              Text(
                l10n.resumeMissingBody,
                style: TextStyle(fontSize: 14, color: colors.textMuted),
              ),
              for (final r in missing)
                Row(
                  spacing: 8,
                  children: [
                    Icon(Icons.radio_button_unchecked, size: 16, color: colors.warning),
                    Text(label(r), style: TextStyle(fontSize: 14, color: colors.textPrimary)),
                  ],
                ),
              const SizedBox(height: 4),
              ElevatedButton.icon(
                onPressed: () => context.go('/settings'),
                icon: const Icon(Icons.edit_outlined, size: 16),
                label: Text(l10n.resumeCompleteProfile),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.accent,
                  foregroundColor: colors.onAccent,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
