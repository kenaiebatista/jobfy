class JobMatchEntity {
  final String title;
  final String company;
  final String location;
  final String type;
  final int matchPercent;
  final String salary;

  const JobMatchEntity({
    required this.title,
    required this.company,
    required this.location,
    required this.type,
    required this.matchPercent,
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
  final List<String> skills;
  final List<JobMatchEntity> recommendedJobs;
  final List<ActivityEntity> activities;

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
  });
}
