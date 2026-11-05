import 'package:security_access/domain/entities/estado_visita.dart';

class Visita {
  const Visita({
    required this.id,
    required this.viviendaId,
    required this.residenteId,
    required this.nombreVisitante,
    required this.fecha,
    required this.estado,
    this.entrada,
    this.salida,
  });

  final String id;
  final String viviendaId;
  final String residenteId;
  final String nombreVisitante;
  final DateTime fecha;
  final DateTime? entrada;
  final DateTime? salida;
  final EstadoVisita estado;
}
