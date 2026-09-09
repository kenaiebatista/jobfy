/// A job posting as browsed by a job seeker (distinct from
/// features/company's JobEntity, which is the company's own view of a
/// posting it manages).
class JobListingEntity {
  final String id;
  final String title;
  final String company;
  final String location;
  final String type;
  final String salary;
  final String description;

  /// Compatibility with the signed-in user's profile, 0-100. Null when
  /// browsing without a profile to match against.
  final int? matchPercent;

  const JobListingEntity({
    required this.id,
    required this.title,
    required this.company,
    required this.location,
    required this.type,
    required this.salary,
    required this.description,
    this.matchPercent,
  });
}
