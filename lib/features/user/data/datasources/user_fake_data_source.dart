import '../../domain/entities/user_profile_entity.dart';
import 'package:jobfy/features/jobs/data/datasources/job_data_source.dart';
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

  @override
  Future<UserProfileModel> getUserProfile(String userId) async {
    await Future.delayed(const Duration(milliseconds: 600));
    // Recommended jobs are the first 3 open jobs from the MySQL database.
    // If the database can't be reached the dashboard still loads, just
    // without recommendations.
    List<JobMatchEntity> recommendedJobs = [];
    try {
      final jobs = await _jobs.searchJobs();
      recommendedJobs = jobs
          .take(3)
          .map(
            (j) => JobMatchEntity(
              title: j.title,
              company: j.company,
              location: j.location,
              type: j.type,
              salary: j.salary,
            ),
          )
          .toList();
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
      skills: const ['Flutter', 'Dart', 'Firebase', 'UI/UX', 'REST APIs'],
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
  }
}
