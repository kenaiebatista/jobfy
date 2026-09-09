import 'package:aplicativo_jobfy/features/company/domain/entities/empresa_entity.dart';
import 'package:aplicativo_jobfy/features/company/domain/repositories/empresa_repository.dart';

class FiltrarCandidatosUsecase {
  final EmpresaRepository _repository;

  FiltrarCandidatosUsecase(this._repository);

  Future<List<CandidatoEntity>> call(
    String vagaId, {
    String? filtroCargo,
    int? matchMinimo,
  }) {
    return _repository.filtrarCandidatos(
      vagaId,
      filtroCargo: filtroCargo,
      matchMinimo: matchMinimo,
    );
  }
}
