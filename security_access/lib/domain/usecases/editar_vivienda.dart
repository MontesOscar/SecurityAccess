import 'package:security_access/domain/entities/estado_vivienda.dart';
import 'package:security_access/domain/repositories/vivienda_repository.dart';
import 'package:security_access/domain/usecases/resultado_editar_vivienda.dart';

class EditarVivienda {
  const EditarVivienda(this._repositorio);

  final ViviendaRepository _repositorio;

  Future<ResultadoEditarVivienda> call({
    required String id,
    required String direccion,
    String? residenteId,
    String? residenteNombre,
    required bool confirmarCambioResidente,
  }) async {
    final actual = await _repositorio.buscarPorId(id);
    if (actual == null) {
      return const ViviendaEdicionNoEncontrada();
    }

    final direccionLimpia = direccion.trim();
    if (direccionLimpia.isEmpty) {
      return const DatosEdicionInvalidos();
    }

    final nuevoResidenteId = _vacioANulo(residenteId);
    final nuevoResidenteNombre = _vacioANulo(residenteNombre);
    final cambiaResidente = actual.residenteId != nuevoResidenteId;
    if (cambiaResidente && !confirmarCambioResidente) {
      return const EdicionRequiereConfirmacion();
    }

    final estado = actual.estado == EstadoVivienda.inactiva
        ? EstadoVivienda.inactiva
        : nuevoResidenteId == null
        ? EstadoVivienda.disponible
        : EstadoVivienda.asignada;

    final actualizada = actual.copyWith(
      direccion: direccionLimpia,
      estado: estado,
      residenteId: nuevoResidenteId,
      residenteNombre: nuevoResidenteNombre,
      limpiarResidente: true,
    );
    await _repositorio.guardar(actualizada);
    return ViviendaActualizada(actualizada);
  }

  String? _vacioANulo(String? valor) {
    final limpio = valor?.trim();
    if (limpio == null || limpio.isEmpty) {
      return null;
    }
    return limpio;
  }
}
