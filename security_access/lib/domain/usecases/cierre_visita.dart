import 'package:security_access/domain/entities/estado_visita.dart';
import 'package:security_access/domain/entities/usuario.dart';
import 'package:security_access/domain/entities/visita.dart';
import 'package:security_access/domain/repositories/invitacion_repository.dart';

/// Cierra una visita que está "Dentro": guarda la hora de salida, el guardia
/// que la registró y, si es manual, el motivo. La visita y su invitación
/// pasan a "Completada".
class CierreVisita {
  const CierreVisita(this._repositorio);

  final InvitacionRepository _repositorio;

  Future<Visita?> buscarActiva(String visitaId) async {
    for (final visita in await _repositorio.listarVisitas()) {
      if (visita.id == visitaId) {
        return visita.estaDentro ? visita : null;
      }
    }
    return null;
  }

  Future<Visita> cerrar({
    required Visita visita,
    required Usuario guardia,
    required DateTime momento,
    String? motivoManual,
  }) async {
    final cerrada = visita.copyWith(
      salida: momento,
      estado: EstadoVisita.completada,
      guardiaSalidaId: guardia.id,
      motivoSalidaManual: motivoManual,
    );
    await _repositorio.guardarVisita(cerrada);
    final invitacionId = visita.invitacionId;
    if (invitacionId != null) {
      final invitacion = await _repositorio.buscarPorId(invitacionId);
      if (invitacion != null) {
        await _repositorio.guardar(
          invitacion.copyWith(estadoVisita: EstadoVisita.completada),
        );
      }
    }
    return cerrada;
  }
}
