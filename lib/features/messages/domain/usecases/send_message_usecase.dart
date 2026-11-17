import '../entities/conversation_entity.dart';
import '../repositories/messages_repository.dart';

class SendMessageUsecase {
  final MessagesRepository _repository;

  const SendMessageUsecase(this._repository);

  Future<MessageEntity> call({
    required ChatParticipant me,
    required String partnerId,
    required String text,
  }) {
    return _repository.sendMessage(me: me, partnerId: partnerId, text: text);
  }
}
