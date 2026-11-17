import 'dart:async';

import 'package:jobfy/core/session/user_session_controller.dart';
import 'package:jobfy/core/theme/build_context_x.dart';
import 'package:jobfy/features/messages/data/repositories/messages_repository_impl.dart';
import 'package:jobfy/features/messages/domain/entities/conversation_entity.dart';
import 'package:jobfy/features/messages/domain/repositories/messages_repository.dart';
import 'package:jobfy/features/messages/domain/usecases/get_conversations_usecase.dart';
import 'package:jobfy/features/messages/domain/usecases/mark_conversation_read_usecase.dart';
import 'package:jobfy/features/messages/domain/usecases/send_message_usecase.dart';
import 'package:jobfy/features/messages/presentation/controllers/messages_controller.dart';
import 'package:jobfy/l10n/app_localizations.dart';
import 'package:jobfy/shared/widgets/app_shell.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Chat between a user and a company. It only lists people the signed-in
/// side can talk to (a company approved the user's application), and only
/// lets them write while that approval stands.
///
/// Users get the usual sidebar shell; a company has no sidebar, so it gets a
/// plain page with a back button, like its settings. On wide screens the
/// conversation list and the thread sit side by side; on narrow ones they
/// are two panes with a back button in the thread.
class MessagesPage extends StatefulWidget {
  /// Opens this partner's conversation once loaded (the company's
  /// "Send message" button on an approved candidate).
  final String? openPartnerId;

  /// Where the chat comes from. Defaults to [MessagesRepositoryImpl]
  /// (MySQL/fake/remote per AppConfig); tests pass their own.
  final MessagesRepository? repository;

  /// How often new messages are fetched while the page is open.
  final Duration pollInterval;

  const MessagesPage({
    super.key,
    this.openPartnerId,
    this.repository,
    this.pollInterval = const Duration(seconds: 5),
  });

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  late final MessagesController _controller;
  late final Timer _poll;
  final _inputController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final session = context.read<UserSessionController>();
    final repo = widget.repository ?? MessagesRepositoryImpl();
    _controller = MessagesController(
      me: ChatParticipant(
        id: session.companyId ?? session.userId ?? '',
        isCompany: session.isCompanySignedIn,
      ),
      getConversationsUsecase: GetConversationsUsecase(repo),
      sendMessageUsecase: SendMessageUsecase(repo),
      markReadUsecase: MarkConversationReadUsecase(repo),
    );
    _controller.load(openPartnerId: widget.openPartnerId);
    _poll = Timer.periodic(widget.pollInterval, (_) => _controller.refresh());
    if (!session.isCompanySignedIn) session.ensureLoaded();
  }

  @override
  void dispose() {
    _poll.cancel();
    _controller.dispose();
    _inputController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final text = _inputController.text;
    if (text.trim().isEmpty) return;

    final ok = await _controller.send(text);
    if (ok) {
      _inputController.clear();
      return;
    }
    final error = _controller.error;
    if (error == null) return;
    messenger.showSnackBar(SnackBar(
      content: Text(error == MessagesError.notAllowed
          ? l10n.messagesNotAllowed
          : l10n.messagesSendError),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<UserSessionController>();

    final body = ListenableBuilder(
      listenable: _controller,
      builder: (context, _) => _ChatBody(
        controller: _controller,
        inputController: _inputController,
        onSend: _send,
      ),
    );

    if (session.isCompanySignedIn) {
      return body;
    }

    return ProfileGate(
        profile: session.profile,
        isError: session.status == UserSessionStatus.error,
        builder: (context, profile) => body,
      );
  }
}

/// Minimum content width for the conversation list and thread side by side.
const _splitWidth = 640.0;

class _ChatBody extends StatelessWidget {
  final MessagesController controller;
  final TextEditingController inputController;
  final VoidCallback onSend;

  const _ChatBody({
    required this.controller,
    required this.inputController,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;

    if (controller.isLoading) return const Center(child: CircularProgressIndicator());
    if (controller.status == MessagesStatus.error) {
      return Center(
        child: Text(l10n.messagesLoadError, style: TextStyle(color: colors.danger)),
      );
    }

    final selected = controller.selected;
    final list = _ConversationList(controller: controller);

    return LayoutBuilder(
      builder: (context, constraints) {
        // Two panes side by side only when there's room for both; the
        // content area already excludes the sidebar.
        final split = constraints.maxWidth >= _splitWidth;
        final thread = selected == null
            ? const _EmptyThread()
            : _Thread(
                conversation: selected,
                inputController: inputController,
                isSending: controller.isSending,
                onSend: onSend,
                // Without the list beside it, the thread needs a way back.
                onBack: split ? null : controller.closeConversation,
              );
        if (split) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(width: 320, child: list),
              VerticalDivider(width: 1, color: colors.surfaceBorder),
              Expanded(child: thread),
            ],
          );
        }
        return selected == null ? list : thread;
      },
    );
  }
}

