import 'package:security_access/domain/entities/estado_invitacion.dart';
import 'package:security_access/domain/entities/estado_visita.dart';
import 'package:security_access/domain/entities/estado_vivienda.dart';
import 'package:security_access/domain/entities/invitacion.dart';
import 'package:security_access/domain/entities/usuario.dart';
import 'package:security_access/domain/repositories/invitacion_repository.dart';
import 'package:security_access/domain/repositories/vivienda_repository.dart';
import 'package:security_access/domain/usecases/resultado_crear_invitacion.dart';

class CrearInvitacion {
  CrearInvitacion(
    this._invitaciones,
    this._viviendas, {
    DateTime Function()? ahora,
  }) : _ahora = ahora ?? DateTime.now;

  final InvitacionRepository _invitaciones;
  final ViviendaRepository _viviendas;
  final DateTime Function() _ahora;

  Future<ResultadoCrearInvitacion> call({
    required Usuario residente,
    required String nombreVisitante,
    required DateTime entrada,
    required DateTime salida,
  }) async {
    final nombre = nombreVisitante.trim();
    if (nombre.isEmpty) {
      return const VisitanteInvalido();
    }

    final viviendaId = residente.viviendaId;
    if (!residente.esResidente || viviendaId == null) {
      return const ViviendaNoActiva();
    }
    final vivienda = await _viviendas.buscarPorId(viviendaId);
    final asignadaAlResidente =
        vivienda != null &&
        vivienda.estado != EstadoVivienda.inactiva &&
        vivienda.residenteId == residente.id;
    if (!asignadaAlResidente) {
      return const ViviendaNoActiva();
    }

    final hoy = _inicioDelDia(_ahora());
    if (entrada.isBefore(hoy)) {
      return const EntradaAnterior();
    }
    if (!salida.isAfter(entrada)) {
      return const SalidaInvalida();
    }

    final id = await _invitaciones.reservarId();
    final codigo = await _invitaciones.reservarCodigo();
    final invitacion = Invitacion(
      id: id,
      viviendaId: vivienda.id,
      viviendaNumero: vivienda.numero,
      residenteId: residente.id,
      nombreVisitante: nombre,
      entrada: entrada,
      salida: salida,
      codigoQr: codigo,
      estado: EstadoInvitacion.activa,
      estadoVisita: EstadoVisita.sinEntrada,
    );
    await _invitaciones.guardar(invitacion);
    return InvitacionCreada(invitacion);
  }

  DateTime _inicioDelDia(DateTime momento) {
    return DateTime(momento.year, momento.month, momento.day);
  }
}
