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
    super.workMode,
    super.status,
    super.candidateCount,
    super.area,
    super.salaryMin,
    super.salaryMax,
    super.workload,
    super.requirements,
    super.benefits,
  });

  /// MySQL sends DECIMAL(10,2) as "7000.00"; the form works in whole reais.
  static int? _money(Object? value) =>
      value == null ? null : double.tryParse('$value')?.round();

  static String? _text(Object? value) {
    final text = value?.toString().trim();
    return text == null || text.isEmpty ? null : text;
  }

  /// Reads the backend JSON and the MySQL row alike (MySQL sends every
  /// value as text and leaves empty columns null).
  factory JobModel.fromJson(Map<String, dynamic> json) {
    return JobModel(
      id: '${json['id']}',
      companyId: '${json['company_id']}',
      title: _text(json['title']) ?? '',
      description: _text(json['description']) ?? '',
      location: _text(json['location']) ?? '',
      contractType: _text(json['contract_type']) ?? '',
      salary: _text(json['salary']) ?? '',
      workMode: _text(json['work_mode']),
      status: _text(json['status']),
      candidateCount: int.tryParse('${json['candidates'] ?? 0}') ?? 0,
      area: _text(json['area']),
      salaryMin: _money(json['salary_min']),
      salaryMax: _money(json['salary_max']),
      workload: _text(json['workload']),
      requirements: _text(json['requirements']),
      benefits: _text(json['benefits']),
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
        'work_mode': workMode,
        'status': status,
        'area': area,
        'salary_min': salaryMin,
        'salary_max': salaryMax,
        'workload': workload,
        'requirements': requirements,
        'benefits': benefits,
      };
}
