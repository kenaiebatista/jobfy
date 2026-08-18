import 'package:flutter/foundation.dart';
import 'package:aplicativo_jobfy/features/company/domain/entities/empresa_entity.dart';
import 'package:aplicativo_jobfy/features/company/domain/usecases/avaliar_usuario_usecase.dart';
import 'package:aplicativo_jobfy/features/company/domain/usecases/cadastrar_empresa_usecase.dart';
import 'package:aplicativo_jobfy/features/company/domain/usecases/filtrar_candidatos_usecase.dart';
import 'package:aplicativo_jobfy/features/company/domain/usecases/mandar_mensagem_usecase.dart';
import 'package:aplicativo_jobfy/features/company/domain/usecases/publicar_vaga_usecase.dart';

enum EmpresaStatus { idle, loading, loaded, error }

class EmpresaController extends ChangeNotifier {
  final CadastrarEmpresaUsecase _cadastrarEmpresaUsecase;
  final PublicarVagaUsecase _publicarVagaUsecase;
  final FiltrarCandidatosUsecase _filtrarCandidatosUsecase;
  final AvaliarUsuarioUsecase _avaliarUsuarioUsecase;
  final MandarMensagemUsecase _mandarMensagemUsecase;

  EmpresaController({
    required CadastrarEmpresaUsecase cadastrarEmpresaUsecase,
    required PublicarVagaUsecase publicarVagaUsecase,
    required FiltrarCandidatosUsecase filtrarCandidatosUsecase,
    required AvaliarUsuarioUsecase avaliarUsuarioUsecase,
    required MandarMensagemUsecase mandarMensagemUsecase,
  })  : _cadastrarEmpresaUsecase = cadastrarEmpresaUsecase,
        _publicarVagaUsecase = publicarVagaUsecase,
        _filtrarCandidatosUsecase = filtrarCandidatosUsecase,
        _avaliarUsuarioUsecase = avaliarUsuarioUsecase,
        _mandarMensagemUsecase = mandarMensagemUsecase;

  EmpresaStatus _status = EmpresaStatus.idle;
  EmpresaEntity? _empresa;
  final List<VagaEntity> _vagas = [];
  List<CandidatoEntity> _candidatos = [];
  String? _erro;

  EmpresaStatus get status => _status;
  EmpresaEntity? get empresa => _empresa;
  List<VagaEntity> get vagas => List.unmodifiable(_vagas);
  List<CandidatoEntity> get candidatos => List.unmodifiable(_candidatos);
  String? get erro => _erro;
  bool get isLoading => _status == EmpresaStatus.loading;

  /// cadastrarEmpresa()
  Future<void> cadastrarEmpresa(EmpresaEntity dados) async {
    _status = EmpresaStatus.loading;
    notifyListeners();
    try {
      _empresa = await _cadastrarEmpresaUsecase(dados);
      _status = EmpresaStatus.loaded;
    } catch (e) {
      _erro = 'Não foi possível cadastrar a empresa.';
      _status = EmpresaStatus.error;
    }
    notifyListeners();
  }

  /// publicarVaga()
  Future<void> publicarVaga(VagaEntity vaga) async {
    try {
      final vagaCriada = await _publicarVagaUsecase(vaga);
      _vagas.add(vagaCriada);
    } catch (e) {
      _erro = 'Não foi possível publicar a vaga.';
    }
    notifyListeners();
  }

  /// filtrarCandidatos()
  Future<void> filtrarCandidatos(
    String vagaId, {
    String? filtroCargo,
    int? matchMinimo,
  }) async {
    try {
      _candidatos = await _filtrarCandidatosUsecase(
        vagaId,
        filtroCargo: filtroCargo,
        matchMinimo: matchMinimo,
      );
    } catch (e) {
      _erro = 'Não foi possível filtrar os candidatos.';
    }
    notifyListeners();
  }

  /// avaliarUsuario()
  Future<void> avaliarUsuario(String candidatoId, double nota, {String? comentario}) async {
    try {
      await _avaliarUsuarioUsecase(candidatoId, nota, comentario: comentario);
    } catch (e) {
      _erro = 'Não foi possível registrar a avaliação.';
    }
    notifyListeners();
  }

  /// mandarMensagem()
  Future<void> mandarMensagem(String candidatoId, String mensagem) async {
    try {
      await _mandarMensagemUsecase(candidatoId, mensagem);
    } catch (e) {
      _erro = 'Não foi possível enviar a mensagem.';
    }
    notifyListeners();
  }
}
