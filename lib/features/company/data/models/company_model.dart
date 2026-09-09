import '../../domain/entities/company_entity.dart';

class CompanyModel extends CompanyEntity {
  const CompanyModel({
    required super.companyId,
    required super.companyName,
    required super.cnpj,
    required super.email,
    required super.phone,
  });

  factory CompanyModel.fromJson(Map<String, dynamic> json) {
    return CompanyModel(
      companyId: json['company_id'] as int,
      companyName: json['company_name'] as String,
      cnpj: json['cnpj'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'company_id': companyId,
      'company_name': companyName,
      'cnpj': cnpj,
      'email': email,
      'phone': phone,
    };
  }
}
