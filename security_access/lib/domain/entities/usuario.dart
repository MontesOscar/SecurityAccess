import 'package:security_access/domain/entities/estado_cuenta.dart';
import 'package:security_access/domain/entities/rol_usuario.dart';

class Usuario {
  const Usuario({
    required this.id,
    required this.nombre,
    required this.correo,
    required this.rol,
    required this.estado,
    this.telefono = '',
    this.viviendaId,
    this.viviendaNumero,
  });

  final String id;
  final String nombre;
  final String correo;
  final String telefono;
  final RolUsuario rol;
  final EstadoCuenta estado;
  final String? viviendaId;
  final String? viviendaNumero;

  bool get estaActivo => estado == EstadoCuenta.activo;

  bool get esResidente => rol == RolUsuario.residente;

  Usuario copyWith({
    String? nombre,
    String? telefono,
    RolUsuario? rol,
    EstadoCuenta? estado,
    String? viviendaId,
    String? viviendaNumero,
    bool limpiarVivienda = false,
  }) {
    return Usuario(
      id: id,
      nombre: nombre ?? this.nombre,
      correo: correo,
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
