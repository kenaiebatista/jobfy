import '../entities/conversation_entity.dart';
import '../repositories/messages_repository.dart';

class GetConversationsUsecase {
  final MessagesRepository _repository;

  const GetConversationsUsecase(this._repository);

  Future<List<ConversationEntity>> call(ChatParticipant me) {
    return _repository.getConversations(me);
  }
}
