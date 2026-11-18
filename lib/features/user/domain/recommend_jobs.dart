import 'package:jobfy/features/jobs/domain/entities/job_listing_entity.dart';
import 'entities/user_profile_entity.dart';

/// The jobs to suggest on the dashboard: the ones whose title or description
/// mention the most of the user's skills come first; with no match at all
/// (or no skills) it's simply the newest ones. [jobs] must come newest
/// first, which is also the tie-break.
List<JobMatchEntity> recommendJobs(
  List<JobListingEntity> jobs,
  List<UserSkillEntity> skills, {
  int limit = 3,
}) {
  int score(JobListingEntity job) {
    final text = '${job.title} ${job.description}'.toLowerCase();
    return skills.where((s) => text.contains(s.name.toLowerCase())).length;
  }

  final ranked = [
    for (final (i, job) in jobs.indexed) (job: job, score: score(job), position: i),
  ]..sort((a, b) {
      final byScore = b.score.compareTo(a.score);
      return byScore != 0 ? byScore : a.position.compareTo(b.position);
    });

  return [
    for (final r in ranked.take(limit))
      JobMatchEntity(
        id: r.job.id,
        title: r.job.title,
        company: r.job.company,
        location: r.job.location,
        type: r.job.type,
        salary: r.job.salary,
      ),
  ];
}
