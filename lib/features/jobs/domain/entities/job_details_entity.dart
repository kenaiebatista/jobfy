/// Everything the job details screen shows: the `jobs` row, the company
/// that published it and whether the signed-in user already applied.
class JobDetailsEntity {
  final String id;
  final String title;
  final String? area;
  final String location;

  /// `jobs.work_mode` (Presencial/Híbrido/Remoto).
  final String workMode;

  /// `jobs.contract_type` value (clt, pj, internship...).
  final String contractType;

  /// Carga horária, e.g. "40h semanais".
  final String? workload;
  final String salary;
  final String description;
  final String? requirements;
  final String? benefits;
  final DateTime? publishedAt;

  /// `jobs.status`: open, paused or closed. Only open jobs take applications.
  final String status;

  final String companyName;
  final String? companyTradeName;
  final String? companyBusinessArea;
  final String? companyCity;
  final String? companyState;
  final String? companyPhone;
  final String? companyEmail;
  final String? companyDescription;

  /// `applications.status` of the signed-in user's application to this job
  /// (under_review, approved, rejected or withdrawn), or null if they
  /// haven't applied.
  final String? applicationStatus;

  const JobDetailsEntity({
    required this.id,
    required this.title,
    this.area,
    required this.location,
    required this.workMode,
    required this.contractType,
    this.workload,
    required this.salary,
    required this.description,
    this.requirements,
    this.benefits,
    this.publishedAt,
    required this.status,
    required this.companyName,
    this.companyTradeName,
    this.companyBusinessArea,
    this.companyCity,
    this.companyState,
    this.companyPhone,
    this.companyEmail,
    this.companyDescription,
    this.applicationStatus,
  });

  /// An active application: after withdrawing, the user can apply again.
  bool get hasApplied => applicationStatus != null && applicationStatus != 'withdrawn';

  /// Pending or approved applications can be given up; an answered
  /// (rejected) or withdrawn one can't.
  bool get canWithdraw => applicationStatus == 'under_review' || applicationStatus == 'approved';
  bool get isOpen => status == 'open';

  /// Name shown in the app: the trade name when there is one.
  String get companyDisplayName =>
      (companyTradeName ?? '').trim().isNotEmpty ? companyTradeName! : companyName;

  JobDetailsEntity copyWith({String? applicationStatus}) => JobDetailsEntity(
        id: id,
        title: title,
        area: area,
        location: location,
        workMode: workMode,
        contractType: contractType,
        workload: workload,
        salary: salary,
        description: description,
        requirements: requirements,
        benefits: benefits,
        publishedAt: publishedAt,
        status: status,
        companyName: companyName,
        companyTradeName: companyTradeName,
        companyBusinessArea: companyBusinessArea,
        companyCity: companyCity,
        companyState: companyState,
        companyPhone: companyPhone,
        companyEmail: companyEmail,
        companyDescription: companyDescription,
        applicationStatus: applicationStatus ?? this.applicationStatus,
      );
}
