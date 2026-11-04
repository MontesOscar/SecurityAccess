import 'package:security_access/data/seed/cuentas_semilla.dart';
import 'package:security_access/domain/entities/usuario.dart';
import 'package:security_access/domain/repositories/auth_repository.dart';

class InMemoryAuthRepository implements AuthRepository {
  InMemoryAuthRepository(List<RegistroCuenta> registros)
    : _registros = List<RegistroCuenta>.of(registros);

  final List<RegistroCuenta> _registros;
  Usuario? sesionActual;

  @override
  Future<Usuario?> buscarPorCorreo(String correo) async {
    final registro = _buscar(correo);
    return registro == null ? null : _aUsuario(registro);
  }

  @override
  Future<bool> contrasenaCoincide({
    required String correo,
    required String contrasena,
  }) async {
    final registro = _buscar(correo);
    if (registro == null) {
      return false;
    }
    return registro.contrasena == contrasena;
  }

  @override
  Future<void> abrirSesion(Usuario usuario) async {
    sesionActual = usuario;
  }

  @override
  Future<void> cerrarSesion() async {
    sesionActual = null;
  }

  RegistroCuenta? _buscar(String correo) {
    final normalizado = correo.trim().toLowerCase();
    for (final registro in _registros) {
      if (registro.correo.toLowerCase() == normalizado) {
        return registro;
      }
    }
    return null;
  }

  Usuario _aUsuario(RegistroCuenta registro) {
    return Usuario(
      id: registro.id,
      nombre: registro.nombre,
      correo: registro.correo,
      rol: registro.rol,
      estado: registro.estado,
    );
  }
}
