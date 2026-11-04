import 'package:security_access/domain/entities/estado_cuenta.dart';
import 'package:security_access/domain/entities/rol_usuario.dart';

class Usuario {
  const Usuario({
    required this.id,
    required this.nombre,
    required this.correo,
    required this.rol,
    required this.estado,
  });

  final String id;
  final String nombre;
  final String correo;
  final RolUsuario rol;
  final EstadoCuenta estado;

  bool get estaActivo => estado == EstadoCuenta.activo;
}
