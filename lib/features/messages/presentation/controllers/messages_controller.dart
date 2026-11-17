import 'package:flutter/foundation.dart';

import '../../domain/entities/conversation_entity.dart';
import '../../domain/usecases/get_conversations_usecase.dart';
import '../../domain/usecases/mark_conversation_read_usecase.dart';
import '../../domain/usecases/send_message_usecase.dart';

enum MessagesStatus { idle, loading, loaded, error }

/// What went wrong with the last send; the screen maps it to a message.
enum MessagesError { send, notAllowed }

/// State of the messages screen: the signed-in person's conversations, the
/// selected one, a search filter and the send flow. [refresh] is called on a
/// timer by the screen to pick up the other side's new messages.
class MessagesController extends ChangeNotifier {
  final ChatParticipant me;
  final GetConversationsUsecase _getConversationsUsecase;
  final SendMessageUsecase _sendMessageUsecase;
  final MarkConversationReadUsecase _markReadUsecase;

  MessagesController({
    required this.me,
    required GetConversationsUsecase getConversationsUsecase,
    required SendMessageUsecase sendMessageUsecase,
    required MarkConversationReadUsecase markReadUsecase,
  })  : _getConversationsUsecase = getConversationsUsecase,
        _sendMessageUsecase = sendMessageUsecase,
        _markReadUsecase = markReadUsecase;

  MessagesStatus _status = MessagesStatus.idle;
  List<ConversationEntity> _conversations = [];
  String? _selectedId;
  String _search = '';
  bool _isSending = false;
  MessagesError? _error;

  /// Bumped by local changes (a sent message) so a [refresh] that started
  /// before them doesn't bring the old list back.
  int _version = 0;
  bool _disposed = false;

  MessagesStatus get status => _status;
  bool get isLoading => _status == MessagesStatus.loading;
  bool get isSending => _isSending;
  MessagesError? get error => _error;
  String? get selectedId => _selectedId;

  List<ConversationEntity> get conversations {
    final term = _search.trim().toLowerCase();
    if (term.isEmpty) return _conversations;
    return _conversations
        .where((c) =>
            c.name.toLowerCase().contains(term) ||
            (c.subtitle ?? '').toLowerCase().contains(term))
        .toList();
  }

  bool get hasConversations => _conversations.isNotEmpty;

  ConversationEntity? get selected {
    for (final c in _conversations) {
      if (c.id == _selectedId) return c;
    }
    return null;
  }

  int get totalUnread => _conversations.fold(0, (sum, c) => sum + c.unread);

  /// Loads the conversations (with a spinner) and, when [openPartnerId] is
  /// one of them, opens it.
  Future<void> load({String? openPartnerId}) async {
    _status = MessagesStatus.loading;
    notifyListeners();

    try {
      _conversations = List.of(await _getConversationsUsecase(me));
      _status = MessagesStatus.loaded;
      if (openPartnerId != null && _conversations.any((c) => c.id == openPartnerId)) {
        _selectedId = openPartnerId;
        _markSelectedRead();
      }
    } catch (e) {
      debugPrint('Could not load conversations: $e');
      _status = MessagesStatus.error;
    }
    notifyListeners();
  }

  /// Reloads quietly (no spinner); on failure the screen keeps what it has.
  Future<void> refresh() async {
    if (_status == MessagesStatus.loading || _isSending) return;
    final version = _version;
    try {
      final fresh = await _getConversationsUsecase(me);
      if (version != _version || _isSending) return;
      _conversations = List.of(fresh);
      _status = MessagesStatus.loaded;
      _markSelectedRead();
      notifyListeners();
    } catch (e) {
      debugPrint('Could not refresh conversations: $e');
    }
  }

  void select(String id) {
    _selectedId = id;
    _error = null;
    _markSelectedRead();
    notifyListeners();
  }

  void closeConversation() {
    _selectedId = null;
    notifyListeners();
  }

  void setSearch(String value) {
    _search = value;
    notifyListeners();
  }

  /// Sends [text] in the selected conversation. Returns false (and sets
  /// [error]) when it wasn't sent, so the screen keeps the typed text.
  Future<bool> send(String text) async {
    final partnerId = _selectedId;
    final body = text.trim();
    if (partnerId == null || body.isEmpty || _isSending) return false;

    _isSending = true;
    _error = null;
    notifyListeners();

    var ok = false;
    try {
      final message = await _sendMessageUsecase(me: me, partnerId: partnerId, text: body);
      _replace(partnerId, (c) => c.copyWith(messages: [...c.messages, message]));
      _version++;
      ok = true;
    } on MessageNotAllowedException {
      // The approval was taken back meanwhile: the chat becomes read-only.
      _replace(partnerId, (c) => c.copyWith(canSend: false));
      _error = MessagesError.notAllowed;
    } catch (e) {
      debugPrint('Could not send message: $e');
      _error = MessagesError.send;
    }

    _isSending = false;
    notifyListeners();
    return ok;
  }

  void _replace(String id, ConversationEntity Function(ConversationEntity) change) {
    final i = _conversations.indexWhere((c) => c.id == id);
    if (i >= 0) _conversations[i] = change(_conversations[i]);
  }

  /// What was opened counts as read: clears the badge now and tells the
  /// database in the background.
  void _markSelectedRead() {
    final id = _selectedId;
    if (id == null) return;
    final i = _conversations.indexWhere((c) => c.id == id);
    if (i < 0 || _conversations[i].unread == 0) return;
    _conversations[i] = _conversations[i].copyWith(unread: 0);
    _markReadUsecase(me: me, partnerId: id).catchError((Object e) {
      debugPrint('Could not mark conversation $id as read: $e');
    });
  }

  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
