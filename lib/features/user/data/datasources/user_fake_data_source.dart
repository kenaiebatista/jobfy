import '../../domain/entities/user_profile_entity.dart';
import 'user_data_source.dart';
import '../models/user_profile_model.dart';

/// In-memory stand-in for [UserRemoteDataSource], used until the Go backend
/// is deployed.
class UserFakeDataSource implements UserDataSource {
  @override
  Future<UserProfileModel> getUserProfile(String userId) async {
    await Future.delayed(const Duration(milliseconds: 600));
    return const UserProfileModel(
      id: 'usr_001',
      name: 'Victor Henrique',
      email: 'victor.henrique@email.com',
      role: 'Flutter Developer',
      location: 'Gaspar, SC',
      profileCompletion: 75,
      applications: 12,
      matchScore: 89,
      profileViews: 234,
      skills: ['Flutter', 'Dart', 'Firebase', 'UI/UX', 'REST APIs'],
      recommendedJobs: [
        JobMatchEntity(
          title: 'Flutter Developer Senior',
          company: 'Nubank',
          location: 'São Paulo, SP',
          type: 'Remoto',
          matchPercent: 97,
          salary: 'R\$ 12.000 – 18.000',
        ),
        JobMatchEntity(
          title: 'Mobile Engineer',
          company: 'iFood',
          location: 'Campinas, SP',
          type: 'Híbrido',
          matchPercent: 91,
          salary: 'R\$ 10.000 – 15.000',
        ),
        JobMatchEntity(
          title: 'Dart/Flutter Developer',
          company: 'PicPay',
          location: 'Remoto',
          type: 'Remoto',
          matchPercent: 85,
          salary: 'R\$ 9.000 – 14.000',
        ),
      ],
      activities: [
        ActivityEntity(
          description: 'Candidatura enviada para Nubank',
          time: 'há 2 horas',
          type: ActivityType.application,
        ),
        ActivityEntity(
          description: 'Perfil visualizado por iFood',
          time: 'há 5 horas',
          type: ActivityType.profileView,
        ),
        ActivityEntity(
          description: 'Match de 91% com iFood',
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
