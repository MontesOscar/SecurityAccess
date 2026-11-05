import 'package:security_access/domain/entities/estado_invitacion.dart';
import 'package:security_access/domain/entities/invitacion.dart';
import 'package:security_access/domain/entities/usuario.dart';
import 'package:security_access/domain/repositories/invitacion_repository.dart';

class ConsultarInvitaciones {
  ConsultarInvitaciones(this._repositorio, {DateTime Function()? ahora})
    : _ahora = ahora ?? DateTime.now;

  final InvitacionRepository _repositorio;
  final DateTime Function() _ahora;

  Future<List<Invitacion>> call({
    required Usuario residente,
    EstadoInvitacion? estado,
    DateTime? desde,
    DateTime? hasta,
  }) async {
    final viviendaId = residente.viviendaId;
    if (viviendaId == null) {
      return const [];
    }
    final momento = _ahora();
    final propias = <Invitacion>[];
    for (final invitacion in await _repositorio.listar()) {
      if (invitacion.viviendaId != viviendaId ||
          invitacion.residenteId != residente.id) {
        continue;
      }
      final vigente = invitacion.vigenteEn(momento);
      if (vigente.estado != invitacion.estado) {
        await _repositorio.guardar(vigente);
      }
      propias.add(vigente);
    }
    final filtradas = propias.where((invitacion) {
      if (estado != null && invitacion.estado != estado) {
        return false;
      }
      final dia = DateTime(
        invitacion.entrada.year,
        invitacion.entrada.month,
        invitacion.entrada.day,
      );
      if (desde != null && dia.isBefore(_dia(desde))) {
        return false;
      }
      if (hasta != null && dia.isAfter(_dia(hasta))) {
        return false;
      }
      return true;
    }).toList();
    filtradas.sort((a, b) => b.entrada.compareTo(a.entrada));
    return filtradas;
  }

  DateTime _dia(DateTime momento) {
    return DateTime(momento.year, momento.month, momento.day);
  }
}
