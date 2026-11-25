import 'package:security_access/domain/entities/tipo_notificacion.dart';

class Notificacion {
  const Notificacion({
    required this.id,
    required this.residenteId,
    required this.viviendaId,
    required this.nombreVisitante,
    required this.fecha,
    required this.tipo,
    this.motivo,
  });

  final String id;
  final String residenteId;
  final String viviendaId;
  final String nombreVisitante;
  final DateTime fecha;
  final TipoNotificacion tipo;
  final String? motivo;

  String get texto {
    final hora = _hora(fecha);
    return switch (tipo) {
      TipoNotificacion.entrada => '$nombreVisitante entró a las $hora',
      TipoNotificacion.salida => '$nombreVisitante salió a las $hora',
      TipoNotificacion.rechazo =>
        'Se rechazó el acceso de $nombreVisitante. Motivo: ${motivo ?? ''}',
    };
  }

  static String _hora(DateTime valor) {
    final horas = valor.hour.toString().padLeft(2, '0');
    final minutos = valor.minute.toString().padLeft(2, '0');
    return '$horas:$minutos';
  }
}