class _ConversationList extends StatelessWidget {
  final MessagesController controller;

  const _ConversationList({required this.controller});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final conversations = controller.conversations;

    return Container(
      color: colors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: TextField(
              onChanged: controller.setSearch,
              decoration: InputDecoration(
                hintText: l10n.messagesSearchHint,
                prefixIcon: const Icon(Icons.search, size: 18),
              ),
            ),
          ),
          Divider(height: 1, color: colors.surfaceBorder),
          Expanded(
            child: conversations.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        spacing: 6,
                        children: [
                          Icon(Icons.chat_bubble_outline, size: 36, color: colors.textMuted),
                          Text(
                            controller.hasConversations ? l10n.messagesNoMatch : l10n.messagesEmpty,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: colors.textPrimary, fontSize: 14),
                          ),
                          if (!controller.hasConversations)
                            Text(
                              l10n.messagesEmptyHint,
                              textAlign: TextAlign.center,
                              style: TextStyle(color: colors.textMuted, fontSize: 12.5),
                            ),
                        ],
                      ),
                    ),
                  )
                : ListView.separated(
                    itemCount: conversations.length,
                    separatorBuilder: (_, __) => Divider(height: 1, color: colors.surfaceBorder),
                    itemBuilder: (context, i) => _ConversationTile(
                      conversation: conversations[i],
                      isSelected: controller.selectedId == conversations[i].id,
                      onTap: () => controller.select(conversations[i].id),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

String _initials(String name) {
  final words = name.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty);
  return words.isEmpty ? '?' : words.take(2).map((w) => w[0]).join().toUpperCase();
}

/// "14:05" for today, "02/11 14:05" for any other day.
String _formatMessageTime(DateTime time) {
  String two(int n) => n.toString().padLeft(2, '0');
  final now = DateTime.now();
  final clock = '${two(time.hour)}:${two(time.minute)}';
  final today = time.year == now.year && time.month == now.month && time.day == now.day;
  return today ? clock : '${two(time.day)}/${two(time.month)} $clock';
}

class _Avatar extends StatelessWidget {
  final String name;
  final double radius;

  const _Avatar({required this.name, required this.radius});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return CircleAvatar(
      radius: radius,
      backgroundColor: colors.accent,
      child: Text(
        _initials(name),
        style: TextStyle(
          color: colors.onAccent,
          fontWeight: FontWeight.bold,
          fontSize: radius * 0.6,
        ),
      ),
    );
  }
}

class _ConversationTile extends StatelessWidget {
  final ConversationEntity conversation;
  final bool isSelected;
  final VoidCallback onTap;

