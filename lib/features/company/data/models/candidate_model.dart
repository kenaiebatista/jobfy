import '../../domain/entities/company_entity.dart';

class CandidateModel extends CandidateEntity {
  const CandidateModel({
    required super.id,
    required super.name,
    required super.desiredRole,
    required super.matchPercent,
    super.rating,
  });

  factory CandidateModel.fromJson(Map<String, dynamic> json) {
    return CandidateModel(
      id: json['id'] as String,
      name: json['name'] as String,
      desiredRole: json['desired_role'] as String,
      matchPercent: json['match_percent'] as int,
      rating: (json['rating'] as num?)?.toDouble(),
    );
  }
}
