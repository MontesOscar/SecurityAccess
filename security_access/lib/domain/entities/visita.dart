import 'package:security_access/domain/entities/estado_visita.dart';

class Visita {
  const Visita({
    required this.id,
    required this.viviendaId,
    required this.residenteId,
    required this.nombreVisitante,
    required this.fecha,
    required this.estado,
    this.invitacionId,
    this.viviendaNumero,
    this.entrada,
    this.salida,
    this.guardiaId,
    this.tipoIdentificacion,
    this.numeroIdentificacion,
    this.guardiaSalidaId,
    this.motivoSalidaManual,
  });

  final String id;
  final String viviendaId;
  final String residenteId;
  final String nombreVisitante;
  final DateTime fecha;
  final String? invitacionId;
  final String? viviendaNumero;
  final DateTime? entrada;
  final DateTime? salida;
  final EstadoVisita estado;
  final String? guardiaId;
  final String? tipoIdentificacion;
  final String? numeroIdentificacion;
  final String? guardiaSalidaId;
  final String? motivoSalidaManual;

  bool get estaDentro =>
      estado == EstadoVisita.dentro && entrada != null && salida == null;

  Visita copyWith({
    DateTime? salida,
    EstadoVisita? estado,
    String? guardiaSalidaId,
    String? motivoSalidaManual,
  }) {
    return Visita(
      id: id,
      viviendaId: viviendaId,
      residenteId: residenteId,
      nombreVisitante: nombreVisitante,
      fecha: fecha,
      estado: estado ?? this.estado,
      invitacionId: invitacionId,
      viviendaNumero: viviendaNumero,
      entrada: entrada,
      salida: salida ?? this.salida,
      guardiaId: guardiaId,
      tipoIdentificacion: tipoIdentificacion,
      numeroIdentificacion: numeroIdentificacion,
      guardiaSalidaId: guardiaSalidaId ?? this.guardiaSalidaId,
      motivoSalidaManual: motivoSalidaManual ?? this.motivoSalidaManual,
    );
  }
}
