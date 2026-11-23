import 'package:security_access/domain/repositories/recuperacion_repository.dart';

/// Revisa que el código corresponda al correo y siga vigente.
class ValidarCodigoRecuperacion {
  ValidarCodigoRecuperacion(this._codigos, {DateTime Function()? ahora})
    : _ahora = ahora ?? DateTime.now;

  final RecuperacionRepository _codigos;
  final DateTime Function() _ahora;

  /// Mismo mensaje si el correo no existe, el código es incorrecto o venció.
  static const mensajeInvalido = 'El código no es válido o ya venció';

  Future<bool> call({required String correo, required String codigo}) async {
    final normalizado = correo.trim().toLowerCase();
    final guardado = await _codigos.buscarPorCorreo(normalizado);
    if (guardado == null) {
      return false;
    }
    if (!guardado.vigenteEn(_ahora())) {
      await _codigos.eliminar(normalizado);
      return false;
    }
    return guardado.codigo == codigo.trim();
  }
}
