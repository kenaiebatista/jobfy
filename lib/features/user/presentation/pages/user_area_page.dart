import 'package:jobfy/core/theme/app_colors.dart';
import 'package:jobfy/l10n/app_localizations.dart';
import 'package:jobfy/features/user/data/repositories/user_repository_impl.dart';
import 'package:jobfy/features/user/domain/entities/user_profile_entity.dart';
import 'package:jobfy/features/user/domain/usecases/get_user_profile_usecase.dart';
import 'package:jobfy/features/user/presentation/controllers/user_controller.dart';
import 'package:jobfy/features/user/presentation/widgets/activity_item.dart';
import 'package:jobfy/features/user/presentation/widgets/job_match_card.dart';
import 'package:jobfy/features/user/presentation/widgets/profile_sidebar.dart';
import 'package:jobfy/features/user/presentation/widgets/stats_card.dart';
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
    _controller = UserController(
      GetUserProfileUsecase(UserRepositoryImpl()),
    );
    _controller.loadProfile('usr_001');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            return Center(
              child: Text(AppLocalizations.of(context)!.userAreaLoadError),
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ProfileSidebar(
                profile: profile,
                selectedIndex: _controller.selectedNavIndex,
                onNavTap: _controller.selectNav,
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
              spacing: 28,
              children: [
                const SizedBox(height: 4),
                _WelcomeBanner(profile: profile),
                _StatsRow(profile: profile),
                _SkillsRow(profile: profile),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 20,
                  children: [
                    Expanded(
                      flex: 3,
                      child: _JobsSection(jobs: profile.recommendedJobs),
                    ),
                    SizedBox(
                      width: 300,
                      child: _ActivitySection(activities: profile.activities),
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
    final colors = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(bottom: BorderSide(color: colors.outlineVariant)),
      ),
      child: Row(
        spacing: 8,
        children: [
          Icon(Icons.lightbulb_circle, size: 28, color: colors.onSurface),
          Text(
            l10n.appName,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: colors.onSurface,
            ),
          ),
          const Spacer(),
          InkWell(
            onTap: () => context.go('/jobs'),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: colors.outlineVariant),
              ),
              child: Row(
                spacing: 6,
                children: [
                  Icon(Icons.search, size: 16, color: colors.onSurfaceVariant),
                  Text(
                    l10n.searchJobsPlaceholder,
                    style: TextStyle(fontSize: 13, color: colors.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.notifications_outlined, color: colors.onSurface),
            onPressed: () {},
            style: IconButton.styleFrom(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            ),
          ),
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.accent,
            child: Text(
              profile.name.isNotEmpty ? profile.name[0].toUpperCase() : '?',
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
    final l10n = AppLocalizations.of(context)!;
    final firstName = profile.name.trim().split(' ').first;
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
        spacing: 20,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 6,
              children: [
                Text(
                  l10n.welcomeGreeting(firstName),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
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
    final l10n = AppLocalizations.of(context)!;
    return Row(
      spacing: 16,
      children: [
        Expanded(
          child: StatsCard(
            value: '${profile.applications}',
            title: l10n.statApplications,
            subtitle: l10n.statApplicationsSub,
            icon: Icons.send_outlined,
            iconColor: AppColors.accent,
            iconBg: AppColors.accent.withValues(alpha: 0.1),
          ),
        ),
        Expanded(
          child: StatsCard(
            value: '${profile.matchScore}%',
            title: l10n.statMatchScore,
            subtitle: l10n.statMatchScoreSub,
            icon: Icons.bolt_outlined,
            iconColor: AppColors.warning,
            iconBg: AppColors.warning.withValues(alpha: 0.1),
          ),
        ),
        Expanded(
          child: StatsCard(
            value: '${profile.profileViews}',
            title: l10n.statProfileViews,
            subtitle: l10n.statProfileViewsSub,
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
    final colors = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        spacing: 10,
        children: [
          const Icon(Icons.auto_awesome, color: AppColors.accent, size: 20),
          Text(
            l10n.skillsTitle,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: colors.onSurface,
            ),
          ),
          Expanded(
            child: Wrap(
              spacing: 8,
              runSpacing: 6,
              children: profile.skills
                  .map((s) => _SkillTag(label: s))
                  .toList(),
            ),
          ),
          TextButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.add, size: 16),
            label: Text(l10n.addSkill, style: const TextStyle(fontSize: 13)),
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

class _JobsSection extends StatelessWidget {
  final List<JobMatchEntity> jobs;

  const _JobsSection({required this.jobs});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.outlineVariant),
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
                  color: colors.onSurface,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => context.go('/jobs'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.accent,
                ),
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
    final colors = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.outlineVariant),
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
              color: colors.onSurface,
            ),
          ),
          Divider(height: 1, color: colors.outlineVariant),
          ...activities.map((a) => Column(
                children: [
                  ActivityItem(activity: a),
                  Divider(height: 1, color: colors.outlineVariant),
                ],
              )),
        ],
      ),
    );
  }
}
