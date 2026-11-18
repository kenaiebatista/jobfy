import 'package:flutter/foundation.dart' show debugPrint;
import 'package:jobfy/core/database/database_service.dart';
import 'package:jobfy/core/network/api_exception.dart';
import '../../domain/entities/conversation_entity.dart';
import '../models/conversation_model.dart';
import 'messages_data_source.dart';

/// Chat straight from the Jobfy MySQL database through [DatabaseService].
/// Stand-in until the Go backend ([MessagesRemoteDataSource]) is deployed.
///
/// The rule that a chat only exists between a user and a company, after the
/// company approved the user's application, lives in the queries
/// ([DatabaseService.getChat], [DatabaseService.sendChatMessage]).
class MessagesMysqlDataSource implements MessagesDataSource {
  @override
  Future<List<ConversationModel>> getConversations(ChatParticipant me) async {
    final chat = await DatabaseService.getChat(
      asCompany: me.isCompany,
      id: int.parse(me.id),
    );

    final byPartner = <String, List<Map<String, dynamic>>>{};
    for (final m in chat.messages) {
      byPartner.putIfAbsent('${m['partner_id']}', () => []).add(m);
    }

    final conversations = [
      for (final p in chat.partners)
        ConversationModel.fromJson({
          'id': p['partner_id'],
          'name': p['name'],
          'subtitle': p['subtitle'],
          'unread': p['unread'],
          'can_send': p['can_send'],
          'messages': [
            for (final m in byPartner[p['partner_id']] ?? const [])
              {'id': m['id'], 'text': m['body'], 'sent_at': m['sent_at'], 'mine': m['mine']},
          ],
        }),
    ];

    // Most recent conversation first; chats with no message yet at the end.
    DateTime? last(ConversationModel c) => c.lastMessage?.sentAt;
    conversations.sort((a, b) {
      final x = last(a), y = last(b);
      if (x == null && y == null) return a.name.compareTo(b.name);
      if (x == null) return 1;
      if (y == null) return -1;
      return y.compareTo(x);
    });
    return conversations;
  }

  @override
  Future<MessageModel> sendMessage({
    required ChatParticipant me,
    required String partnerId,
    required String text,
  }) async {
    try {
      final sent = await DatabaseService.sendChatMessage(
        asCompany: me.isCompany,
        id: int.parse(me.id),
        partnerId: int.parse(partnerId),
        text: text,
      );
      return MessageModel.fromJson({
        'id': sent['id'],
        'text': text,
        'sent_at': sent['sent_at'],
        'mine': true,
      });
    } on ChatNotAllowedException {
      throw const MessageNotAllowedException();
    } catch (e) {
      debugPrint('MySQL error (host ${DatabaseService.host}): $e');
      throw ApiUnreachableException(e.toString());
    }
  }

  @override
  Future<int> countUnread(ChatParticipant me) {
    return DatabaseService.countUnreadMessages(asCompany: me.isCompany, id: int.parse(me.id));
  }

  @override
  Future<void> markAsRead({required ChatParticipant me, required String partnerId}) {
    return DatabaseService.markChatRead(
      asCompany: me.isCompany,
      id: int.parse(me.id),
      partnerId: int.parse(partnerId),
    );
  }
}
