import 'package:jobfy/features/user/domain/entities/user_profile_entity.dart';

/// Profile information the resume can't be generated without. Name and
/// email always exist (they come from sign-up); skills and experiences are
/// optional, so a first-job resume still works without them.
enum ResumeRequirement { phone, educationLevel }

/// What [profile] is missing to generate the resume (empty = ready).
List<ResumeRequirement> missingResumeInfo(UserProfileEntity profile) => [
      if ((profile.phone ?? '').trim().isEmpty) ResumeRequirement.phone,
      if (profile.educationLevel == null) ResumeRequirement.educationLevel,
    ];
