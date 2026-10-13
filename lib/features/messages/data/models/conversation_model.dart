import '../../domain/entities/conversation_entity.dart';

class ConversationModel extends ConversationEntity {
  const ConversationModel({
    required super.id,
    required super.nome,
    required super.subtitulo,
    required super.online,
    required super.naoLidas,
    required super.mensagens,
  });
}
