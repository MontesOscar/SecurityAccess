import 'package:security_access/domain/entities/usuario.dart';

abstract class AuthRepository {
  Future<List<Usuario>> listar();

  Future<Usuario?> buscarPorId(String id);

  Future<Usuario?> buscarPorCorreo(String correo);

  Future<bool> contrasenaCoincide({
    required String correo,
    required String contrasena,
  });

  Future<String> reservarId();

  Future<void> registrar(Usuario usuario, {required String contrasena});

  Future<void> actualizar(Usuario usuario);

  Future<void> abrirSesion(Usuario usuario);

  Future<void> cerrarSesion();
}