  const _ConversationTile({
    required this.conversation,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final last = conversation.lastMessage;
    final hasUnread = conversation.unread > 0;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        color: isSelected ? colors.accent.withValues(alpha: 0.08) : null,
        child: Row(
          spacing: 12,
          children: [
            _Avatar(name: conversation.name, radius: 22),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 2,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          conversation.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13.5,
                            color: colors.textPrimary,
                          ),
                        ),
                      ),
                      if (last != null)
                        Text(
                          _formatMessageTime(last.sentAt),
                          style: TextStyle(fontSize: 11, color: colors.textMuted),
                        ),
                    ],
                  ),
                  if (conversation.subtitle != null)
                    Text(
                      conversation.subtitle!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 11, color: colors.textMuted),
                    ),
                  Row(
                    spacing: 6,
                    children: [
                      Expanded(
                        child: Text(
                          last?.text ?? l10n.messagesNoMessagesYet,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12.5,
                            color: hasUnread ? colors.textPrimary : colors.textMuted,
                            fontWeight: hasUnread ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                      ),
                      if (hasUnread)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: colors.accent,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${conversation.unread}',
                            style: TextStyle(
                              color: colors.onAccent,
                              fontSize: 10.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyThread extends StatelessWidget {
  const _EmptyThread();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 12,
        children: [
          Icon(Icons.chat_bubble_outline, size: 48, color: colors.textMuted),
          Text(
            AppLocalizations.of(context)!.messagesSelect,
            style: TextStyle(color: colors.textMuted, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _Thread extends StatelessWidget {
  final ConversationEntity conversation;
  final TextEditingController inputController;
  final bool isSending;
  final VoidCallback onSend;
  final VoidCallback? onBack;

  const _Thread({
    required this.conversation,
    required this.inputController,
    required this.isSending,
    required this.onSend,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: colors.surface,
            border: Border(bottom: BorderSide(color: colors.surfaceBorder)),
          ),
          child: Row(
            spacing: 10,
            children: [
              if (onBack != null)
                IconButton(
                  tooltip: l10n.settingsBack,
                  icon: const Icon(Icons.arrow_back),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: onBack,
                ),
              _Avatar(name: conversation.name, radius: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      conversation.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: colors.textPrimary,
                      ),
                    ),
                    if (conversation.subtitle != null)
                      Text(
                        conversation.subtitle!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 11.5, color: colors.textMuted),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Container(
            color: colors.background,
            child: conversation.messages.isEmpty
                ? Center(
                    child: Text(
                      l10n.messagesNoMessagesYet,
                      style: TextStyle(color: colors.textMuted, fontSize: 13),
                    ),
                  )
                : ListView.builder(
                    reverse: true,
                    padding: const EdgeInsets.all(16),
                    itemCount: conversation.messages.length,
                    itemBuilder: (context, i) => _MessageBubble(
                      message: conversation.messages[conversation.messages.length - 1 - i],
                    ),
                  ),
          ),
        ),
        if (conversation.canSend)
          Container(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
            decoration: BoxDecoration(
              color: colors.surface,
              border: Border(top: BorderSide(color: colors.surfaceBorder)),
            ),
            child: Row(
              spacing: 8,
              children: [
                Expanded(
                  child: TextField(
                    controller: inputController,
                    minLines: 1,
                    maxLines: 4,
                    maxLength: 2000,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => onSend(),
                    decoration: InputDecoration(
                      hintText: l10n.messagesInputHint,
                      counterText: '',
                    ),
                  ),
                ),
                IconButton(
                  tooltip: l10n.messagesSendTooltip,
                  onPressed: isSending ? null : onSend,
                  style: IconButton.styleFrom(
                    backgroundColor: colors.accent,
                    foregroundColor: colors.onAccent,
                    shape: const CircleBorder(),
                  ),
                  icon: isSending
                      ? SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: colors.onAccent),
                        )
                      : const Icon(Icons.send, size: 18),
                ),
              ],
            ),
          )
        else
          // The approval is gone (or was never there): history only.
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colors.surface,
              border: Border(top: BorderSide(color: colors.surfaceBorder)),
            ),
            child: Row(
              spacing: 10,
              children: [
                Icon(Icons.lock_outline, size: 18, color: colors.textMuted),
                Expanded(
                  child: Text(
                    l10n.messagesLocked,
                    style: TextStyle(fontSize: 13, color: colors.textMuted),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final MessageEntity message;

  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final mine = message.fromMe;

    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: const BoxConstraints(maxWidth: 360),
        decoration: BoxDecoration(
          color: mine ? colors.accent : colors.surface,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(14),
            topRight: const Radius.circular(14),
            bottomLeft: Radius.circular(mine ? 14 : 2),
            bottomRight: Radius.circular(mine ? 2 : 14),
          ),
          border: mine ? null : Border.all(color: colors.surfaceBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          spacing: 4,
          children: [
            Text(
              message.text,
              style: TextStyle(
                color: mine ? colors.onAccent : colors.textPrimary,
                fontSize: 13.5,
                height: 1.4,
              ),
            ),
            Text(
              _formatMessageTime(message.sentAt),
              style: TextStyle(
                color: (mine ? colors.onAccent : colors.textMuted).withValues(alpha: 0.7),
                fontSize: 10.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
