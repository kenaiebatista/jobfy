import '../entities/conversation_entity.dart';

abstract class MessagesRepository {
  Future<List<ConversationEntity>> getConversations(String userId);

  Future<MessageEntity> sendMessage({
    required String conversationId,
    required String texto,
  });
}
