import 'package:aplicativo_jobfy/features/company/domain/entities/empresa_entity.dart';

/// Versão "de dados" da EmpresaEntity. No futuro, aqui entrariam
/// fromJson/toJson para consumir uma API real.
class EmpresaModel extends EmpresaEntity {
  const EmpresaModel({
    required super.idEmpresa,
    required super.nomeEmpresa,
    required super.cnpj,
    required super.email,
    required super.telefone,
  });

  factory EmpresaModel.fromJson(Map<String, dynamic> json) {
    return EmpresaModel(
      idEmpresa: json['id_empresa'] as int,
      nomeEmpresa: json['nome_empresa'] as String,
      cnpj: json['cnpj'] as String,
      email: json['email'] as String,
      telefone: json['telefone'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_empresa': idEmpresa,
      'nome_empresa': nomeEmpresa,
      'cnpj': cnpj,
      'email': email,
      'telefone': telefone,
    };
  }
}
