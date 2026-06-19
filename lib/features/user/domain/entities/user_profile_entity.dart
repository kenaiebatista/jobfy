class JobMatchEntity {
  final String titulo;
  final String empresa;
  final String local;
  final String tipo;
  final int matchPercent;
  final String salario;

  const JobMatchEntity({
    required this.titulo,
    required this.empresa,
    required this.local,
    required this.tipo,
    required this.matchPercent,
    required this.salario,
  });
}

class ActivityEntity {
  final String descricao;
  final String tempo;
  final String tipo;

  const ActivityEntity({
    required this.descricao,
    required this.tempo,
    required this.tipo,
  });
}

class UserProfileEntity {
  final String id;
  final String nome;
  final String email;
  final String cargo;
  final String localizacao;
  final int perfilCompleto;
  final int candidaturas;
  final int matchScore;
  final int visualizacoes;
  final List<String> habilidades;
  final List<JobMatchEntity> vagasRecomendadas;
  final List<ActivityEntity> atividades;

  const UserProfileEntity({
    required this.id,
    required this.nome,
    required this.email,
    required this.cargo,
    required this.localizacao,
    required this.perfilCompleto,
    required this.candidaturas,
    required this.matchScore,
    required this.visualizacoes,
    required this.habilidades,
    required this.vagasRecomendadas,
    required this.atividades,
  });
}
