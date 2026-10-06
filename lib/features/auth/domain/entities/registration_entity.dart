import 'package:jobfy/features/user/domain/entities/user_profile_entity.dart';

/// Everything the sign-up form collects: the login (email/password), every
/// column of the `users` table, plus the user's skills and experiences.
class RegistrationEntity {
  final String name;
  final String email;
  final String password;

  /// Digits only (11).
  final String cpf;
  final Gender gender;
  final String? phone;
  final DateTime? birthDate;
  final EducationLevel? educationLevel;
  final List<UserSkillEntity> skills;
  final List<ExperienceEntity> experiences;

  const RegistrationEntity({
    required this.name,
    required this.email,
    required this.password,
    required this.cpf,
    required this.gender,
    this.phone,
    this.birthDate,
    this.educationLevel,
    this.skills = const [],
    this.experiences = const [],
  });
}
