import 'package:flutter_test/flutter_test.dart';
import 'package:jobfy/features/messages/data/datasources/messages_data_source.dart';
import 'package:jobfy/features/messages/data/models/conversation_model.dart';
import 'package:jobfy/features/messages/data/repositories/messages_repository_impl.dart';
import 'package:jobfy/features/messages/domain/entities/conversation_entity.dart';
import 'package:jobfy/features/messages/domain/usecases/get_conversations_usecase.dart';
import 'package:jobfy/features/messages/domain/usecases/mark_conversation_read_usecase.dart';
import 'package:jobfy/features/messages/domain/usecases/send_message_usecase.dart';
import 'package:jobfy/features/messages/presentation/controllers/messages_controller.dart';

/// Two chats kept in memory: 'open' (approved) and 'locked' (not any more).
class _InMemoryChat implements MessagesDataSource {
  final readCalls = <String>[];
  var failSending = false;
  var approvalTakenBack = false;

  final conversations = <String, ConversationModel>{
    'open': const ConversationModel(
      id: 'open',
      name: 'TechNova',
      subtitle: 'Flutter Developer',
      unread: 2,
      canSend: true,
      messages: [],
    ),
    'locked': const ConversationModel(
      id: 'locked',
      name: 'Verde Agro',
      unread: 0,
      canSend: false,
      messages: [],
    ),
  };

  @override
  Future<List<ConversationModel>> getConversations(ChatParticipant me) async =>
      conversations.values.toList();

  @override
  Future<MessageModel> sendMessage({
    required ChatParticipant me,
    required String partnerId,
    required String text,
  }) async {
    if (failSending) throw StateError('offline');
    final chat = conversations[partnerId]!;
    if (!chat.canSend || approvalTakenBack) throw const MessageNotAllowedException();
    final message = MessageModel(
      id: 'm${chat.messages.length + 1}',
      text: text,
      sentAt: DateTime(2026, 11, 20, 10, chat.messages.length),
      fromMe: true,
    );
    conversations[partnerId] = ConversationModel(
      id: chat.id,
      name: chat.name,
      subtitle: chat.subtitle,
      unread: chat.unread,
      canSend: chat.canSend,
      messages: [...chat.messages, message],
    );
    return message;
  }

  @override
  Future<void> markAsRead({required ChatParticipant me, required String partnerId}) async {
    readCalls.add(partnerId);
  }
}

MessagesController _controller(_InMemoryChat source, {bool company = false}) {
  final repo = MessagesRepositoryImpl(source);
  return MessagesController(
    me: ChatParticipant(id: '1', isCompany: company),
    getConversationsUsecase: GetConversationsUsecase(repo),
    sendMessageUsecase: SendMessageUsecase(repo),
    markReadUsecase: MarkConversationReadUsecase(repo),
  );
}

void main() {
  late _InMemoryChat source;
  late MessagesController controller;

  setUp(() {
    source = _InMemoryChat();
    controller = _controller(source);
  });

  test('loads the conversations and counts the unread messages', () async {
    await controller.load();

    expect(controller.status, MessagesStatus.loaded);
    expect(controller.conversations.map((c) => c.name), ['TechNova', 'Verde Agro']);
    expect(controller.totalUnread, 2);
    expect(controller.selected, isNull);
  });

  test('search filters by name and by job title', () async {
    await controller.load();

    controller.setSearch('verde');
    expect(controller.conversations.map((c) => c.id), ['locked']);
    controller.setSearch('flutter');
    expect(controller.conversations.map((c) => c.id), ['open']);
    controller.setSearch('nada');
    expect(controller.conversations, isEmpty);
    expect(controller.hasConversations, isTrue);
  });

  test('opening a conversation marks it as read', () async {
    await controller.load();

    controller.select('open');

    expect(controller.selected!.unread, 0);
    expect(controller.totalUnread, 0);
    expect(source.readCalls, ['open']);

    // Nothing unread: no second call.
    controller.select('open');
    expect(source.readCalls, ['open']);
  });

  test('load can open a conversation straight away (company "send message")', () async {
    await controller.load(openPartnerId: 'open');
    expect(controller.selectedId, 'open');
    expect(source.readCalls, ['open']);

    // A partner that isn't in the list is ignored.
    final other = _controller(_InMemoryChat());
    await other.load(openPartnerId: 'someone-else');
    expect(other.selectedId, isNull);
  });

  test('sending adds the message to the open conversation', () async {
    await controller.load();
    controller.select('open');

    final ok = await controller.send('  Olá!  ');

    expect(ok, isTrue);
    expect(controller.selected!.messages.single.text, 'Olá!'); // trimmed
    expect(controller.selected!.messages.single.fromMe, isTrue);
    expect(controller.error, isNull);
  });

  test('an empty message or no open conversation sends nothing', () async {
    await controller.load();

    expect(await controller.send('oi'), isFalse); // nothing selected
    controller.select('open');
    expect(await controller.send('   '), isFalse);
    expect(source.conversations['open']!.messages, isEmpty);
  });

  test('a chat without approval refuses the message and stays read-only', () async {
    await controller.load();
    controller.select('locked');

    final ok = await controller.send('Oi');

    expect(ok, isFalse);
    expect(controller.error, MessagesError.notAllowed);
    expect(controller.selected!.canSend, isFalse);
    expect(source.conversations['locked']!.messages, isEmpty);
  });

  test('when the approval is taken back meanwhile, the chat turns read-only', () async {
    await controller.load();
    controller.select('open');
    source.approvalTakenBack = true;

    expect(await controller.send('Oi'), isFalse);
    expect(controller.error, MessagesError.notAllowed);
    expect(controller.selected!.canSend, isFalse);
  });

  test('a network failure is reported and the typed text can be kept', () async {
    await controller.load();
    controller.select('open');
    source.failSending = true;

    expect(await controller.send('Oi'), isFalse);
    expect(controller.error, MessagesError.send);
    expect(controller.selected!.canSend, isTrue);
  });

  test('refresh brings the partner\'s new messages without a spinner', () async {
    await controller.load();
    controller.select('open');
    source.conversations['open'] = ConversationModel(
      id: 'open',
      name: 'TechNova',
      subtitle: 'Flutter Developer',
      unread: 1,
      canSend: true,
      messages: [
        MessageModel(id: 'x', text: 'Bom dia', sentAt: DateTime(2026, 11, 20), fromMe: false),
      ],
    );

    await controller.refresh();

    expect(controller.status, MessagesStatus.loaded);
    expect(controller.selected!.messages.single.text, 'Bom dia');
    // It's the open conversation, so it's read right away.
    expect(controller.selected!.unread, 0);
    expect(source.readCalls, ['open', 'open']);
  });

  test('a company chats the same way', () async {
    final company = _controller(source, company: true);
    await company.load();
    company.select('open');

    expect(await company.send('Podemos conversar?'), isTrue);
    expect(company.me.isCompany, isTrue);
  });
}
