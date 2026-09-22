import 'package:aplicativo_jobfy/core/theme/app_breakpoints.dart';
import 'package:aplicativo_jobfy/core/theme/app_colors.dart';
import 'package:aplicativo_jobfy/features/messages/data/repositories/messages_repository_impl.dart';
import 'package:aplicativo_jobfy/features/messages/domain/entities/conversation_entity.dart';
import 'package:aplicativo_jobfy/features/messages/domain/usecases/get_conversations_usecase.dart';
import 'package:aplicativo_jobfy/features/messages/domain/usecases/send_message_usecase.dart';
import 'package:aplicativo_jobfy/features/messages/presentation/controllers/messages_controller.dart';
import 'package:aplicativo_jobfy/features/user/data/repositories/user_repository_impl.dart';
import 'package:aplicativo_jobfy/features/user/domain/entities/user_profile_entity.dart';
import 'package:aplicativo_jobfy/features/user/domain/usecases/get_user_profile_usecase.dart';
import 'package:aplicativo_jobfy/features/user/presentation/widgets/profile_sidebar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Messages screen. Follows the same shell used by the dashboard and by
/// Settings: a dark ProfileSidebar for navigation and a light content area
/// made of rounded white cards.
///
/// Below [AppBreakpoints.mobile] the fixed sidebar becomes a Drawer opened
/// from a menu button in the top bar, and the conversation list / thread
/// split collapses into a single pane: the list is shown first, and
/// selecting a conversation shows the thread full-width with a back button.
class MessagesPage extends StatefulWidget {
  const MessagesPage({super.key});

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  late final MessagesController _controller;
  late final GetUserProfileUsecase _getProfileUsecase;
  UserProfileEntity? _profile;

  final _mensagemCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    final messagesRepository = MessagesRepositoryImpl();
    _controller = MessagesController(
      GetConversationsUsecase(messagesRepository),
      SendMessageUsecase(messagesRepository),
    );
    _controller.loadConversations('usr_001');

    _getProfileUsecase = GetUserProfileUsecase(UserRepositoryImpl());
    _getProfileUsecase('usr_001').then((profile) {
      if (!mounted) return;
      setState(() => _profile = profile);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _mensagemCtrl.dispose();
    super.dispose();
  }

  void _handleNav(BuildContext context, int index, bool isMobile) {
    if (isMobile) {
      Navigator.pop(context);
    }
    if (index == 0) {
      context.go('/user');
    } else if (index == 4) {
      context.go('/settings');
    }
    // Vagas e Currículo ainda não têm tela própria.
    // index 3 (Mensagens) já é a página atual.
  }

  Future<void> _enviarMensagem() async {
    final texto = _mensagemCtrl.text;
    if (texto.trim().isEmpty) return;
    _mensagemCtrl.clear();
    await _controller.enviarMensagem(texto);
  }

  @override
  Widget build(BuildContext context) {
    final profile = _profile;

    if (profile == null) {
      return const Scaffold(
        backgroundColor: AppColors.backgroundLight,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.accent),
        ),
      );
    }

    final isMobile = MediaQuery.sizeOf(context).width < AppBreakpoints.mobile;

