/// Who is signed in to the chat: a user (`users.user_id`) or a company
/// (`companies.company_id`). A chat is always between one of each.
class ChatParticipant {
  final String id;
  final bool isCompany;

  const ChatParticipant({required this.id, required this.isCompany});
}

/// One message of a conversation (`messages`).
class MessageEntity {
  final String id;
  final String text;
  final DateTime sentAt;

  /// True when the signed-in person wrote it.
  final bool fromMe;

  const MessageEntity({
    required this.id,
    required this.text,
    required this.sentAt,
    required this.fromMe,
  });
}

/// The chat with one partner: a company when a user is signed in, a user
/// when a company is. [id] is the partner's profile id.
class ConversationEntity {
  final String id;
  final String name;

  /// Title of the job that was approved (what opened the chat), if any.
  final String? subtitle;

  /// Messages from the partner not read yet.
  final int unread;

  /// Messages can only be sent while the company keeps one of the user's
  /// applications approved; otherwise the history is read-only.
  final bool canSend;
  final List<MessageEntity> messages;

  const ConversationEntity({
    required this.id,
    required this.name,
    this.subtitle,
    required this.unread,
    required this.canSend,
    required this.messages,
  });

  MessageEntity? get lastMessage => messages.isEmpty ? null : messages.last;

  ConversationEntity copyWith({
    int? unread,
    bool? canSend,
    List<MessageEntity>? messages,
  }) {
    return ConversationEntity(
      id: id,
      name: name,
      subtitle: subtitle,
      unread: unread ?? this.unread,
      canSend: canSend ?? this.canSend,
      messages: messages ?? this.messages,
    );
  }
}

/// The message was refused because the chat isn't open: no approved
/// application between this user and company.
class MessageNotAllowedException implements Exception {
  const MessageNotAllowedException();
}
