import 'package:jobfy/core/session/user_session_controller.dart';
import 'package:jobfy/core/theme/app_breakpoints.dart';
import 'package:jobfy/core/theme/app_colors.dart';
import 'package:jobfy/core/theme/build_context_x.dart';
import 'package:jobfy/l10n/app_localizations.dart';
import 'package:jobfy/features/user/domain/entities/user_profile_entity.dart';
import 'package:jobfy/features/user/presentation/widgets/activity_item.dart';
import 'package:jobfy/features/user/presentation/widgets/job_match_card.dart';
import 'package:jobfy/features/user/presentation/widgets/profile_sidebar.dart';
import 'package:jobfy/features/user/presentation/widgets/stats_card.dart';
import 'package:jobfy/shared/widgets/user_shell.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class UserAreaPage extends StatefulWidget {
  const UserAreaPage({super.key});

  @override
  State<UserAreaPage> createState() => _UserAreaPageState();
}

class _UserAreaPageState extends State<UserAreaPage> {
  @override
  void initState() {
    super.initState();
    context.read<UserSessionController>().ensureLoaded('usr_001');
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<UserSessionController>();
    return Scaffold(
      drawer: UserShell.drawer(
        context,
        profile: session.profile,
        current: SidebarSection.dashboard,
      ),
      body: UserShell(
        profile: session.profile,
        isError: session.status == UserSessionStatus.error,
        current: SidebarSection.dashboard,
        builder: (context, profile) => _MainContent(profile: profile),
      ),
    );
  }
}

class _MainContent extends StatelessWidget {
  final UserProfileEntity profile;

  const _MainContent({required this.profile});