    final sidebar = ProfileSidebar(
      profile: profile,
      selectedIndex: 3,
      onNavTap: (i) => _handleNav(context, i, isMobile),
    );

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      drawer: isMobile ? Drawer(child: sidebar) : null,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isMobile) sidebar,
          Expanded(
            child: ListenableBuilder(
              listenable: _controller,
              builder: (context, _) {
                return _MessagesContent(
                  controller: _controller,
                  isMobile: isMobile,
                  mensagemCtrl: _mensagemCtrl,
                  onEnviar: _enviarMensagem,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _MessagesContent extends StatelessWidget {
  final MessagesController controller;
  final bool isMobile;
  final TextEditingController mensagemCtrl;
  final VoidCallback onEnviar;

  const _MessagesContent({
    required this.controller,
    required this.isMobile,
    required this.mensagemCtrl,
    required this.onEnviar,
  });

  @override
  Widget build(BuildContext context) {
    final selecionada = controller.conversaSelecionada;
    final mostrarThreadEmMobile = isMobile && selecionada != null;

    return Column(
      children: [
        _MessagesTopBar(
          totalNaoLidas: controller.totalNaoLidas,
          isMobile: isMobile,
        ),
        Expanded(
          child: controller.isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.accent),
                )
              : isMobile
                  ? (mostrarThreadEmMobile
                      ? _ThreadPane(
                          conversa: selecionada,
                          isMobile: isMobile,
                          mensagemCtrl: mensagemCtrl,
                          isSending: controller.isSending,
                          onEnviar: onEnviar,
                          onVoltar: controller.fecharConversa,
                        )
                      : _ConversationListPane(
                          controller: controller,
                          isMobile: isMobile,
                        ))
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(
                          width: 320,
                          child: _ConversationListPane(
                            controller: controller,
                            isMobile: isMobile,
                          ),
                        ),
                        const VerticalDivider(
                          width: 1,
                          color: AppColors.cardBorder,
                        ),
                        Expanded(
                          child: selecionada == null
                              ? const _EmptyThreadState()
                              : _ThreadPane(
                                  conversa: selecionada,
                                  isMobile: isMobile,
                                  mensagemCtrl: mensagemCtrl,
                                  isSending: controller.isSending,
                                  onEnviar: onEnviar,
                                  onVoltar: null,
                                ),
                        ),
                      ],
                    ),
        ),
      ],
    );
  }
}

class _MessagesTopBar extends StatelessWidget {
  final int totalNaoLidas;
  final bool isMobile;

