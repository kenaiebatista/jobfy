import 'package:aplicativo_jobfy/l10n/app_localizations.dart';

/// Ex.: "3 hours ago", "yesterday", "2 days ago" (localized).
String tempoRelativo(AppLocalizations l10n, DateTime data) {
  final diff = DateTime.now().difference(data);

  if (diff.inMinutes < 1) return l10n.timeAgoNow;
  if (diff.inMinutes < 60) return l10n.timeAgoMinutes(diff.inMinutes);
  if (diff.inHours < 24) return l10n.timeAgoHours(diff.inHours);
  if (diff.inDays == 1) return l10n.timeAgoYesterday;
  if (diff.inDays < 30) return l10n.timeAgoDays(diff.inDays);

  final meses = diff.inDays ~/ 30;
  return l10n.timeAgoMonths(meses);
}
