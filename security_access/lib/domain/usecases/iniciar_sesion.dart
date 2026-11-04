import 'package:security_access/domain/repositories/auth_repository.dart';
import 'package:security_access/domain/usecases/resultado_inicio_sesion.dart';

class IniciarSesion {
  const IniciarSesion(this._repositorio);

  final AuthRepository _repositorio;

  Future<ResultadoInicioSesion> call({
    required String correo,
    required String contrasena,
  }) async {
    final correoNormalizado = correo.trim().toLowerCase();
    if (correoNormalizado.isEmpty || contrasena.isEmpty) {
      return const InicioSesionCredencialesInvalidas();
    }

    final usuario = await _repositorio.buscarPorCorreo(correoNormalizado);
    if (usuario == null) {
      return const InicioSesionCredencialesInvalidas();
    }

    final coincide = await _repositorio.contrasenaCoincide(
      correo: correoNormalizado,
      contrasena: contrasena,
    );
    if (!coincide) {
      return const InicioSesionCredencialesInvalidas();
    }

    if (!usuario.estaActivo) {
      return const InicioSesionCuentaInactiva();
    }

    await _repositorio.abrirSesion(usuario);
    return InicioSesionExitoso(usuario);
  }
}
