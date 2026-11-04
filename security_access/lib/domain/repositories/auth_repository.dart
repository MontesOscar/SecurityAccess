import 'package:security_access/domain/entities/usuario.dart';

abstract class AuthRepository {
  Future<Usuario?> buscarPorCorreo(String correo);

  Future<bool> contrasenaCoincide({
    required String correo,
    required String contrasena,
  });

  Future<void> abrirSesion(Usuario usuario);

  Future<void> cerrarSesion();
}
