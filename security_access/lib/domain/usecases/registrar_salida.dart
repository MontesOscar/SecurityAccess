import 'package:security_access/domain/entities/rol_usuario.dart';
import 'package:security_access/domain/entities/usuario.dart';
import 'package:security_access/domain/usecases/buscar_entrada_activa.dart';
import 'package:security_access/domain/usecases/cierre_visita.dart';
import 'package:security_access/domain/usecases/resultado_registrar_salida.dart';

/// Registra la salida por QR. No vuelve a pedir identificación.
class RegistrarSalida {
  RegistrarSalida(this._buscar, this._cierre, {DateTime Function()? ahora})
    : _ahora = ahora ?? DateTime.now;

  final BuscarEntradaActiva _buscar;
  final CierreVisita _cierre;
  final DateTime Function() _ahora;

  Future<ResultadoRegistrarSalida> call({
    required Usuario guardia,
    required String codigo,
  }) async {
    if (guardia.rol != RolUsuario.guardia) {
      return const SalidaNoRegistrada(
        'Solo un guardia puede registrar la salida',
      );
    }
    final busqueda = await _buscar(codigo);
    switch (busqueda) {
      case SalidaNoDisponible(:final mensaje):
        return SalidaNoRegistrada(mensaje);
      case EntradaActivaEncontrada(:final visita):
        final cerrada = await _cierre.cerrar(
          visita: visita,
          guardia: guardia,
          momento: _ahora(),
        );
        return SalidaRegistrada(cerrada);
    }
  }
}
