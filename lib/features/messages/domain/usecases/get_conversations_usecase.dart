import '../entities/conversation_entity.dart';
import '../repositories/messages_repository.dart';

class GetConversationsUsecase {
  final MessagesRepository _repository;

  const GetConversationsUsecase(this._repository);

  Future<List<ConversationEntity>> call(String userId) {
    return _repository.getConversations(userId);
  }
}
