import 'package:security_access/domain/entities/acceso_rechazado.dart';
import 'package:security_access/domain/entities/notificacion.dart';
import 'package:security_access/domain/entities/tipo_notificacion.dart';
import 'package:security_access/domain/entities/visita.dart';
import 'package:security_access/domain/repositories/invitacion_repository.dart';
import 'package:security_access/domain/repositories/vivienda_repository.dart';

class NotificarEventoVisita {
  NotificarEventoVisita(this._invitaciones, this._viviendas);

  final InvitacionRepository _invitaciones;
  final ViviendaRepository _viviendas;

  Future<void> entrada(Visita visita) {
    return _guardar(
      viviendaId: visita.viviendaId,
      nombreVisitante: visita.nombreVisitante,
      fecha: visita.entrada ?? visita.fecha,
      tipo: TipoNotificacion.entrada,
    );
  }

  Future<void> salida(Visita visita) {
    return _guardar(
      viviendaId: visita.viviendaId,
      nombreVisitante: visita.nombreVisitante,
      fecha: visita.salida ?? visita.fecha,
      tipo: TipoNotificacion.salida,
    );
  }

  Future<void> rechazo({
    required AccesoRechazado rechazo,
    required String nombreVisitante,
  }) {
    final viviendaId = rechazo.viviendaId;
    if (viviendaId == null) {
      return Future.value();
    }
    final motivo = rechazo.descripcion ?? rechazo.motivo.etiqueta;
    return _guardar(
      viviendaId: viviendaId,
      nombreVisitante: nombreVisitante,
      fecha: rechazo.fecha,
      tipo: TipoNotificacion.rechazo,
      motivo: motivo,
    );
  }

  Future<void> _guardar({
    required String viviendaId,
    required String nombreVisitante,
    required DateTime fecha,
    required TipoNotificacion tipo,
    String? motivo,
  }) async {
    try {
      final vivienda = await _viviendas.buscarPorId(viviendaId);
      final residenteId = vivienda?.residenteId;
      if (residenteId == null || residenteId.isEmpty) {
        return;
      }
      final aviso = Notificacion(
        id: await _invitaciones.reservarIdNotificacion(),
        residenteId: residenteId,
        viviendaId: viviendaId,
        nombreVisitante: nombreVisitante,
        fecha: fecha,
        tipo: tipo,
        motivo: motivo,
      );
      await _invitaciones.guardarNotificacion(aviso);
    } catch (_) {
      // Un fallo al avisar no revierte el acceso ya registrado.
    }
  }
}
