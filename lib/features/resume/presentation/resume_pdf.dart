import 'dart:typed_data';

import 'package:jobfy/features/user/domain/entities/user_profile_entity.dart';
import 'package:jobfy/features/user/presentation/user_labels.dart';
import 'package:jobfy/l10n/app_localizations.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// Builds the user's resume as a PDF, in memory only (nothing is written to
/// the device). Layout: name and headline, contact line, then the
/// Objective, Education, Experience and Skills sections.
Future<Uint8List> buildResumePdf(
  UserProfileEntity profile,
  AppLocalizations l10n,
) {
  final education =
      profile.educationLevel == null ? '' : l10n.educationLevel(profile.educationLevel!);
  // Headline under the name: current job, or the education level for a
  // first-job resume.
  final headline = profile.role.isNotEmpty ? profile.role : education;

  final skillNames = profile.skills.map((s) => s.name).toList();
  final objective = skillNames.isEmpty
      ? l10n.resumeObjectiveDefault
      : l10n.resumeObjectiveWithSkills(skillNames.take(3).join(', '));

  final doc = pw.Document(title: profile.name, author: profile.name);
  doc.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.symmetric(horizontal: 48, vertical: 44),
      build: (_) => [
        pw.Text(
          _latin1(profile.name.toUpperCase()),
          style: pw.TextStyle(fontSize: 30, fontWeight: pw.FontWeight.bold),
        ),
        if (headline.isNotEmpty)
          pw.Text(_latin1(headline), style: const pw.TextStyle(fontSize: 14)),
        pw.SizedBox(height: 10),
        pw.Divider(thickness: 0.8, height: 1),
        pw.SizedBox(height: 8),
        pw.Row(
          children: [
            pw.Text(_latin1(profile.phone ?? ''), style: const pw.TextStyle(fontSize: 10)),
            pw.SizedBox(width: 36),
            pw.Text(_latin1(profile.email), style: const pw.TextStyle(fontSize: 10)),
          ],
        ),
        pw.SizedBox(height: 8),
        pw.Divider(thickness: 0.8, height: 1),

        _section(l10n.resumeObjective),
        pw.Text(_latin1(objective), style: _body),

        _section(l10n.resumeEducation),
        pw.Text(_latin1(education), style: _itemTitle),

        if (profile.experiences.isNotEmpty) ...[
          _section(l10n.resumeExperience),
          for (final exp in profile.experiences) _experience(exp, l10n),
        ],

        if (profile.skills.isNotEmpty) ...[
          _section(l10n.resumeSkills),
          pw.Text(
            _latin1(profile.skills
                .map((s) => '${s.name} (${l10n.skillLevel(s.level)})')
                .join('  ·  ')),
            style: _body,
          ),
        ],
      ],
    ),
  );
  return doc.save();
}

const _body = pw.TextStyle(fontSize: 10, lineSpacing: 2);
final _itemTitle = pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold);

/// Section title, e.g. "EXPERIÊNCIAS".
pw.Widget _section(String title) => pw.Padding(
      padding: const pw.EdgeInsets.only(top: 18, bottom: 6),
      child: pw.Text(
        _latin1(title.toUpperCase()),
        style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold),
      ),
    );

/// "2019 - 2023 | COMPANY", then the job title and the description.
pw.Widget _experience(ExperienceEntity exp, AppLocalizations l10n) {
  final end = exp.endDate == null ? l10n.resumeCurrent : '${exp.endDate!.year}';
  return pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 10),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          _latin1('${exp.startDate.year} - $end | ${exp.companyName.toUpperCase()}'),
          style: _itemTitle,
        ),
        pw.Text(_latin1(exp.jobTitle), style: _body),
        if ((exp.description ?? '').isNotEmpty)
          pw.Text(
            _latin1(exp.description!),
            style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700, lineSpacing: 2),
          ),
      ],
    ),
  );
}

/// The built-in PDF font only has Latin-1 characters (Portuguese accents
/// are fine). Swap common typographic characters for plain ones and drop
/// anything else (e.g. emojis) so user text can never break the PDF.
String _latin1(String text) {
  const swaps = {'–': '-', '—': '-', '“': '"', '”': '"', '‘': "'", '’': "'", '•': '·', '…': '...'};
  final buffer = StringBuffer();
  for (final char in text.runes.map(String.fromCharCode)) {
    final swapped = swaps[char] ?? char;
    if (swapped.runes.every((r) => r <= 0xFF)) buffer.write(swapped);
  }
  return buffer.toString();
}
