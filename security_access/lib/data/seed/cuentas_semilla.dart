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
    this.telefono = '',
    this.viviendaId,
    this.viviendaNumero,
  });

  final String id;
  final String nombre;
  final String correo;
  final String contrasena;
  final String telefono;
  final RolUsuario rol;
  final EstadoCuenta estado;
  final String? viviendaId;
  final String? viviendaNumero;

  RegistroCuenta copyWith({
    String? nombre,
    String? telefono,
    RolUsuario? rol,
    EstadoCuenta? estado,
    String? viviendaId,
    String? viviendaNumero,
    bool limpiarVivienda = false,
  }) {
    return RegistroCuenta(
      id: id,
      nombre: nombre ?? this.nombre,
      correo: correo,
      contrasena: contrasena,
      telefono: telefono ?? this.telefono,
      rol: rol ?? this.rol,
      estado: estado ?? this.estado,
      viviendaId: limpiarVivienda ? viviendaId : viviendaId ?? this.viviendaId,
      viviendaNumero: limpiarVivienda
          ? viviendaNumero
          : viviendaNumero ?? this.viviendaNumero,
    );
  }
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
