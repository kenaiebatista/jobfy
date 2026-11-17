import '../../domain/entities/job_details_entity.dart';

class JobDetailsModel extends JobDetailsEntity {
  const JobDetailsModel({
    required super.id,
    required super.title,
    super.area,
    required super.location,
    required super.workMode,
    required super.contractType,
    super.workload,
    required super.salary,
    required super.description,
    super.requirements,
    super.benefits,
    super.publishedAt,
    required super.status,
    required super.companyName,
    super.companyTradeName,
    super.companyBusinessArea,
    super.companyCity,
    super.companyState,
    super.companyPhone,
    super.companyEmail,
    super.companyDescription,
    super.applicationStatus,
  });

  /// Reads the backend JSON and the MySQL row alike (same snake_case
  /// names; MySQL sends every value as text).
  factory JobDetailsModel.fromJson(Map<String, dynamic> json) {
    String? opt(String key) {
      final value = json[key]?.toString().trim();
      return value == null || value.isEmpty ? null : value;
    }

    return JobDetailsModel(
      id: '${json['id']}',
      title: opt('title') ?? '',
      area: opt('area'),
      location: opt('location') ?? '',
      workMode: opt('work_mode') ?? '',
      contractType: opt('contract_type') ?? '',
      workload: opt('workload'),
      salary: opt('salary') ?? '',
      description: opt('description') ?? '',
      requirements: opt('requirements'),
      benefits: opt('benefits'),
      publishedAt: DateTime.tryParse(opt('published_at') ?? ''),
      status: opt('status') ?? 'open',
      companyName: opt('company_name') ?? '',
      companyTradeName: opt('trade_name'),
      companyBusinessArea: opt('business_area'),
      companyCity: opt('city'),
      companyState: opt('state'),
      companyPhone: opt('company_phone'),
      companyEmail: opt('company_email'),
      companyDescription: opt('company_description'),
      applicationStatus: opt('application_status'),
    );
  }
}
