import 'package:security_access/domain/entities/usuario.dart';
import 'package:security_access/domain/entities/visita.dart';
import 'package:security_access/domain/repositories/invitacion_repository.dart';

class ConsultarHistorialVisitas {
  const ConsultarHistorialVisitas(this._repositorio);

  final InvitacionRepository _repositorio;

  Future<List<Visita>> call({
    required Usuario residente,
    DateTime? desde,
    DateTime? hasta,
  }) async {
    final viviendaId = residente.viviendaId;
    if (viviendaId == null) {
      return const [];
    }
    final visitas = await _repositorio.listarVisitas();
    final propias = visitas.where((visita) {
      if (visita.viviendaId != viviendaId ||
          visita.residenteId != residente.id) {
        return false;
      }
      final dia = DateTime(
        visita.fecha.year,
        visita.fecha.month,
        visita.fecha.day,
      );
      if (desde != null &&
          dia.isBefore(DateTime(desde.year, desde.month, desde.day))) {
        return false;
      }
      if (hasta != null &&
          dia.isAfter(DateTime(hasta.year, hasta.month, hasta.day))) {
        return false;
      }
      return true;
    }).toList();
    propias.sort((a, b) => b.fecha.compareTo(a.fecha));
    return propias;
  }
}
