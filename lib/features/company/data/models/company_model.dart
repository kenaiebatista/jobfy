import '../../domain/entities/company_entity.dart';

class CompanyModel extends CompanyEntity {
  const CompanyModel({
    required super.companyId,
    required super.companyName,
    required super.cnpj,
    required super.email,
    required super.phone,
    super.tradeName,
    super.businessArea,
    super.zipCode,
    super.address,
    super.city,
    super.state,
    super.description,
  });

  factory CompanyModel.fromJson(Map<String, dynamic> json) {
    return CompanyModel(
      companyId: json['company_id'] as String,
      companyName: json['company_name'] as String,
      cnpj: json['cnpj'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String? ?? '',
      tradeName: json['trade_name'] as String?,
      businessArea: json['business_area'] as String?,
      zipCode: json['zip_code'] as String?,
      address: json['address'] as String?,
      city: json['city'] as String?,
      state: json['state'] as String?,
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'company_id': companyId,
      'company_name': companyName,
      'cnpj': cnpj,
      'email': email,
      'phone': phone,
      'trade_name': tradeName,
      'business_area': businessArea,
      'zip_code': zipCode,
      'address': address,
      'city': city,
      'state': state,
      'description': description,
    };
  }
}
