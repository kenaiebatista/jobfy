import '../../domain/entities/company_entity.dart';

class JobModel extends JobEntity {
  const JobModel({
    required super.id,
    required super.companyId,
    required super.title,
    required super.description,
    required super.location,
    required super.contractType,
    required super.salary,
  });

  factory JobModel.fromJson(Map<String, dynamic> json) {
    return JobModel(
      id: json['id'] as String,
      companyId: json['company_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      location: json['location'] as String,
      contractType: json['contract_type'] as String,
      salary: json['salary'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'company_id': companyId,
        'title': title,
        'description': description,
        'location': location,
        'contract_type': contractType,
        'salary': salary,
      };
}
