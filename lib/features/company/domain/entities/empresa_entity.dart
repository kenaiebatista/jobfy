/// Entidade que representa uma vaga publicada pela empresa.
/// (necessária para o método publicarVaga() do diagrama)
class VagaEntity {
  final String id;
  final String idEmpresa;
  final String titulo;
  final String descricao;
  final String localizacao;
  final String tipoContrato;
  final String salario;

  const VagaEntity({
    required this.id,
    required this.idEmpresa,
    required this.titulo,
    required this.descricao,
    required this.localizacao,
    required this.tipoContrato,
    required this.salario,
  });
}

/// Entidade que representa um candidato retornado pelo filtro.
/// (necessária para o método filtrarCandidatos() do diagrama)
class CandidatoEntity {
  final String id;
  final String nome;
  final String cargoDesejado;
  final int matchPercent;
  final double? avaliacao;

  const CandidatoEntity({
    required this.id,
    required this.nome,
    required this.cargoDesejado,
    required this.matchPercent,
    this.avaliacao,
  });
}

/// Entidade principal, espelhando 1:1 o diagrama UML fornecido:
/// - id_empresa : int      -> idEmpresa
/// - nome_empresa : String -> nomeEmpresa
/// - cnpj : String         -> cnpj
/// - email : String        -> email
/// - telefone : String     -> telefone
class EmpresaEntity {
  final int idEmpresa;
  final String nomeEmpresa;
  final String cnpj;
  final String email;
  final String telefone;

  const EmpresaEntity({
    required this.idEmpresa,
    required this.nomeEmpresa,
    required this.cnpj,
    required this.email,
    required this.telefone,
  });
}
