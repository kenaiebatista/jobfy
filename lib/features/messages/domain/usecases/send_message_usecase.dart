import '../entities/conversation_entity.dart';
import '../repositories/messages_repository.dart';

class SendMessageUsecase {
  final MessagesRepository _repository;

  const SendMessageUsecase(this._repository);

  Future<MessageEntity> call({
    required String conversationId,
    required String texto,
  }) {
    return _repository.sendMessage(
      conversationId: conversationId,
      texto: texto,
    );
  }
}
