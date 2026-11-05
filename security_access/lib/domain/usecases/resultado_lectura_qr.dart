import 'package:security_access/domain/entities/invitacion.dart';

enum ClasificacionQr { valida, invalida, vencida }

class ResultadoLecturaQr {
  const ResultadoLecturaQr({
    required this.clasificacion,
    required this.mensaje,
    required this.codigo,
    this.invitacion,
  });

  final ClasificacionQr clasificacion;
  final String mensaje;
  final String codigo;
  final Invitacion? invitacion;

  bool get esValida => clasificacion == ClasificacionQr.valida;

  String get etiqueta => switch (clasificacion) {
    ClasificacionQr.valida => 'Válida',
    ClasificacionQr.invalida => 'Inválida',
    ClasificacionQr.vencida => 'Vencida',
  };
}
