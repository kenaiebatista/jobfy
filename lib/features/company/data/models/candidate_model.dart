import '../../domain/entities/company_entity.dart';

class CandidateModel extends CandidateEntity {
  const CandidateModel({
    required super.id,
    required super.name,
    required super.email,
    super.phone,
    super.appliedAt,
    super.status,
  });

  /// Reads the backend JSON and the MySQL row alike (same snake_case names).
  factory CandidateModel.fromJson(Map<String, dynamic> json) {
    final phone = json['phone']?.toString().trim();
    return CandidateModel(
      id: '${json['user_id']}',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: phone == null || phone.isEmpty ? null : phone,
      appliedAt: DateTime.tryParse('${json['applied_at'] ?? ''}'),
      status: json['status']?.toString() ?? 'under_review',
    );
  }
}