  const _MessagesTopBar({required this.totalNaoLidas, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 28,
        vertical: 14,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.cardBorder)),
      ),
      child: Row(
        children: [
          if (isMobile)
            Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.menu),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
            )
          else
            const Icon(Icons.lightbulb_circle, size: 28),
          const SizedBox(width: 10),
          const Text(
            'Jobfy',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const Spacer(),
          if (totalNaoLidas > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
              ),
              child: Text(
                '$totalNaoLidas não lida${totalNaoLidas == 1 ? '' : 's'}',
                style: const TextStyle(
                  color: AppColors.accent,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ConversationListPane extends StatelessWidget {
  final MessagesController controller;
  final bool isMobile;

  const _ConversationListPane({required this.controller, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    final conversas = controller.conversas;

    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Mensagens',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
                const SizedBox(height: 12),
                TextField(
                  onChanged: controller.setBusca,
                  decoration: InputDecoration(
                    hintText: 'Buscar conversas...',
                    hintStyle: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textMuted,
                    ),
                    prefixIcon: const Icon(Icons.search, size: 18),
                    isDense: true,
                    filled: true,
                    fillColor: AppColors.backgroundLight,
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.cardBorder),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.cardBorder),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.cardBorder),
          Expanded(
            child: conversas.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        'Nenhuma conversa encontrada.',
                        style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                      ),
                    ),
                  )
                : ListView.separated(
                    itemCount: conversas.length,
                    separatorBuilder: (_, __) =>
                        const Divider(height: 1, color: AppColors.cardBorder),
                    itemBuilder: (context, i) {
                      final conversa = conversas[i];
                      final isSelected = controller.selectedId == conversa.id;
                      return _ConversationTile(
                        conversa: conversa,
                        isSelected: isSelected,
                        onTap: () => controller.selecionarConversa(conversa.id),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _ConversationTile extends StatelessWidget {
  final ConversationEntity conversa;
  final bool isSelected;
  final VoidCallback onTap;

  const _ConversationTile({
    required this.conversa,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final ultima = conversa.ultimaMensagem;
    final initials = conversa.nome.trim().isNotEmpty
        ? conversa.nome.trim().split(' ').take(2).map((w) => w[0]).join()
        : '?';

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        color: isSelected ? AppColors.accent.withValues(alpha: 0.06) : null,
        child: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: AppColors.accent,
                  child: Text(
                    initials.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
                if (conversa.online)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          conversa.nome,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13.5,
                          ),
                        ),
                      ),
                      if (ultima != null)
                        Text(
                          ultima.hora,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textMuted,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    conversa.subtitulo,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          ultima?.texto ?? 'Sem mensagens ainda.',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12.5,
                            color: conversa.naoLidas > 0
                                ? Colors.black87
                                : AppColors.textMuted,
                            fontWeight: conversa.naoLidas > 0
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                      if (conversa.naoLidas > 0) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.accent,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${conversa.naoLidas}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
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

class _EmptyThreadState extends StatelessWidget {
  const _EmptyThreadState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.chat_bubble_outline, size: 48, color: AppColors.textMuted),
          SizedBox(height: 12),
          Text(
            'Selecione uma conversa',
            style: TextStyle(color: AppColors.textMuted, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _ThreadPane extends StatelessWidget {
  final ConversationEntity conversa;
  final bool isMobile;
  final TextEditingController mensagemCtrl;
  final bool isSending;
  final VoidCallback onEnviar;
  final VoidCallback? onVoltar;

  const _ThreadPane({
    required this.conversa,
    required this.isMobile,
    required this.mensagemCtrl,
    required this.isSending,
    required this.onEnviar,
    required this.onVoltar,
  });

  @override
  Widget build(BuildContext context) {
    final initials = conversa.nome.trim().isNotEmpty
        ? conversa.nome.trim().split(' ').take(2).map((w) => w[0]).join()
        : '?';

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: AppColors.cardBorder)),
          ),
          child: Row(
            children: [
              if (onVoltar != null)
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: onVoltar,
                ),
              if (onVoltar != null) const SizedBox(width: 8),
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.accent,
                child: Text(
                  initials.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      conversa.nome,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                    Text(
                      conversa.online ? 'Online' : conversa.subtitulo,
                      style: TextStyle(
                        fontSize: 11.5,
                        color: conversa.online
                            ? AppColors.success
                            : AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Container(
            color: AppColors.backgroundLight,
            child: ListView.builder(
              reverse: true,
              padding: const EdgeInsets.all(16),
              itemCount: conversa.mensagens.length,
              itemBuilder: (context, i) {
                final mensagem =
                    conversa.mensagens[conversa.mensagens.length - 1 - i];
                return _MessageBubble(mensagem: mensagem);
              },
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.fromLTRB(
            isMobile ? 12 : 16,
            10,
            isMobile ? 12 : 16,
            10,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: AppColors.cardBorder)),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: mensagemCtrl,
                  minLines: 1,
                  maxLines: 4,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => onEnviar(),
                  decoration: InputDecoration(
                    hintText: 'Escreva uma mensagem...',
                    hintStyle: const TextStyle(fontSize: 13, color: AppColors.textMuted),
                    isDense: true,
                    filled: true,
                    fillColor: AppColors.backgroundLight,
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: const BorderSide(color: AppColors.cardBorder),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: const BorderSide(color: AppColors.cardBorder),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 44,
                height: 44,
                child: IconButton(
                  onPressed: isSending ? null : onEnviar,
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.white,
                    shape: const CircleBorder(),
                  ),
                  icon: isSending
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.send, size: 18),
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
  final MessageEntity mensagem;

  const _MessageBubble({required this.mensagem});

  @override
  Widget build(BuildContext context) {
    final isUsuario = mensagem.deUsuario;

    return Align(
      alignment: isUsuario ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: const BoxConstraints(maxWidth: 360),
        decoration: BoxDecoration(
          color: isUsuario ? AppColors.accent : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(14),
            topRight: const Radius.circular(14),
            bottomLeft: Radius.circular(isUsuario ? 14 : 2),
            bottomRight: Radius.circular(isUsuario ? 2 : 14),
          ),
          border: isUsuario ? null : Border.all(color: AppColors.cardBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              mensagem.texto,
              style: TextStyle(
                color: isUsuario ? Colors.white : Colors.black87,
                fontSize: 13.5,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              mensagem.hora,
              style: TextStyle(
                color: isUsuario
                    ? Colors.white.withValues(alpha: 0.7)
                    : AppColors.textMuted,
                fontSize: 10.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
