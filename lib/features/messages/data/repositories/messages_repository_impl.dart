import '../../domain/entities/conversation_entity.dart';
import '../../domain/repositories/messages_repository.dart';
import '../models/conversation_model.dart';

class MessagesRepositoryImpl implements MessagesRepository {
  final List<ConversationModel> _conversas = [
    const ConversationModel(
      id: 'conv_001',
      nome: 'Nubank · Recrutamento',
      subtitulo: 'Flutter Developer Senior',
      online: true,
      naoLidas: 2,
      mensagens: [
        MessageEntity(
          id: 'm1',
          texto:
              'Olá! Vimos seu perfil e gostaríamos de conversar sobre a vaga de Flutter Developer Senior.',
          hora: '09:12',
          deUsuario: false,
        ),
        MessageEntity(
          id: 'm2',
          texto: 'Oi! Fico muito feliz com o contato, pode falar 🙂',
          hora: '09:15',
          deUsuario: true,
        ),
        MessageEntity(
          id: 'm3',
          texto:
              'Ótimo! Você teria disponibilidade para uma entrevista essa semana?',
          hora: '09:16',
          deUsuario: false,
        ),
        MessageEntity(
          id: 'm4',
          texto: 'Sim, tenho disponibilidade na quinta ou sexta à tarde.',
          hora: '09:20',
          deUsuario: false,
        ),
      ],
    ),
    const ConversationModel(
      id: 'conv_002',
      nome: 'iFood · RH',
      subtitulo: 'Mobile Engineer',
      online: false,
      naoLidas: 0,
      mensagens: [
        MessageEntity(
          id: 'm1',
          texto: 'Boa tarde! Recebemos sua candidatura para Mobile Engineer.',
          hora: 'ontem',
          deUsuario: false,
        ),
        MessageEntity(
          id: 'm2',
          texto: 'Boa tarde! Obrigado pelo retorno.',
          hora: 'ontem',
          deUsuario: true,
        ),
        MessageEntity(
          id: 'm3',
          texto: 'Em breve entramos em contato com os próximos passos.',
          hora: 'ontem',
          deUsuario: false,
        ),
      ],
    ),
    const ConversationModel(
      id: 'conv_003',
      nome: 'PicPay · Talent Acquisition',
      subtitulo: 'Dart/Flutter Developer',
      online: true,
      naoLidas: 0,
      mensagens: [
        MessageEntity(
          id: 'm1',
          texto: 'Seu perfil teve 85% de match com a vaga remota. Podemos conversar?',
          hora: 'há 2 dias',
          deUsuario: false,
        ),
      ],
    ),
    const ConversationModel(
      id: 'conv_004',
      nome: 'Ana Beatriz · Mentoria',
      subtitulo: 'Preparação para entrevista',
      online: false,
      naoLidas: 1,
      mensagens: [
        MessageEntity(
          id: 'm1',
          texto: 'Consegui revisar seu currículo, ficou muito bom!',
          hora: 'há 3 dias',
          deUsuario: false,
        ),
        MessageEntity(
          id: 'm2',
          texto: 'Muito obrigado pela ajuda! 🙏',
          hora: 'há 3 dias',
          deUsuario: true,
        ),
      ],
    ),
  ];

  @override
  Future<List<ConversationEntity>> getConversations(String userId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return List.unmodifiable(_conversas);
  }

  @override
  Future<MessageEntity> sendMessage({
    required String conversationId,
    required String texto,
  }) async {
    await Future.delayed(const Duration(milliseconds: 250));

    final index = _conversas.indexWhere((c) => c.id == conversationId);
    if (index == -1) {
      throw ArgumentError('Conversa não encontrada: $conversationId');
    }

    final novaMensagem = MessageEntity(
      id: 'm${DateTime.now().microsecondsSinceEpoch}',
      texto: texto,
      hora: 'agora',
      deUsuario: true,
    );

    final atual = _conversas[index];
    _conversas[index] = ConversationModel(
      id: atual.id,
      nome: atual.nome,
      subtitulo: atual.subtitulo,
      online: atual.online,
      naoLidas: 0,
      mensagens: [...atual.mensagens, novaMensagem],
    );

    return novaMensagem;
  }
}
