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
    super.cpf,
    super.gender,
    super.phone,
    super.birthDate,
    super.educationLevel,
    super.experiences,
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
      skills: (json['skills'] as List)
          .map((s) => _skillFromJson(s as Map<String, dynamic>))
          .toList(),
      recommendedJobs: (json['recommended_jobs'] as List)
          .map((j) => _jobMatchFromJson(j as Map<String, dynamic>))
          .toList(),
      activities: (json['activities'] as List)
          .map((a) => _activityFromJson(a as Map<String, dynamic>))
          .toList(),
      cpf: json['cpf'] as String?,
      gender: _genderFromJson(json['gender'] as String?),
      phone: json['phone'] as String?,
      birthDate: DateTime.tryParse(json['birth_date'] as String? ?? ''),
      educationLevel: EducationLevel.fromDb(json['education_level'] as String?),
      experiences: ((json['experiences'] as List?) ?? const [])
          .map((e) => _experienceFromJson(e as Map<String, dynamic>))
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
        'skills': [
          for (final s in skills) {'name': s.name, 'level': s.level.name},
        ],
        'cpf': cpf,
        'gender': gender?.name,
        'phone': phone,
        'birth_date': birthDate?.toIso8601String().substring(0, 10),
        'education_level': educationLevel?.dbValue,
      };
}

UserSkillEntity _skillFromJson(Map<String, dynamic> json) => UserSkillEntity(
      name: json['name'] as String,
      level: SkillLevel.values.asNameMap()[json['level']] ?? SkillLevel.beginner,
    );

Gender? _genderFromJson(String? value) => Gender.values.asNameMap()[value];

ExperienceEntity _experienceFromJson(Map<String, dynamic> json) =>
    ExperienceEntity(
      jobTitle: json['job_title'] as String,
      companyName: json['company_name'] as String,
      description: json['description'] as String?,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.tryParse(json['end_date'] as String? ?? ''),
    );

JobMatchEntity _jobMatchFromJson(Map<String, dynamic> json) => JobMatchEntity(
      title: json['title'] as String,
      company: json['company'] as String,
      location: json['location'] as String,
      type: json['type'] as String,
      matchPercent: json['match_percent'] as int?,
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
