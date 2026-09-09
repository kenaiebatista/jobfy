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

  /// Parses the Go backend's `GET /users/{id}/profile` response.
  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      location: json['location'] as String,
      profileCompletion: json['profile_completion'] as int,
      applications: json['applications'] as int,
      matchScore: json['match_score'] as int,
      profileViews: json['profile_views'] as int,
      skills: (json['skills'] as List).cast<String>(),
      recommendedJobs: (json['recommended_jobs'] as List)
          .map((j) => _jobMatchFromJson(j as Map<String, dynamic>))
          .toList(),
      activities: (json['activities'] as List)
          .map((a) => _activityFromJson(a as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'role': role,
        'location': location,
        'profile_completion': profileCompletion,
        'applications': applications,
        'match_score': matchScore,
        'profile_views': profileViews,
        'skills': skills,
      };
}

JobMatchEntity _jobMatchFromJson(Map<String, dynamic> json) => JobMatchEntity(
      title: json['title'] as String,
      company: json['company'] as String,
      location: json['location'] as String,
      type: json['type'] as String,
      matchPercent: json['match_percent'] as int,
      salary: json['salary'] as String,
    );

const _activityTypeByJson = {
  'application': ActivityType.application,
  'profile_view': ActivityType.profileView,
  'match': ActivityType.match,
  'profile': ActivityType.profile,
  'job': ActivityType.job,
};

ActivityEntity _activityFromJson(Map<String, dynamic> json) => ActivityEntity(
      description: json['description'] as String,
      time: json['time'] as String,
      type: _activityTypeByJson[json['type']] ?? ActivityType.job,
    );
