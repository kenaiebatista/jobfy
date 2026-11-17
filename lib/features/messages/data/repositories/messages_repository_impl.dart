import 'package:jobfy/core/config/app_config.dart';
import 'package:jobfy/core/network/api_client.dart';
import '../../domain/entities/conversation_entity.dart';
import '../../domain/repositories/messages_repository.dart';
import '../datasources/messages_data_source.dart';
import '../datasources/messages_fake_data_source.dart';
import '../datasources/messages_mysql_data_source.dart';
import '../datasources/messages_remote_data_source.dart';

class MessagesRepositoryImpl implements MessagesRepository {
  final MessagesDataSource _dataSource;

  MessagesRepositoryImpl([MessagesDataSource? dataSource])
      : _dataSource = dataSource ??
            (AppConfig.useMysql
                ? MessagesMysqlDataSource()
                : AppConfig.useFakeBackend
                    ? MessagesFakeDataSource()
                    : MessagesRemoteDataSource(ApiClient()));

  @override
  Future<List<ConversationEntity>> getConversations(ChatParticipant me) {
    return _dataSource.getConversations(me);
  }

  @override
  Future<MessageEntity> sendMessage({
    required ChatParticipant me,
    required String partnerId,
    required String text,
  }) {
    return _dataSource.sendMessage(me: me, partnerId: partnerId, text: text);
  }

  @override
  Future<void> markAsRead({required ChatParticipant me, required String partnerId}) {
    return _dataSource.markAsRead(me: me, partnerId: partnerId);
  }
}
