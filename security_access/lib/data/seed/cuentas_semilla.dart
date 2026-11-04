import 'package:security_access/domain/entities/estado_cuenta.dart';
import 'package:security_access/domain/entities/rol_usuario.dart';

class RegistroCuenta {
  const RegistroCuenta({
    required this.id,
    required this.nombre,
    required this.correo,
    required this.contrasena,
    required this.rol,
    required this.estado,
  });

  final String id;
  final String nombre;
  final String correo;
  final String contrasena;
  final RolUsuario rol;
  final EstadoCuenta estado;
}

abstract final class CuentasSemilla {
  static const registros = <RegistroCuenta>[
    RegistroCuenta(
      id: 'usr-admin',
      nombre: 'Ana Administradora',
      correo: 'admin@securityaccess.com',
      contrasena: 'Admin1234',
      rol: RolUsuario.administrador,
      estado: EstadoCuenta.activo,
    ),
    RegistroCuenta(
      id: 'usr-residente',
      nombre: 'Luis Residente',
      correo: 'residente@securityaccess.com',
      contrasena: 'Residente1',
      rol: RolUsuario.residente,
      estado: EstadoCuenta.activo,
    ),
    RegistroCuenta(
      id: 'usr-guardia',
      nombre: 'Marta Guardia',
      correo: 'guardia@securityaccess.com',
      contrasena: 'Guardia1234',
      rol: RolUsuario.guardia,
      estado: EstadoCuenta.activo,
    ),
    RegistroCuenta(
      id: 'usr-inactivo',
      nombre: 'Pedro Inactivo',
      correo: 'inactivo@securityaccess.com',
      contrasena: 'Inactivo1',
      rol: RolUsuario.residente,
      estado: EstadoCuenta.inactivo,
    ),
  ];
}
