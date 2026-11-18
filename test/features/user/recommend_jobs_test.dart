import 'package:flutter_test/flutter_test.dart';
import 'package:jobfy/features/jobs/domain/entities/job_listing_entity.dart';
import 'package:jobfy/features/user/domain/entities/user_profile_entity.dart';
import 'package:jobfy/features/user/domain/recommend_jobs.dart';

JobListingEntity _job(String id, String title, String description) => JobListingEntity(
      id: id,
      title: title,
      company: 'Empresa $id',
      location: 'Gaspar, SC',
      type: 'Remoto',
      salary: 'R\$ 1.000 – 2.000',
      description: description,
    );

void main() {
  // Newest first, like the job list.
  final jobs = [
    _job('1', 'Designer UX/UI', 'Figma e protótipos.'),
    _job('2', 'Analista de Dados', 'SQL e dashboards.'),
    _job('3', 'Estágio em Flutter', 'Apps com Flutter.'),
    _job('4', 'Desenvolvedor Flutter', 'Flutter e Dart, APIs REST.'),
    _job('5', 'Suporte de TI', 'Atendimento.'),
  ];
  const skills = [
    UserSkillEntity(name: 'Flutter'),
    UserSkillEntity(name: 'dart'),
  ];

  test('the jobs that mention the most skills come first', () {
    final result = recommendJobs(jobs, skills);

    expect(result.map((j) => j.id), ['4', '3', '1']); // 2 skills, 1 skill, then the newest
    expect(result.first.title, 'Desenvolvedor Flutter');
    expect(result.first.company, 'Empresa 4');
  });

  test('without skills it is just the newest jobs', () {
    expect(recommendJobs(jobs, []).map((j) => j.id), ['1', '2', '3']);
  });

  test('without any match it is also the newest jobs', () {
    final result = recommendJobs(jobs, const [UserSkillEntity(name: 'Cobol')]);
    expect(result.map((j) => j.id), ['1', '2', '3']);
  });

  test('respects the limit and an empty list', () {
    expect(recommendJobs(jobs, skills, limit: 1).map((j) => j.id), ['4']);
    expect(recommendJobs([], skills), isEmpty);
  });
}
