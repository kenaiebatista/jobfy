import '../../domain/entities/conversation_entity.dart';
import '../models/conversation_model.dart';

/// Where [MessagesRepositoryImpl] gets its data from.
/// [MessagesMysqlDataSource] reads/writes the MySQL database directly;
/// [MessagesRemoteDataSource] is the future Go backend;
/// [MessagesFakeDataSource] is an in-memory stand-in.
abstract class MessagesDataSource {
  Future<List<ConversationModel>> getConversations(ChatParticipant me);

  /// Throws [MessageNotAllowedException] when the chat isn't open.
  Future<MessageModel> sendMessage({
    required ChatParticipant me,
    required String partnerId,
    required String text,
  });

  Future<void> markAsRead({required ChatParticipant me, required String partnerId});
}
