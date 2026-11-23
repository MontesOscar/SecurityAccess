import 'package:security_access/domain/entities/rol_usuario.dart';
import 'package:security_access/domain/entities/usuario.dart';
import 'package:security_access/domain/usecases/cierre_visita.dart';
import 'package:security_access/domain/usecases/resultado_registrar_salida.dart';

/// Cierra sin QR una visita "Dentro". Guarda guardia, fecha, hora y motivo.
class RegistrarSalidaManual {
  RegistrarSalidaManual(this._cierre, {DateTime Function()? ahora})
    : _ahora = ahora ?? DateTime.now;

  final CierreVisita _cierre;
  final DateTime Function() _ahora;

  static const mensajeNoAutorizado =
      'Solo un guardia puede registrar la salida manual';
  static const mensajeMotivo = 'El motivo es obligatorio';
  static const mensajeNoActiva =
      'La visita no está dentro de la residencial o ya fue completada';

  Future<ResultadoRegistrarSalida> call({
    required Usuario guardia,
    required String visitaId,
    required String motivo,
  }) async {
    if (guardia.rol != RolUsuario.guardia || !guardia.estaActivo) {
      return const SalidaNoRegistrada(mensajeNoAutorizado);
    }
    final detalle = motivo.trim();
    if (detalle.isEmpty) {
      return const SalidaNoRegistrada(mensajeMotivo);
    }
    final visita = await _cierre.buscarActiva(visitaId);
    if (visita == null) {
      return const SalidaNoRegistrada(mensajeNoActiva);
    }
    final cerrada = await _cierre.cerrar(
      visita: visita,
      guardia: guardia,
      momento: _ahora(),
      motivoManual: detalle,
    );
    return SalidaRegistrada(cerrada);
  }
}
