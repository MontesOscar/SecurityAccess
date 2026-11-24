import 'package:security_access/domain/entities/estado_visita.dart';

class Visita {
  const Visita({
    required this.id,
    required this.viviendaId,
    required this.residenteId,
    required this.nombreVisitante,
    required this.fecha,
    required this.estado,
    this.viviendaNumero = '',
    this.entrada,
    this.salida,
    this.guardiaId,
    this.tipoIdentificacion,
    this.numeroIdentificacion,
    this.invitacionId,
    this.guardiaSalidaId,
    this.motivoSalida,
  });

  final String id;
  final String viviendaId;
  final String residenteId;
  final String nombreVisitante;
  final String viviendaNumero;
  final DateTime fecha;
  final DateTime? entrada;
  final DateTime? salida;
  final EstadoVisita estado;
  final String? guardiaId;
  final String? tipoIdentificacion;
  final String? numeroIdentificacion;
  final String? invitacionId;
  final String? guardiaSalidaId;
  final String? motivoSalida;

  bool get estaDentro => estado == EstadoVisita.dentro && salida == null;

  Visita copyWith({
    DateTime? salida,
    EstadoVisita? estado,
    String? guardiaSalidaId,
    String? motivoSalida,
  }) {
    return Visita(
      id: id,
      viviendaId: viviendaId,
      residenteId: residenteId,
      nombreVisitante: nombreVisitante,
      viviendaNumero: viviendaNumero,
      fecha: fecha,
      entrada: entrada,
      salida: salida ?? this.salida,
      estado: estado ?? this.estado,
      guardiaId: guardiaId,
      tipoIdentificacion: tipoIdentificacion,
      numeroIdentificacion: numeroIdentificacion,
      invitacionId: invitacionId,
      guardiaSalidaId: guardiaSalidaId ?? this.guardiaSalidaId,
      motivoSalida: motivoSalida ?? this.motivoSalida,
    );
  }
}
