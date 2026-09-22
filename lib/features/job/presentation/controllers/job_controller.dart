import 'package:flutter/foundation.dart';
import 'package:aplicativo_jobfy/domain/entities/job_entity.dart';
import 'package:aplicativo_jobfy/domain/usecases/job_usecase.dart';

enum JobStatus { idle, loading, loaded, error }

class JobController extends ChangeNotifier {
  static const tiposFiltro = ['Todas', 'Remoto', 'Híbrido', 'Presencial'];

  final JobUsecase _jobUsecase;

  JobController(this._jobUsecase);

  JobStatus _status = JobStatus.idle;
  List<JobEntity> _jobs = [];
  String _busca = '';
  String _tipoSelecionado = tiposFiltro.first;

  // Vagas salvas: estado local otimista, persistido via [JobUsecase]
  // (mock por enquanto — chamadas reais comentadas em JobRepositoryImpl).
  final Set<String> _salvas = {};
  final Set<String> _candidaturas = {};
  final Set<String> _enviando = {};

  JobStatus get status => _status;
  bool get isLoading => _status == JobStatus.loading;
  String get tipoSelecionado => _tipoSelecionado;

  /// A filtragem é local, sobre a lista já carregada. Se o backend passar a
  /// paginar, mover `busca` e `tipo` para o usecase.
  List<JobEntity> get jobsFiltradas {
    final termo = _busca.trim().toLowerCase();
    return _jobs.where((j) {
      final passaTipo =
          _tipoSelecionado == tiposFiltro.first || j.tipo == _tipoSelecionado;
      final passaBusca = termo.isEmpty ||
          j.titulo.toLowerCase().contains(termo) ||
          j.empresa.toLowerCase().contains(termo) ||
          j.local.toLowerCase().contains(termo);
      return passaTipo && passaBusca;
    }).toList();
  }

  bool estaSalva(String jobId) => _salvas.contains(jobId);
  bool jaCandidatou(String jobId) => _candidaturas.contains(jobId);
  bool estaEnviando(String jobId) => _enviando.contains(jobId);

  /// Com [refresh] a lista atual continua na tela (o RefreshIndicator já
  /// mostra o progresso), sem trocar por um spinner.
  Future<void> loadJobs({bool refresh = false}) async {
    if (!refresh) {
      _status = JobStatus.loading;
      notifyListeners();
    }

    try {
      _jobs = await _jobUsecase.getJobs();
      _status = JobStatus.loaded;
    } catch (_) {
      _status = JobStatus.error;
    }
    notifyListeners();
  }

  void setBusca(String valor) {
    _busca = valor;
    notifyListeners();
  }

  void selecionarTipo(String tipo) {
    _tipoSelecionado = tipo;
    notifyListeners();
  }

  /// Otimista: alterna localmente e persiste em segundo plano. Se a chamada
  /// falhar, desfaz o toggle.
  void toggleSalva(String jobId) {
    final salvando = !_salvas.remove(jobId);
    if (salvando) _salvas.add(jobId);
    notifyListeners();

    final acao = salvando
        ? _jobUsecase.salvarVaga(jobId)
        : _jobUsecase.removerVagaSalva(jobId);

    acao.catchError((_) {
      if (salvando) {
        _salvas.remove(jobId);
      } else {
        _salvas.add(jobId);
      }
      notifyListeners();
    });
  }

  /// Retorna `true` se a candidatura foi enviada.
  Future<bool> candidatar(String jobId) async {
    if (_candidaturas.contains(jobId) || _enviando.contains(jobId)) {
      return false;
    }

    _enviando.add(jobId);
    notifyListeners();

    try {
      await _jobUsecase.candidatar(jobId);
      _candidaturas.add(jobId);
      return true;
    } catch (_) {
      return false;
    } finally {
      _enviando.remove(jobId);
      notifyListeners();
    }
  }
}
