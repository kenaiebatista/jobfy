import '../../domain/entities/user_profile_entity.dart';

class UserProfileModel extends UserProfileEntity {
  const UserProfileModel({
    required super.id,
    required super.name,
    required super.email,
    required super.role,
    required super.location,
    required super.profileCompletion,
    required super.applications,
    required super.matchScore,
    required super.profileViews,
    required super.skills,
    required super.recommendedJobs,
    required super.activities,
  });
}
