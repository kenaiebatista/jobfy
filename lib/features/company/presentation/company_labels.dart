import 'package:jobfy/features/company/domain/entities/company_entity.dart';
import 'package:jobfy/l10n/app_localizations.dart';

/// Localized text for the job values stored in the database, shared by the
/// company dashboard and (later) the job insertion form.
extension CompanyLabels on AppLocalizations {
  String contractType(ContractType type) => switch (type) {
        ContractType.clt => contractClt,
        ContractType.pj => contractPj,
        ContractType.internship => contractInternship,
        ContractType.apprentice => contractApprentice,
        ContractType.temporary => contractTemporary,
        ContractType.freelance => contractFreelance,
      };

  /// [value] is the raw `jobs.contract_type`; unknown values pass through.
  String contractTypeFromDb(String value) {
    final type = ContractType.fromDb(value);
    return type == null ? value : contractType(type);
  }

  /// [value] is the raw `jobs.status`: open, paused or closed.
  String jobStatus(String? value) => switch (value) {
        'open' => jobStatusOpen,
        'paused' => jobStatusPaused,
        'closed' => jobStatusClosed,
        _ => value ?? '',
      };
}

/// "12345678000190" -> "12.345.678/0001-90".
String formatCnpj(String cnpj) {
  final d = cnpj.replaceAll(RegExp(r'\D'), '');
  if (d.length != 14) return cnpj;
  return '${d.substring(0, 2)}.${d.substring(2, 5)}.${d.substring(5, 8)}/${d.substring(8, 12)}-${d.substring(12)}';
}

/// "89110000" -> "89110-000".
String formatZipCode(String zip) {
  final d = zip.replaceAll(RegExp(r'\D'), '');
  return d.length == 8 ? '${d.substring(0, 5)}-${d.substring(5)}' : zip;
}
