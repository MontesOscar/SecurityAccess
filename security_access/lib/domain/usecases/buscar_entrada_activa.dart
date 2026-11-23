import 'package:security_access/domain/repositories/invitacion_repository.dart';
import 'package:security_access/domain/usecases/leer_qr.dart';
import 'package:security_access/domain/usecases/resultado_registrar_salida.dart';

/// Con el código QR leído busca la entrada que aún no tiene salida.
class BuscarEntradaActiva {
  const BuscarEntradaActiva(this._repositorio);

  final InvitacionRepository _repositorio;

  static const mensajeSinEntrada = 'No hay registro de entrada';

  Future<ResultadoBusquedaSalida> call(String codigo) async {
    final limpio = codigo.trim();
    if (limpio.isEmpty) {
      return const SalidaNoDisponible(LeerQr.mensajeIlegible);
    }
    final invitacion = await _repositorio.buscarPorCodigo(limpio);
    if (invitacion == null) {
      return const SalidaNoDisponible(LeerQr.mensajeInvalido);
    }
    for (final visita in await _repositorio.listarVisitas()) {
      if (visita.invitacionId == invitacion.id && visita.estaDentro) {
        return EntradaActivaEncontrada(
          codigo: limpio,
          invitacion: invitacion,
          visita: visita,
        );
      }
    }
    return const SalidaNoDisponible(mensajeSinEntrada);
  }
}
