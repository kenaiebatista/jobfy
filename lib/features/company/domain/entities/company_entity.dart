/// A job posting published by a company.
class JobEntity {
  final String id;
  final String companyId;
  final String title;
  final String description;
  final String location;

  /// `jobs.contract_type` value: clt, pj, internship, apprentice,
  /// temporary or freelance (see [ContractType]).
  final String contractType;
  final String salary;

  /// `jobs.work_mode` (Presencial/Híbrido/Remoto) and `jobs.status`
  /// (open/paused/closed).
  final String? workMode;
  final String? status;

  const JobEntity({
    required this.id,
    required this.companyId,
    required this.title,
    required this.description,
    required this.location,
    required this.contractType,
    required this.salary,
    this.workMode,
    this.status,
  });
}

/// What the company fills in to publish a job (the `jobs` columns; the
/// publication date and status come from the database defaults).
class NewJobEntity {
  final String companyId;
  final String title;
  final String? area;
  final String location;
  final WorkMode workMode;
  final String description;
  final ContractType contractType;
  final int salaryMin;
  final int salaryMax;

  const NewJobEntity({
    required this.companyId,
    required this.title,
    this.area,
    required this.location,
    required this.workMode,
    required this.description,
    required this.contractType,
    required this.salaryMin,
    required this.salaryMax,
  });
}

/// Values of `jobs.work_mode`, kept in [dbValue].
enum WorkMode {
  onSite('Presencial'),
  hybrid('Híbrido'),
  remote('Remoto');

  const WorkMode(this.dbValue);
  final String dbValue;
}

/// Values of `jobs.contract_type`.
enum ContractType {
  clt,
  pj,
  internship,
  apprentice,
  temporary,
  freelance;

  static ContractType? fromDb(String? value) => values.asNameMap()[value];
}

/// A candidate returned by the candidate filter.
class CandidateEntity {
  final String id;
  final String name;
  final String desiredRole;
  final int matchPercent;
  final double? rating;

  const CandidateEntity({
    required this.id,
    required this.name,
    required this.desiredRole,
    required this.matchPercent,
    this.rating,
  });
}

/// A row of `companies` plus the account email. [companyName] is the
/// legal name (razão social); the other optional fields are filled at
/// sign-up, usually from the CNPJ lookup.
class CompanyEntity {
  final String companyId;
  final String companyName;
  final String cnpj;
  final String email;
  final String phone;
  final String? tradeName;
  final String? businessArea;
  final String? zipCode;
  final String? address;
  final String? city;
  final String? state;
  final String? description;

  const CompanyEntity({
    required this.companyId,
    required this.companyName,
    required this.cnpj,
    required this.email,
    required this.phone,
    this.tradeName,
    this.businessArea,
    this.zipCode,
    this.address,
    this.city,
    this.state,
    this.description,
  });

  /// Name shown in the app: the trade name when there is one.
  String get displayName =>
      (tradeName != null && tradeName!.trim().isNotEmpty) ? tradeName! : companyName;
}

/// What the CNPJ lookup (BrasilAPI / Receita Federal) returns, used to fill
/// the company sign-up form.
class CnpjDataEntity {
  final String cnpj;
  final String legalName;
  final String? tradeName;
  final String? phone;
  final String? businessArea;
  final String? zipCode;
  final String? address;
  final String? city;
  final String? state;

  /// Registration status at Receita Federal, e.g. "ATIVA" or "BAIXADA".
  final String? status;

  const CnpjDataEntity({
    required this.cnpj,
    required this.legalName,
    this.tradeName,
    this.phone,
    this.businessArea,
    this.zipCode,
    this.address,
    this.city,
    this.state,
    this.status,
  });

  bool get isActive => status == null || status!.toUpperCase() == 'ATIVA';
}
