import 'package:security_access/domain/repositories/auth_repository.dart';
import 'package:security_access/domain/repositories/recuperacion_repository.dart';
import 'package:security_access/domain/usecases/reglas_contrasena.dart';
import 'package:security_access/domain/usecases/resultado_recuperar_contrasena.dart';
import 'package:security_access/domain/usecases/validar_codigo_recuperacion.dart';

/// Guarda la nueva contraseña si el código sigue siendo válido. El código
/// se borra al usarse, así que solo sirve una vez.
class RestablecerContrasena {
  const RestablecerContrasena(this._usuarios, this._codigos, this._validar);

  final AuthRepository _usuarios;
  final RecuperacionRepository _codigos;
  final ValidarCodigoRecuperacion _validar;

  static const mensajeObligatorios = 'Todos los campos son obligatorios';
  static const mensajeIgualAnterior =
      'La nueva contraseña no puede ser igual a la anterior';

  Future<ResultadoRestablecerContrasena> call({
    required String correo,
    required String codigo,
    required String nueva,
    required String confirmacion,
  }) async {
    final normalizado = correo.trim().toLowerCase();
    final valido = await _validar(correo: normalizado, codigo: codigo);
    final usuario = valido
        ? await _usuarios.buscarPorCorreo(normalizado)
        : null;
    if (usuario == null) {
      return const ContrasenaNoRestablecida(
        ValidarCodigoRecuperacion.mensajeInvalido,
      );
    }
    if (nueva.isEmpty || confirmacion.isEmpty) {
      return const ContrasenaNoRestablecida(mensajeObligatorios);
    }
    if (nueva != confirmacion) {
      return const ContrasenaNoRestablecida(
        ReglasContrasena.mensajeNoCoinciden,
      );
    }
    if (!ReglasContrasena.cumple(nueva)) {
      return const ContrasenaNoRestablecida(ReglasContrasena.mensajeRequisitos);
    }
    final esLaAnterior = await _usuarios.contrasenaCoincide(
      correo: normalizado,
      contrasena: nueva,
    );
    if (esLaAnterior) {
      return const ContrasenaNoRestablecida(mensajeIgualAnterior);
    }
    await _usuarios.actualizarContrasena(id: usuario.id, contrasena: nueva);
    await _codigos.eliminar(normalizado);
    return const ContrasenaRestablecida();
  }
}
