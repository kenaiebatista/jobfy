import 'package:jobfy/core/network/api_client.dart';
import 'package:jobfy/core/network/api_exception.dart';
import '../../domain/entities/conversation_entity.dart';
import '../models/conversation_model.dart';
import 'messages_data_source.dart';

/// Talks to the Jobfy backend's chat endpoints. `role` is "user" or
/// "company" and `id` the signed-in profile id.
///
/// Expected contract (Go backend, JSON, snake_case fields):
///   GET  /chat/conversations?role=&id=            -> `List<ConversationModel>`
///   POST /chat/conversations/{partnerId}/messages {role, id, text}
///                                                 -> MessageModel (403 = chat not open)
///   PUT  /chat/conversations/{partnerId}/read     {role, id}
class MessagesRemoteDataSource implements MessagesDataSource {
  final ApiClient _client;

  MessagesRemoteDataSource(this._client);

  Map<String, String> _who(ChatParticipant me) => {
        'role': me.isCompany ? 'company' : 'user',
        'id': me.id,
      };

  @override
  Future<List<ConversationModel>> getConversations(ChatParticipant me) async {
    final json = await _client.get('/chat/conversations', query: _who(me)) as List;
    return json.map((c) => ConversationModel.fromJson(c as Map<String, dynamic>)).toList();
  }

  @override
  Future<MessageModel> sendMessage({
    required ChatParticipant me,
    required String partnerId,
    required String text,
  }) async {
    try {
      final json = await _client.post(
        '/chat/conversations/$partnerId/messages',
        body: {..._who(me), 'text': text},
      ) as Map<String, dynamic>;
      return MessageModel.fromJson({...json, 'mine': true});
    } on ApiStatusException catch (e) {
      if (e.statusCode == 403) throw const MessageNotAllowedException();
      rethrow;
    }
  }

  @override
  Future<void> markAsRead({required ChatParticipant me, required String partnerId}) {
    return _client.put('/chat/conversations/$partnerId/read', body: _who(me));
  }
}
