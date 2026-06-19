import '../../domain/entities/user_profile_entity.dart';

class UserProfileModel extends UserProfileEntity {
  const UserProfileModel({
    required super.id,
    required super.nome,
    required super.email,
    required super.cargo,
    required super.localizacao,
    required super.perfilCompleto,
    required super.candidaturas,
    required super.matchScore,
    required super.visualizacoes,
    required super.habilidades,
    required super.vagasRecomendadas,
    required super.atividades,
  });
}
