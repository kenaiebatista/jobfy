/// Vaga exibida para o candidato (lado mobile).
/// Não confundir com [VagaEntity] da feature company, que é a vaga do ponto
/// de vista de quem publica.
class JobEntity {
  final String id;
  final String titulo;
  final String empresa;
  final String local;
  final String tipo; // Remoto | Híbrido | Presencial
  final String nivel; // Júnior | Pleno | Sênior
  final String salario;
  final String descricao;
  final List<String> requisitos;
  final int matchPercent;
  final DateTime publicadaEm;

  const JobEntity({
    required this.id,
    required this.titulo,
    required this.empresa,
    required this.local,
    required this.tipo,
    required this.nivel,
    required this.salario,
    required this.descricao,
    required this.requisitos,
    required this.matchPercent,
    required this.publicadaEm,
  });
}
