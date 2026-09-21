import '../../domain/entities/job_entity.dart';

class JobModel extends JobEntity {
  const JobModel({
    required super.id,
    required super.titulo,
    required super.empresa,
    required super.local,
    required super.tipo,
    required super.nivel,
    required super.salario,
    required super.descricao,
    required super.requisitos,
    required super.matchPercent,
    required super.publicadaEm,
  });

  // --- Backend (API + MySQL) -------------------------------------------------
  // Descomentar junto com o JobRepositoryImpl quando a API estiver pronta.
  // Chaves em snake_case, iguais às colunas do MySQL (como no EmpresaModel).
  //
  // factory JobModel.fromJson(Map<String, dynamic> json) {
  //   return JobModel(
  //     id: json['id'].toString(), // INT no banco, String na entidade
  //     titulo: json['titulo'] as String,
  //     empresa: json['empresa'] as String, // JOIN com a tabela de empresas
  //     local: json['local'] as String,
  //     tipo: json['tipo'] as String,
  //     nivel: json['nivel'] as String,
  //     salario: json['salario'] as String,
  //     descricao: json['descricao'] as String,
  //     requisitos: List<String>.from(json['requisitos'] ?? const []),
  //     // O match é calculado pela API para o usuário logado.
  //     matchPercent: (json['match_percent'] ?? 0) as int,
  //     // DATETIME serializado em ISO 8601 pela API.
  //     publicadaEm: DateTime.parse(json['publicada_em'] as String),
  //   );
  // }
}
