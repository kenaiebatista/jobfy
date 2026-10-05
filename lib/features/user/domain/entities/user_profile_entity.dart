class JobMatchEntity {
  final String title;
  final String company;
  final String location;
  final String type;
  /// Null when there is no match score for this job (jobs from MySQL).
  final int? matchPercent;
  final String salary;

  const JobMatchEntity({
    required this.title,
    required this.company,
    required this.location,
    required this.type,
    this.matchPercent,
    required this.salary,
  });
}

enum ActivityType { application, profileView, match, profile, job }

class ActivityEntity {
  final String description;
  final String time;
  final ActivityType type;

  const ActivityEntity({
    required this.description,
    required this.time,
    required this.type,
  });
}

/// Values match the `users.gender` ENUM in the database.
enum Gender { male, female, other }

/// Values match the `user_skills.level` ENUM in the database.
enum SkillLevel { beginner, intermediate, advanced }

/// `users.education_level`. The database uses snake_case, kept in [dbValue].
enum EducationLevel {
  elementaryIncomplete('elementary_incomplete'),
  elementaryComplete('elementary_complete'),
  highSchoolIncomplete('high_school_incomplete'),
  highSchoolComplete('high_school_complete'),
  technical('technical'),
  bachelorIncomplete('bachelor_incomplete'),
  bachelorComplete('bachelor_complete'),
  postgraduate('postgraduate');

  const EducationLevel(this.dbValue);
  final String dbValue;

  static EducationLevel? fromDb(String? value) {
    for (final level in values) {
      if (level.dbValue == value) return level;
    }
    return null;
  }
}

/// A row of `user_skills` joined with the skill's name.
class UserSkillEntity {
  final String name;
  final SkillLevel level;

  const UserSkillEntity({required this.name, this.level = SkillLevel.beginner});
}

/// A row of `experiences`. [endDate] null means it's the current job.
class ExperienceEntity {
  final String jobTitle;
  final String companyName;
  final String? description;
  final DateTime startDate;
  final DateTime? endDate;

  const ExperienceEntity({
    required this.jobTitle,
    required this.companyName,
    this.description,
    required this.startDate,
    this.endDate,
  });
}

class UserProfileEntity {
  final String id;
  final String name;
  final String email;
  final String role;
  final String location;
  final int profileCompletion;
  final int applications;
  final int matchScore;
  final int profileViews;
  final List<UserSkillEntity> skills;
  final List<JobMatchEntity> recommendedJobs;
  final List<ActivityEntity> activities;

  // Personal data from the `users` table (all optional at sign-up).
  final String? cpf;
  final Gender? gender;
  final String? phone;
  final DateTime? birthDate;
  final EducationLevel? educationLevel;
  final List<ExperienceEntity> experiences;

  const UserProfileEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.location,
    required this.profileCompletion,
    required this.applications,
    required this.matchScore,
    required this.profileViews,
    required this.skills,
    required this.recommendedJobs,
    required this.activities,
    this.cpf,
    this.gender,
    this.phone,
    this.birthDate,
    this.educationLevel,
    this.experiences = const [],
  });
}
