import '../../domain/entities/conversation_entity.dart';

/// MySQL sends every value as text ('1'/'0' for booleans), the backend JSON
/// uses real booleans; both are read the same way.
bool _flag(Object? value) => value == true || '$value' == '1';

class MessageModel extends MessageEntity {
  const MessageModel({
    required super.id,
    required super.text,
    required super.sentAt,
    required super.fromMe,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: '${json['id']}',
      text: '${json['text'] ?? ''}',
      sentAt: DateTime.tryParse('${json['sent_at'] ?? ''}') ?? DateTime.now(),
      fromMe: _flag(json['mine']),
    );
  }
}

class ConversationModel extends ConversationEntity {
  const ConversationModel({
    required super.id,
    required super.name,
    super.subtitle,
    required super.unread,
    required super.canSend,
    required super.messages,
  });

  /// `messages` is a list of [MessageModel] JSON maps, oldest first.
  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    final subtitle = json['subtitle']?.toString().trim();
    return ConversationModel(
      id: '${json['id']}',
      name: '${json['name'] ?? ''}',
      subtitle: subtitle == null || subtitle.isEmpty ? null : subtitle,
      unread: int.tryParse('${json['unread'] ?? 0}') ?? 0,
      canSend: _flag(json['can_send']),
      messages: [
        for (final m in (json['messages'] as List? ?? const []))
          MessageModel.fromJson(m as Map<String, dynamic>),
      ],
    );
  }
}
