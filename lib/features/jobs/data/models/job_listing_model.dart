import '../../domain/entities/job_listing_entity.dart';

class JobListingModel extends JobListingEntity {
  const JobListingModel({
    required super.id,
    required super.title,
    required super.company,
    required super.location,
    required super.type,
    required super.salary,
    required super.description,
    super.matchPercent,
  });

  factory JobListingModel.fromJson(Map<String, dynamic> json) => JobListingModel(
        id: json['id'] as String,
        title: json['title'] as String,
        company: json['company'] as String,
        location: json['location'] as String,
        type: json['type'] as String,
        salary: json['salary'] as String,
        description: json['description'] as String,
        matchPercent: json['match_percent'] as int?,
      );
}