  @override
  Widget build(BuildContext context) {
    final jobs = _JobsSection(jobs: profile.recommendedJobs);
    final activity = _ActivitySection(activities: profile.activities);
    final gap = context.responsive(mobile: 16.0, tablet: 20.0, laptop: 28.0);

    return Column(
      children: [
        _TopBar(profile: profile),
        Expanded(
          child: SingleChildScrollView(
            child: ResponsiveContent(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: gap,
                children: [
                  _WelcomeBanner(profile: profile),
                  _StatsRow(profile: profile),
                  _SkillsRow(profile: profile),
                  // Only a full desktop has room for the activity feed
                  // beside the jobs list; everything narrower stacks them.
                  if (context.isDesktop)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 20,
                      children: [
                        Expanded(flex: 3, child: jobs),
                        SizedBox(width: 300, child: activity),
                      ],
                    )
                  else ...[
                    jobs,
                    activity,
                  ],
                ],
              ),
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
    final colors = context.colors;
    final l10n = AppLocalizations.of(context)!;
    final compact = context.isMobile;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.pagePadding,
        vertical: context.responsive(mobile: 6.0, laptop: 14.0),
      ),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(bottom: BorderSide(color: colors.surfaceBorder)),
      ),
      child: Row(
        spacing: 8,
        children: [
          // Phones/tablets: the sidebar lives in a drawer opened from here.
          if (context.isCompactLayout) MenuButton(color: colors.textPrimary),
          Icon(Icons.lightbulb_circle, size: 28, color: colors.textPrimary),
          if (!compact)
            Text(
              l10n.appName,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: colors.textPrimary,
              ),
            ),
          const Spacer(),
          // Phones only get the search icon; the pill's label doesn't fit.
          if (compact)
            IconButton(
              icon: Icon(Icons.search, color: colors.textPrimary),
              onPressed: () => context.go('/jobs'),
              style: IconButton.styleFrom(backgroundColor: colors.background),
            )
          else
            InkWell(
              onTap: () => context.go('/jobs'),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: colors.background,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: colors.surfaceBorder),
                ),
                child: Row(
                  spacing: 6,
                  children: [
                    Icon(Icons.search, size: 16, color: colors.textMuted),
                    Text(
                      l10n.searchJobsPlaceholder,
                      style: TextStyle(fontSize: 13, color: colors.textMuted),
                    ),
                  ],
                ),
              ),
            ),
          IconButton(
            icon: Icon(Icons.notifications_outlined, color: colors.textPrimary),
            onPressed: () {},
            style: IconButton.styleFrom(backgroundColor: colors.background),
          ),
          CircleAvatar(
            radius: 18,
            backgroundColor: colors.accent,
            child: Text(
              profile.name.isNotEmpty ? profile.name[0].toUpperCase() : '?',
              style: TextStyle(
                color: colors.onAccent,
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
    final colors = context.colors;
    final l10n = AppLocalizations.of(context)!;
    final firstName = profile.name.trim().split(' ').first;
    final compact = context.isMobile;
    return Container(
      padding: EdgeInsets.all(context.responsive(mobile: 18.0, laptop: 24.0)),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [AppColors.backgroundDark, Color(0xFF1E3A5F)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        spacing: 20,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 6,
              children: [
                Text(
                  l10n.welcomeGreeting(firstName),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: context.responsive(mobile: 20.0, laptop: 24.0),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  l10n.welcomeSubtitle,
                  style: const TextStyle(
                    color: AppColors.textLight,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: () => context.go('/jobs'),
                  icon: const Icon(Icons.bolt_outlined, size: 16),
                  label: Text(
                    l10n.viewRecommendedJobs,
                    style: const TextStyle(fontSize: 13),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.accent,
                    foregroundColor: colors.onAccent,
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
          // The score badge is decorative; phones need the room for text.
          if (!compact)
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
                spacing: 8,
                children: [
                  const Icon(Icons.insights, color: Colors.white, size: 36),
                  Text(
                    '${profile.matchScore}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    l10n.avgMatch,
                    style: const TextStyle(
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
    final colors = context.colors;
    final l10n = AppLocalizations.of(context)!;
    final cards = [
      StatsCard(
        value: '${profile.applications}',
        title: l10n.statApplications,
        subtitle: l10n.statApplicationsSub,
        icon: Icons.send_outlined,
        iconColor: colors.accent,
        iconBg: colors.accent.withValues(alpha: 0.1),
      ),
      StatsCard(
        value: '${profile.matchScore}%',
        title: l10n.statMatchScore,
        subtitle: l10n.statMatchScoreSub,
        icon: Icons.bolt_outlined,
        iconColor: colors.warning,
        iconBg: colors.warning.withValues(alpha: 0.1),
      ),
      StatsCard(
        value: '${profile.profileViews}',
        title: l10n.statProfileViews,
        subtitle: l10n.statProfileViewsSub,
        icon: Icons.visibility_outlined,
        iconColor: colors.success,
        iconBg: colors.success.withValues(alpha: 0.1),
      ),
    ];

    // Phones stack the cards; tablets and up keep them side by side.
    if (context.isMobile) {
      return Column(spacing: 12, children: cards);
    }
    return Row(
      spacing: 16,
      children: [for (final card in cards) Expanded(child: card)],
    );
  }
}

class _SkillsRow extends StatelessWidget {
  final UserProfileEntity profile;

  const _SkillsRow({required this.profile});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context)!;
    final title = Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 10,
      children: [
        Icon(Icons.auto_awesome, color: colors.accent, size: 20),
        Text(
          l10n.skillsTitle,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: colors.textPrimary,
          ),
        ),
      ],
    );
    final tags = Wrap(
      spacing: 8,
      runSpacing: 6,
      children: profile.skills.map((s) => _SkillTag(label: s)).toList(),
    );
    final addButton = TextButton.icon(
      onPressed: () {},
      icon: const Icon(Icons.add, size: 16),
      label: Text(l10n.addSkill, style: const TextStyle(fontSize: 13)),
      style: TextButton.styleFrom(foregroundColor: colors.accent),
    );

    return Container(
      padding: EdgeInsets.all(context.responsive(mobile: 16.0, laptop: 20.0)),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.surfaceBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      // On phones the title, tags and button can't share one line.
      child: context.isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 10,
              children: [
                title,
                tags,
                Align(alignment: Alignment.centerRight, child: addButton),
              ],
            )
          : Row(
              spacing: 10,
              children: [title, Expanded(child: tags), addButton],
            ),
    );
  }
}

class _SkillTag extends StatelessWidget {
  final String label;

  const _SkillTag({required this.label});

  @override
  Widget build(BuildContext context) {
    final accent = context.colors.accent;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accent.withValues(alpha: 0.25)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: accent,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _JobsSection extends StatelessWidget {
  final List<JobMatchEntity> jobs;

  const _JobsSection({required this.jobs});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.surfaceBorder),
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
        spacing: 4,
        children: [
          Row(
            children: [
              Text(
                l10n.recommendedJobsTitle,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: colors.textPrimary,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => context.go('/jobs'),
                style: TextButton.styleFrom(foregroundColor: colors.accent),
                child: Text(
                  l10n.viewAll,
                  style: const TextStyle(fontSize: 13),
                ),
              ),
            ],
          ),
          ...jobs.map((j) => Padding(
                padding: const EdgeInsets.only(top: 12),
                child: JobMatchCard(job: j),
              )),
        ],
      ),
    );
  }
}

class _ActivitySection extends StatelessWidget {
  final List<ActivityEntity> activities;

  const _ActivitySection({required this.activities});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.surfaceBorder),
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
        spacing: 12,
        children: [
          Text(
            l10n.recentActivityTitle,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: colors.textPrimary,
            ),
          ),
          Divider(height: 1, color: colors.surfaceBorder),
          ...activities.map((a) => Column(
                children: [
                  ActivityItem(activity: a),
                  Divider(height: 1, color: colors.surfaceBorder),
                ],
              )),
        ],
      ),
    );
  }
}
