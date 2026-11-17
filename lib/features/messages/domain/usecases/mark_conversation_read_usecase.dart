import '../entities/conversation_entity.dart';
import '../repositories/messages_repository.dart';

class MarkConversationReadUsecase {
  final MessagesRepository _repository;

  const MarkConversationReadUsecase(this._repository);

  Future<void> call({required ChatParticipant me, required String partnerId}) {
    return _repository.markAsRead(me: me, partnerId: partnerId);
  }
}
