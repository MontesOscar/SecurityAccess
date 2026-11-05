import 'package:security_access/data/seed/cuentas_semilla.dart';
import 'package:security_access/domain/entities/usuario.dart';
import 'package:security_access/domain/repositories/auth_repository.dart';

class InMemoryAuthRepository implements AuthRepository {
  InMemoryAuthRepository(List<RegistroCuenta> registros)
    : _registros = List<RegistroCuenta>.of(registros);

  final List<RegistroCuenta> _registros;
  Usuario? sesionActual;
  var _secuencia = 0;

  @override
  Future<List<Usuario>> listar() async {
    return [for (final registro in _registros) _aUsuario(registro)];
  }

  @override
  Future<Usuario?> buscarPorId(String id) async {
    for (final registro in _registros) {
      if (registro.id == id) {
        return _aUsuario(registro);
      }
    }
    return null;
  }

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
  Future<String> reservarId() async {
    _secuencia += 1;
    return 'usr-$_secuencia';
  }

  @override
  Future<void> registrar(Usuario usuario, {required String contrasena}) async {
    _registros.add(
      RegistroCuenta(
        id: usuario.id,
        nombre: usuario.nombre,
        correo: usuario.correo,
        contrasena: contrasena,
        telefono: usuario.telefono,
        rol: usuario.rol,
        estado: usuario.estado,
        viviendaId: usuario.viviendaId,
        viviendaNumero: usuario.viviendaNumero,
      ),
    );
  }

  @override
  Future<void> actualizar(Usuario usuario) async {
    final indice = _registros.indexWhere(
      (registro) => registro.id == usuario.id,
    );
    if (indice < 0) {
      return;
    }
    final actual = _registros[indice];
    _registros[indice] = RegistroCuenta(
      id: actual.id,
      nombre: usuario.nombre,
      correo: actual.correo,
      contrasena: actual.contrasena,
      telefono: usuario.telefono,
      rol: usuario.rol,
      estado: usuario.estado,
      viviendaId: usuario.viviendaId,
      viviendaNumero: usuario.viviendaNumero,
    );
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
      telefono: registro.telefono,
      rol: registro.rol,
      estado: registro.estado,
      viviendaId: registro.viviendaId,
      viviendaNumero: registro.viviendaNumero,
    );
  }
}
