import 'package:flutter/foundation.dart';
import 'package:aplicativo_jobfy/domain/entities/empresa_entity.dart';
import 'package:aplicativo_jobfy/domain/usecases/empresa_usecase.dart';

enum EmpresaStatus { idle, loading, loaded, error }

class EmpresaController extends ChangeNotifier {
  final EmpresaUsecase _empresaUsecase;

  EmpresaController(this._empresaUsecase);

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
      _empresa = await _empresaUsecase.cadastrarEmpresa(dados);
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
      final vagaCriada = await _empresaUsecase.publicarVaga(vaga);
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
      _candidatos = await _empresaUsecase.filtrarCandidatos(
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
      await _empresaUsecase.avaliarUsuario(candidatoId, nota, comentario: comentario);
    } catch (e) {
      _erro = 'Não foi possível registrar a avaliação.';
    }
    notifyListeners();
  }

  /// mandarMensagem()
  Future<void> mandarMensagem(String candidatoId, String mensagem) async {
    try {
      await _empresaUsecase.mandarMensagem(candidatoId, mensagem);
    } catch (e) {
      _erro = 'Não foi possível enviar a mensagem.';
    }
    notifyListeners();
  }
}
