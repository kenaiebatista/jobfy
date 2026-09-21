/// Ex.: "há 3 horas", "ontem", "há 2 dias".
String tempoRelativo(DateTime data) {
  final diff = DateTime.now().difference(data);

  if (diff.inMinutes < 1) return 'agora';
  if (diff.inMinutes < 60) return 'há ${diff.inMinutes} min';
  if (diff.inHours < 24) {
    return diff.inHours == 1 ? 'há 1 hora' : 'há ${diff.inHours} horas';
  }
  if (diff.inDays == 1) return 'ontem';
  if (diff.inDays < 30) return 'há ${diff.inDays} dias';

  final meses = diff.inDays ~/ 30;
  return meses == 1 ? 'há 1 mês' : 'há $meses meses';
}
