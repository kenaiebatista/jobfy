import '../../domain/entities/conversation_entity.dart';
import '../models/conversation_model.dart';
import 'messages_data_source.dart';

/// In-memory stand-in for [MessagesRemoteDataSource], used until the Go
/// backend is deployed. Follows the same rule as the real chat: one
/// conversation is open, the other is read-only (no approved application).
class MessagesFakeDataSource implements MessagesDataSource {
  final List<ConversationModel> _conversations = [
    ConversationModel(
      id: 'p1',
      name: 'TechNova Soluções Digitais',
      subtitle: 'Desenvolvedor(a) Flutter Pleno',
      unread: 1,
      canSend: true,
      messages: [
        MessageModel(
          id: 'm1',
          text: 'Olá! Sua candidatura foi aprovada. Podemos agendar uma conversa?',
          sentAt: DateTime.now().subtract(const Duration(hours: 3)),
          fromMe: false,
        ),
      ],
    ),
    ConversationModel(
      id: 'p2',
      name: 'Verde Agro Analytics',
      subtitle: null,
      unread: 0,
      canSend: false,
      messages: [
        MessageModel(
          id: 'm2',
          text: 'Obrigado pelo interesse na vaga.',
          sentAt: DateTime.now().subtract(const Duration(days: 4)),
          fromMe: false,
        ),
      ],
    ),
  ];

  int _nextId = 100;

  @override
  Future<List<ConversationModel>> getConversations(ChatParticipant me) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.of(_conversations);
  }

  @override
  Future<MessageModel> sendMessage({
    required ChatParticipant me,
    required String partnerId,
    required String text,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final i = _conversations.indexWhere((c) => c.id == partnerId);
    if (i < 0 || !_conversations[i].canSend) throw const MessageNotAllowedException();

    final message = MessageModel(
      id: 'm${_nextId++}',
      text: text,
      sentAt: DateTime.now(),
      fromMe: true,
    );
    final old = _conversations[i];
    _conversations[i] = ConversationModel(
      id: old.id,
      name: old.name,
      subtitle: old.subtitle,
      unread: old.unread,
      canSend: old.canSend,
      messages: [...old.messages, message],
    );
    return message;
  }

  @override
  Future<int> countUnread(ChatParticipant me) async {
    return _conversations.fold<int>(0, (sum, c) => sum + c.unread);
  }

  @override
  Future<void> markAsRead({required ChatParticipant me, required String partnerId}) async {
    final i = _conversations.indexWhere((c) => c.id == partnerId);
    if (i < 0) return;
    final old = _conversations[i];
    _conversations[i] = ConversationModel(
      id: old.id,
      name: old.name,
      subtitle: old.subtitle,
      unread: 0,
      canSend: old.canSend,
      messages: old.messages,
    );
  }
}
