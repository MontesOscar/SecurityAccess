import 'package:flutter/foundation.dart';
import 'package:security_access/domain/entities/estado_cuenta.dart';
import 'package:security_access/domain/entities/rol_usuario.dart';
import 'package:security_access/domain/entities/usuario.dart';
import 'package:security_access/domain/usecases/cambiar_estado_usuario.dart';
import 'package:security_access/domain/usecases/consultar_usuarios.dart';
import 'package:security_access/domain/usecases/resultado_cambio_estado_usuario.dart';

class UsuariosState {
  const UsuariosState({
    this.usuarios = const [],
    this.rol,
    this.estado,
    this.mensaje,
    this.detalle,
  });

  final List<Usuario> usuarios;
  final RolUsuario? rol;
  final EstadoCuenta? estado;
  final String? mensaje;
  final String? detalle;

  UsuariosState copyWith({
    List<Usuario>? usuarios,
    RolUsuario? rol,
    EstadoCuenta? estado,
    String? mensaje,
    String? detalle,
    bool limpiarRol = false,
    bool limpiarEstado = false,
    bool limpiarMensaje = false,
  }) {
    return UsuariosState(
      usuarios: usuarios ?? this.usuarios,
      rol: limpiarRol ? rol : rol ?? this.rol,
      estado: limpiarEstado ? estado : estado ?? this.estado,
      mensaje: limpiarMensaje ? mensaje : mensaje ?? this.mensaje,
      detalle: limpiarMensaje ? detalle : detalle ?? this.detalle,
    );
  }
}

class UsuariosViewModel extends ChangeNotifier {
  UsuariosViewModel({required this._consultar, required this._cambiarEstado});

  final ConsultarUsuarios _consultar;
  final CambiarEstadoUsuario _cambiarEstado;
  UsuariosState state = const UsuariosState();

  static const desactivado = 'Usuario desactivado correctamente';
  static const reactivado = 'Usuario reactivado correctamente';

  Future<void> cargar() async {
    final usuarios = await _consultar(rol: state.rol, estado: state.estado);
    state = state.copyWith(usuarios: usuarios);
    notifyListeners();
  }

  Future<void> cambiarRol(RolUsuario? rol) async {
    state = state.copyWith(rol: rol, limpiarRol: true);
    await cargar();
  }

  Future<void> cambiarEstadoFiltro(EstadoCuenta? estado) async {
    state = state.copyWith(estado: estado, limpiarEstado: true);
    await cargar();
  }

  Future<String?> desactivar(String id) {
    return _cambiar(id: id, activar: false, mensaje: desactivado);
  }

  Future<String?> reactivar(String id) {
    return _cambiar(id: id, activar: true, mensaje: reactivado);
  }

  Future<String?> _cambiar({
    required String id,
    required bool activar,
    required String mensaje,
  }) async {
    final resultado = await _cambiarEstado(id: id, activar: activar);
    if (resultado is! EstadoUsuarioActualizado) {
      return null;
    }
    await cargar();
    return mensaje;
  }
}
