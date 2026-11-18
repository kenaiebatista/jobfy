import '../entities/conversation_entity.dart';
import '../repositories/messages_repository.dart';

class GetUnreadMessagesUsecase {
  final MessagesRepository _repository;

  const GetUnreadMessagesUsecase(this._repository);

  Future<int> call(ChatParticipant me) => _repository.countUnread(me);
}
