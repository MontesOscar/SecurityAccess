import 'package:security_access/domain/entities/estado_vivienda.dart';
import 'package:security_access/domain/repositories/vivienda_repository.dart';
import 'package:security_access/domain/usecases/resultado_cambio_estado_vivienda.dart';

class CambiarEstadoVivienda {
  const CambiarEstadoVivienda(this._repositorio);

  final ViviendaRepository _repositorio;

  Future<ResultadoCambioEstadoVivienda> call({
    required String id,
    required bool activar,
  }) async {
    final actual = await _repositorio.buscarPorId(id);
    if (actual == null) {
      return const ViviendaEstadoNoEncontrada();
    }

    final estado = activar
        ? actual.tieneResidente
              ? EstadoVivienda.asignada
              : EstadoVivienda.disponible
        : EstadoVivienda.inactiva;

    final actualizada = actual.copyWith(estado: estado);
    await _repositorio.guardar(actualizada);
    return EstadoViviendaActualizado(actualizada);
  }
}
