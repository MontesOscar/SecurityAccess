import 'package:security_access/domain/entities/estado_invitacion.dart';
import 'package:security_access/domain/entities/estado_visita.dart';

class Invitacion {
  const Invitacion({
    required this.id,
    required this.viviendaId,
    required this.viviendaNumero,
    required this.residenteId,
    required this.nombreVisitante,
    required this.entrada,
    required this.salida,
    required this.codigoQr,
    required this.estado,
    required this.estadoVisita,
  });

  final String id;
  final String viviendaId;
  final String viviendaNumero;
  final String residenteId;
  final String nombreVisitante;
  final DateTime entrada;
  final DateTime salida;
  final String codigoQr;
  final EstadoInvitacion estado;
  final EstadoVisita estadoVisita;

  bool get puedeCancelarse =>
      estado == EstadoInvitacion.activa &&
      estadoVisita == EstadoVisita.sinEntrada;

  Invitacion vigenteEn(DateTime momento) {
    final vencio =
        estado == EstadoInvitacion.activa &&
        estadoVisita == EstadoVisita.sinEntrada &&
        !salida.isAfter(momento);
    if (!vencio) {
      return this;
    }
    return copyWith(estado: EstadoInvitacion.vencida);
  }

  Invitacion copyWith({EstadoInvitacion? estado, EstadoVisita? estadoVisita}) {
    return Invitacion(
      id: id,
      viviendaId: viviendaId,
      viviendaNumero: viviendaNumero,
      residenteId: residenteId,
      nombreVisitante: nombreVisitante,
      entrada: entrada,
      salida: salida,
      codigoQr: codigoQr,
      estado: estado ?? this.estado,
      estadoVisita: estadoVisita ?? this.estadoVisita,
    );
  }
}
