import '../../domain/entities/user_profile_entity.dart';
import 'package:jobfy/features/jobs/data/datasources/job_data_source.dart';
import '../../domain/recommend_jobs.dart';
import 'package:jobfy/features/jobs/data/datasources/job_mysql_data_source.dart';
import 'user_data_source.dart';
import '../models/user_profile_model.dart';

/// In-memory stand-in for [UserRemoteDataSource], used until the Go backend
/// is deployed.
class UserFakeDataSource implements UserDataSource {
  /// Where the recommended jobs come from. Tests pass their own so they
  /// don't need a running database.
  final JobDataSource _jobs;

  UserFakeDataSource([JobDataSource? jobs]) : _jobs = jobs ?? JobMysqlDataSource();

  static const _baseSkills = [
    UserSkillEntity(name: 'Flutter', level: SkillLevel.advanced),
    UserSkillEntity(name: 'Dart', level: SkillLevel.advanced),
    UserSkillEntity(name: 'Firebase', level: SkillLevel.intermediate),
    UserSkillEntity(name: 'UI/UX'),
    UserSkillEntity(name: 'REST APIs', level: SkillLevel.intermediate),
  ];

  /// Edits from the settings screen, kept until the app restarts.
  static UserProfileModel? _saved;
  static String _password = 'admin';

  @override
  Future<UserProfileModel> getUserProfile(String userId) async {
    await Future.delayed(const Duration(milliseconds: 600));
    final saved = _saved;
    if (saved != null) return saved;

    // Recommended jobs are the first 3 open jobs from the MySQL database.
    // If the database can't be reached the dashboard still loads, just
    // without recommendations.
    List<JobMatchEntity> recommendedJobs = [];
    try {
      recommendedJobs = recommendJobs(await _jobs.searchJobs(), _baseSkills);
    } catch (_) {}

    return UserProfileModel(
      id: 'usr_001',
      name: 'Victor Henrique',
      email: 'victor.henrique@email.com',
      role: 'Flutter Developer',
      location: 'Gaspar, SC',
      profileCompletion: 75,
      applications: 12,
      matchScore: 89,
      profileViews: 234,
      skills: _baseSkills,
      recommendedJobs: recommendedJobs,
      activities: const [
        ActivityEntity(
          description: 'Candidatura enviada para TechNova Soluções Digitais',
          time: 'há 2 horas',
          type: ActivityType.application,
        ),
        ActivityEntity(
          description: 'Perfil visualizado por Verde Agro Analytics',
          time: 'há 5 horas',
          type: ActivityType.profileView,
        ),
        ActivityEntity(
          description: 'Match de 91% com Pixel Criativo Studio',
          time: 'ontem',
          type: ActivityType.match,
        ),
        ActivityEntity(
          description: 'Currículo atualizado',
          time: 'há 2 dias',
          type: ActivityType.profile,
        ),
        ActivityEntity(
          description: '3 novas vagas compatíveis',
          time: 'há 3 dias',
          type: ActivityType.job,
        ),
      ],
    );
  }

  @override
  Future<void> updateProfile(UserProfileModel profile) async {
    await Future.delayed(const Duration(milliseconds: 400));
    _saved = profile;
  }

  @override
  Future<bool> changePassword({
    required String userId,
    required String currentPassword,
    required String newPassword,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    if (currentPassword != _password) return false;
    _password = newPassword;
    return true;
  }

  @override
  Future<void> deleteAccount(String userId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    _saved = null;
  }

  /// Applies [change] to the profile and keeps it (until the app restarts).
  Future<void> _edit(String userId, UserProfileEntity Function(UserProfileEntity) change) async {
    final p = change(await getUserProfile(userId));
    _saved = UserProfileModel(
      id: p.id,
      name: p.name,
      email: p.email,
      role: p.role,
      location: p.location,
      profileCompletion: p.profileCompletion,
      applications: p.applications,
      matchScore: p.matchScore,
      profileViews: p.profileViews,
      skills: p.skills,
      recommendedJobs: p.recommendedJobs,
      activities: p.activities,
      cpf: p.cpf,
      gender: p.gender,
      phone: p.phone,
      birthDate: p.birthDate,
      educationLevel: p.educationLevel,
      experiences: p.experiences,
    );
  }

  @override
  Future<void> addSkill(String userId, String name, SkillLevel level) {
    final key = name.trim().toLowerCase();
    return _edit(userId, (p) {
      // Same name in any case is the same skill (like the database), so it keeps
      // the name it was first saved with.
      final existing = p.skills.where((s) => s.name.toLowerCase() == key);
      return p.copyWith(skills: [
        ...p.skills.where((s) => s.name.toLowerCase() != key),
        UserSkillEntity(name: existing.isEmpty ? name.trim() : existing.first.name, level: level),
      ]);
    });
  }

  @override
  Future<void> removeSkill(String userId, String name) {
    return _edit(userId, (p) => p.copyWith(skills: [
          for (final s in p.skills)
            if (s.name != name) s,
        ]));
  }

  @override
  Future<void> addExperience(String userId, ExperienceEntity experience) {
    final saved = ExperienceEntity(
      id: 'exp_${DateTime.now().microsecondsSinceEpoch}',
      jobTitle: experience.jobTitle,
      companyName: experience.companyName,
      description: experience.description,
      startDate: experience.startDate,
      endDate: experience.endDate,
    );
    return _edit(userId, (p) => p.copyWith(experiences: [...p.experiences, saved]));
  }

  @override
  Future<void> deleteExperience(String userId, String experienceId) {
    return _edit(userId, (p) => p.copyWith(experiences: [
          for (final e in p.experiences)
            if (e.id != experienceId) e,
        ]));
  }
}
