import '../../domain/entities/user_profile_entity.dart';
import '../../domain/repositories/user_repository.dart';
import '../models/user_profile_model.dart';

// Mock implementation — substitua por Firebase/API real
class UserRepositoryImpl implements UserRepository {
  @override
  Future<UserProfileEntity> getUserProfile(String userId) async {
    await Future.delayed(const Duration(milliseconds: 600));
    return const UserProfileModel(
      id: 'usr_001',
      nome: 'Caue Bueno',
      email: 'caue@email.com',
      cargo: 'Desenvolvedor Flutter',
      localizacao: 'São Paulo, SP',
      perfilCompleto: 75,
      candidaturas: 12,
      matchScore: 89,
      visualizacoes: 234,
      habilidades: ['Flutter', 'Dart', 'Firebase', 'UI/UX', 'REST APIs'],
      vagasRecomendadas: [
        JobMatchEntity(
          titulo: 'Flutter Developer Senior',
          empresa: 'Nubank',
          local: 'São Paulo, SP',
          tipo: 'Remoto',
          matchPercent: 97,
          salario: 'R\$ 12.000 – 18.000',
        ),
        JobMatchEntity(
          titulo: 'Mobile Engineer',
          empresa: 'iFood',
          local: 'Campinas, SP',
          tipo: 'Híbrido',
          matchPercent: 91,
          salario: 'R\$ 10.000 – 15.000',
        ),
        JobMatchEntity(
          titulo: 'Dart/Flutter Developer',
          empresa: 'PicPay',
          local: 'Remoto',
          tipo: 'Remoto',
          matchPercent: 85,
          salario: 'R\$ 9.000 – 14.000',
        ),
      ],
      atividades: [
        ActivityEntity(
          descricao: 'Candidatura enviada para Nubank',
          tempo: 'há 2 horas',
          tipo: 'candidatura',
        ),
        ActivityEntity(
          descricao: 'Perfil visualizado por iFood',
          tempo: 'há 5 horas',
          tipo: 'visualizacao',
        ),
        ActivityEntity(
          descricao: 'Match de 91% com iFood',
          tempo: 'ontem',
          tipo: 'match',
        ),
        ActivityEntity(
          descricao: 'Currículo atualizado',
          tempo: 'há 2 dias',
          tipo: 'perfil',
        ),
        ActivityEntity(
          descricao: '3 novas vagas compatíveis',
          tempo: 'há 3 dias',
          tipo: 'vaga',
        ),
      ],
    );
  }

  @override
  Future<void> updateProfile(UserProfileEntity profile) async {
    await Future.delayed(const Duration(milliseconds: 400));
  }
}
