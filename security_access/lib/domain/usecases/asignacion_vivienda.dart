import 'package:security_access/domain/entities/estado_vivienda.dart';
import 'package:security_access/domain/entities/vivienda.dart';
import 'package:security_access/domain/repositories/vivienda_repository.dart';

class AsignacionVivienda {
  const AsignacionVivienda(this._repositorio);

  final ViviendaRepository _repositorio;

  Future<Vivienda?> buscarDisponible(
    String viviendaId, {
    String? residenteActualId,
  }) async {
    final vivienda = await _repositorio.buscarPorId(viviendaId);
    if (vivienda == null || vivienda.estado == EstadoVivienda.inactiva) {
      return null;
    }
    final ocupadaPorOtro =
        vivienda.residenteId != null &&
        vivienda.residenteId != residenteActualId;
    if (ocupadaPorOtro) {
      return null;
    }
    return vivienda;
  }

  Future<Vivienda> asignar({
    required Vivienda vivienda,
    required String residenteId,
    required String residenteNombre,
  }) async {
    final actualizada = vivienda.copyWith(
      estado: EstadoVivienda.asignada,
      residenteId: residenteId,
      residenteNombre: residenteNombre,
      limpiarResidente: true,
    );
    await _repositorio.guardar(actualizada);
    return actualizada;
  }

  Future<void> liberar(String? viviendaId) async {
    if (viviendaId == null) {
      return;
    }
    final vivienda = await _repositorio.buscarPorId(viviendaId);
    if (vivienda == null) {
      return;
    }
    final estado = vivienda.estado == EstadoVivienda.inactiva
        ? EstadoVivienda.inactiva
        : EstadoVivienda.disponible;
    await _repositorio.guardar(
      vivienda.copyWith(estado: estado, limpiarResidente: true),
    );
  }
}
