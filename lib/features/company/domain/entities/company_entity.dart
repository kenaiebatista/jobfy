/// A job posting published by a company.
class JobEntity {
  final String id;
  final String companyId;
  final String title;
  final String description;
  final String location;
  final String contractType;
  final String salary;

  const JobEntity({
    required this.id,
    required this.companyId,
    required this.title,
    required this.description,
    required this.location,
    required this.contractType,
    required this.salary,
  });
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

class CompanyEntity {
  final String companyId;
  final String companyName;
  final String cnpj;
  final String email;
  final String phone;

  const CompanyEntity({
    required this.companyId,
    required this.companyName,
    required this.cnpj,
    required this.email,
    required this.phone,
  });
}
