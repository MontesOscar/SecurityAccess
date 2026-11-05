import 'package:security_access/domain/entities/estado_cuenta.dart';
import 'package:security_access/domain/entities/rol_usuario.dart';
import 'package:security_access/domain/entities/usuario.dart';
import 'package:security_access/domain/repositories/auth_repository.dart';

class ConsultarUsuarios {
  const ConsultarUsuarios(this._repositorio);

  final AuthRepository _repositorio;

  Future<List<Usuario>> call({RolUsuario? rol, EstadoCuenta? estado}) async {
    final usuarios = await _repositorio.listar();
    final filtrados = usuarios.where((usuario) {
      final coincideRol = rol == null || usuario.rol == rol;
      final coincideEstado = estado == null || usuario.estado == estado;
      return coincideRol && coincideEstado;
    }).toList();
    filtrados.sort(
      (a, b) => a.nombre.toLowerCase().compareTo(b.nombre.toLowerCase()),
    );
    return filtrados;
  }
}
