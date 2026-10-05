import 'package:jobfy/features/user/domain/entities/user_profile_entity.dart';
import 'package:jobfy/l10n/app_localizations.dart';

/// Localized text for the profile's enum values, shared by the sign-up form
/// and the dashboard.
extension UserLabels on AppLocalizations {
  String gender(Gender g) => switch (g) {
        Gender.male => genderMale,
        Gender.female => genderFemale,
        Gender.other => genderOther,
      };

  String skillLevel(SkillLevel level) => switch (level) {
        SkillLevel.beginner => skillLevelBeginner,
        SkillLevel.intermediate => skillLevelIntermediate,
        SkillLevel.advanced => skillLevelAdvanced,
      };

  String educationLevel(EducationLevel level) => switch (level) {
        EducationLevel.elementaryIncomplete => educationElementaryIncomplete,
        EducationLevel.elementaryComplete => educationElementaryComplete,
        EducationLevel.highSchoolIncomplete => educationHighSchoolIncomplete,
        EducationLevel.highSchoolComplete => educationHighSchoolComplete,
        EducationLevel.technical => educationTechnical,
        EducationLevel.bachelorIncomplete => educationBachelorIncomplete,
        EducationLevel.bachelorComplete => educationBachelorComplete,
        EducationLevel.postgraduate => educationPostgraduate,
      };
}

/// 'dd/mm/yyyy', used for birth dates and experience periods.
String formatDate(DateTime d) {
  String two(int n) => n.toString().padLeft(2, '0');
  return '${two(d.day)}/${two(d.month)}/${d.year}';
}

/// 'mm/yyyy', used for experience periods.
String formatMonthYear(DateTime d) => '${d.month.toString().padLeft(2, '0')}/${d.year}';
