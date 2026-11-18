import '../entities/conversation_entity.dart';

abstract class MessagesRepository {
  /// The signed-in person's chats, with all their messages.
  Future<List<ConversationEntity>> getConversations(ChatParticipant me);

  /// Throws [MessageNotAllowedException] when the chat isn't open.
  Future<MessageEntity> sendMessage({
    required ChatParticipant me,
    required String partnerId,
    required String text,
  });

  Future<void> markAsRead({required ChatParticipant me, required String partnerId});

  /// How many messages [me] has not read yet, over all chats.
  Future<int> countUnread(ChatParticipant me);
}
