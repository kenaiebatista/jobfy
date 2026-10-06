import 'package:jobfy/core/database/database_service.dart';
import 'package:jobfy/features/jobs/data/datasources/job_data_source.dart';
import 'package:jobfy/features/jobs/data/datasources/job_mysql_data_source.dart';
import '../../domain/entities/user_profile_entity.dart';
import '../models/user_profile_model.dart';
import 'user_data_source.dart';

/// Builds the signed-in user's dashboard profile straight from the Jobfy
/// MySQL database through [DatabaseService]. Stand-in until the Go backend
/// ([UserRemoteDataSource]) is deployed.
class UserMysqlDataSource implements UserDataSource {
  /// Where the recommended jobs come from (the open jobs in the database).
  final JobDataSource _jobs;

  UserMysqlDataSource([JobDataSource? jobs]) : _jobs = jobs ?? JobMysqlDataSource();

  @override
  Future<UserProfileModel> getUserProfile(String userId) async {
    final data = await DatabaseService.getUserProfile(int.parse(userId));
    if (data == null) throw StateError('User $userId not found');
    final user = data.user;

    final skills = [
      for (final s in data.skills)
        UserSkillEntity(
          name: s['name'] ?? '',
          level: SkillLevel.values.asNameMap()[s['level']] ?? SkillLevel.beginner,
        ),
    ];

    final experiences = [
      for (final e in data.experiences)
        ExperienceEntity(
          jobTitle: e['job_title'] ?? '',
          companyName: e['company_name'] ?? '',
          description: e['description'],
          startDate: DateTime.parse(e['start_date']!),
          endDate: DateTime.tryParse(e['end_date'] ?? ''),
        ),
    ];

    final jobs = await _jobs.searchJobs();

    final cpf = user['cpf'];
    final gender = Gender.values.asNameMap()[user['gender']];
    final phone = user['phone'];
    final birthDate = DateTime.tryParse(user['birth_date'] ?? '');
    final education = EducationLevel.fromDb(user['education_level']);

    // Profile completion: name and email are always there; each optional
    // piece of the profile the user filled in adds to the percentage.
    final optional = [
      cpf != null,
      gender != null,
      phone != null && phone.isNotEmpty,
      birthDate != null,
      education != null,
      skills.isNotEmpty,
      experiences.isNotEmpty,
    ];
    final filled = 2 + optional.where((f) => f).length;
    final completion = (filled * 100 / (2 + optional.length)).round();

    return UserProfileModel(
      id: userId,
      name: user['name'] ?? '',
      email: user['email'] ?? '',
      // Headline under the name: the current (or most recent) job title.
      role: experiences.isEmpty ? '' : experiences.first.jobTitle,
      // The `users` table has no address column.
      location: '',
      profileCompletion: completion,
      applications: data.applications,
      // No data for these yet; the dashboard doesn't show them.
      matchScore: 0,
      profileViews: 0,
      skills: skills,
      recommendedJobs: [
        for (final j in jobs.take(3))
          JobMatchEntity(
            title: j.title,
            company: j.company,
            location: j.location,
            type: j.type,
            salary: j.salary,
          ),
      ],
      activities: [
        for (final a in data.recentApplications)
          ActivityEntity(
            description: '${a['title']} · ${a['company_name']}',
            time: _formatDate(DateTime.tryParse(a['applied_at'] ?? '')),
            type: ActivityType.application,
          ),
      ],
      cpf: cpf,
      gender: gender,
      phone: phone,
      birthDate: birthDate,
      educationLevel: education,
      experiences: experiences,
    );
  }

  /// Saves what the settings screen edits (name, email, phone). The rest
  /// of the profile (skills, experiences) is only set at sign-up for now.
  @override
  Future<void> updateProfile(UserProfileModel profile) {
    final phone = profile.phone?.trim();
    return DatabaseService.updateUserAccount(
      userId: int.parse(profile.id),
      name: profile.name,
      email: profile.email,
      phone: phone == null || phone.isEmpty ? null : phone,
    );
  }

  @override
  Future<bool> changePassword({
    required String userId,
    required String currentPassword,
    required String newPassword,
  }) {
    return DatabaseService.changePassword(
      userId: int.parse(userId),
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
  }

  @override
  Future<void> deleteAccount(String userId) {
    return DatabaseService.deactivateAccount(int.parse(userId));
  }

  static String _formatDate(DateTime? d) {
    if (d == null) return '';
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.day)}/${two(d.month)}/${d.year}';
  }
}
