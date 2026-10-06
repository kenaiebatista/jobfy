import 'package:flutter/foundation.dart';

import '../../domain/entities/conversation_entity.dart';
import '../../domain/usecases/get_conversations_usecase.dart';
import '../../domain/usecases/send_message_usecase.dart';

enum MessagesStatus { idle, loading, loaded, error }

/// Holds the messages screen state: the loaded list of conversations, which
/// one is selected, a search filter and the (mocked) send-message flow.
/// Mirrors the load/notify pattern used by UserController/SettingsController.
class MessagesController extends ChangeNotifier {
  final GetConversationsUsecase _getConversationsUsecase;
  final SendMessageUsecase _sendMessageUsecase;

  MessagesController(this._getConversationsUsecase, this._sendMessageUsecase);

  MessagesStatus _status = MessagesStatus.idle;
  List<ConversationEntity> _conversas = [];
  String? _selectedId;
  String _busca = '';
  bool _isSending = false;

  MessagesStatus get status => _status;
  bool get isLoading => _status == MessagesStatus.loading;
  bool get isSending => _isSending;
  String? get selectedId => _selectedId;
  String get busca => _busca;

  List<ConversationEntity> get conversas {
    if (_busca.trim().isEmpty) return _conversas;
    final termo = _busca.trim().toLowerCase();
    return _conversas
        .where((c) =>
            c.nome.toLowerCase().contains(termo) ||
            c.subtitulo.toLowerCase().contains(termo))
        .toList();
  }

  ConversationEntity? get conversaSelecionada {
    if (_selectedId == null) return null;
    for (final c in _conversas) {
      if (c.id == _selectedId) return c;
    }
    return null;
  }

  int get totalNaoLidas =>
      _conversas.fold(0, (soma, c) => soma + c.naoLidas);

  Future<void> loadConversations(String userId) async {
    _status = MessagesStatus.loading;
    notifyListeners();

    try {
      _conversas = await _getConversationsUsecase(userId);
      _status = MessagesStatus.loaded;
    } catch (_) {
      _status = MessagesStatus.error;
    }
    notifyListeners();
  }

  void selecionarConversa(String id) {
    _selectedId = id;
    final index = _conversas.indexWhere((c) => c.id == id);
    if (index != -1 && _conversas[index].naoLidas != 0) {
      _conversas[index] = _conversas[index].copyWith(naoLidas: 0);
    }
    notifyListeners();
  }

  void fecharConversa() {
    _selectedId = null;
    notifyListeners();
  }

  void setBusca(String value) {
    _busca = value;
    notifyListeners();
  }

  Future<void> enviarMensagem(String texto) async {
    final conversationId = _selectedId;
    if (conversationId == null || texto.trim().isEmpty) return;

    _isSending = true;
    notifyListeners();

    final novaMensagem = await _sendMessageUsecase(
      conversationId: conversationId,
      texto: texto.trim(),
    );

    final index = _conversas.indexWhere((c) => c.id == conversationId);
    if (index != -1) {
      _conversas[index] = _conversas[index].copyWith(
        mensagens: [..._conversas[index].mensagens, novaMensagem],
        naoLidas: 0,
      );
    }

    _isSending = false;
    notifyListeners();
  }
}
