import 'package:security_access/domain/entities/motivo_rechazo.dart';

class AccesoRechazado {
  const AccesoRechazado({
    required this.id,
    required this.codigoQr,
    required this.guardiaId,
    required this.fecha,
    required this.motivo,
    this.viviendaId,
    this.viviendaNumero,
    this.invitacionId,
    this.descripcion,
  });

  final String id;
  final String codigoQr;
  final String guardiaId;
  final DateTime fecha;
  final MotivoRechazo motivo;
  final String? viviendaId;
  final String? viviendaNumero;
  final String? invitacionId;
  final String? descripcion;
}
