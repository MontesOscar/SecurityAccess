import 'package:security_access/domain/entities/fila_reporte_acceso.dart';
import 'package:security_access/domain/repositories/auth_repository.dart';
import 'package:security_access/domain/repositories/invitacion_repository.dart';

class ConsultarReporteAccesos {
  const ConsultarReporteAccesos(this._invitaciones, this._usuarios);

  final InvitacionRepository _invitaciones;
  final AuthRepository _usuarios;

  static const estadoRechazado = 'Rechazado';

  Future<List<FilaReporteAcceso>> call({
    DateTime? desde,
    DateTime? hasta,
    String vivienda = '',
    String? estado,
  }) async {
    final usuarios = await _usuarios.listar();
    final nombres = {
      for (final usuario in usuarios) usuario.id: usuario.nombre,
    };
    final textoVivienda = vivienda.trim().toLowerCase();
    final filas = <FilaReporteAcceso>[];

    for (final visita in await _invitaciones.listarVisitas()) {
      final momento = visita.entrada ?? visita.fecha;
      if (!_enRango(momento, desde, hasta)) {
        continue;
      }
      if (!_coincideVivienda(visita.viviendaNumero, textoVivienda)) {
        continue;
      }
      final etiqueta = visita.estado.etiqueta;
      if (estado != null && estado != etiqueta) {
        continue;
      }
      final identificacion = [
        visita.tipoIdentificacion,
        visita.numeroIdentificacion,
      ].whereType<String>().where((parte) => parte.isNotEmpty).join(' ');
      filas.add(
        FilaReporteAcceso(
          id: visita.id,
          visitante: visita.nombreVisitante,
          viviendaNumero: visita.viviendaNumero,
          momento: momento,
          entrada: visita.entrada,
          salida: visita.salida,
          guardia: nombres[visita.guardiaId] ?? '',
          identificacion: identificacion,
          estado: etiqueta,
          sinSalida: visita.salida == null,
        ),
      );
    }

    for (final rechazo in await _invitaciones.listarRechazos()) {
      if (!_enRango(rechazo.fecha, desde, hasta)) {
        continue;
      }
      if (!_coincideVivienda(rechazo.viviendaNumero ?? '', textoVivienda)) {
        continue;
      }
      if (estado != null && estado != estadoRechazado) {
        continue;
      }
      filas.add(
        FilaReporteAcceso(
          id: rechazo.id,
          visitante: rechazo.nombreVisitante ?? 'Visitante',
          viviendaNumero: rechazo.viviendaNumero ?? '',
          momento: rechazo.fecha,
          guardia: nombres[rechazo.guardiaId] ?? '',
          identificacion: '',
          estado: estadoRechazado,
          sinSalida: false,
        ),
      );
    }

    filas.sort((a, b) => b.momento.compareTo(a.momento));
    return filas;
  }

  bool _enRango(DateTime momento, DateTime? desde, DateTime? hasta) {
    final dia = DateTime(momento.year, momento.month, momento.day);
    if (desde != null &&
        dia.isBefore(DateTime(desde.year, desde.month, desde.day))) {
      return false;
    }
    if (hasta != null &&
        dia.isAfter(DateTime(hasta.year, hasta.month, hasta.day))) {
      return false;
    }
    return true;
  }

  bool _coincideVivienda(String numero, String consulta) {
    if (consulta.isEmpty) {
      return true;
    }
    return numero.toLowerCase().contains(consulta);
  }
}
