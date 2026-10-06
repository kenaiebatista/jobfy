class MessageEntity {
  final String id;
  final String texto;
  final String hora;
  final bool deUsuario;

  const MessageEntity({
    required this.id,
    required this.texto,
    required this.hora,
    required this.deUsuario,
  });
}

class ConversationEntity {
  final String id;
  final String nome;
  final String subtitulo;
  final bool online;
  final int naoLidas;
  final List<MessageEntity> mensagens;

  const ConversationEntity({
    required this.id,
    required this.nome,
    required this.subtitulo,
    required this.online,
    required this.naoLidas,
    required this.mensagens,
  });

  MessageEntity? get ultimaMensagem =>
      mensagens.isEmpty ? null : mensagens.last;

  ConversationEntity copyWith({
    List<MessageEntity>? mensagens,
    int? naoLidas,
  }) {
    return ConversationEntity(
      id: id,
      nome: nome,
      subtitulo: subtitulo,
      online: online,
      naoLidas: naoLidas ?? this.naoLidas,
      mensagens: mensagens ?? this.mensagens,
    );
  }
}
