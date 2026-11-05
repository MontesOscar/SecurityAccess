import 'package:flutter/material.dart';
import 'package:security_access/domain/usecases/buscar_invitacion.dart';
import 'package:security_access/domain/usecases/cambiar_estado_usuario.dart';
import 'package:security_access/domain/usecases/cambiar_estado_vivienda.dart';
import 'package:security_access/domain/usecases/cancelar_invitacion.dart';
import 'package:security_access/domain/usecases/cerrar_sesion.dart';
import 'package:security_access/domain/usecases/consultar_historial_visitas.dart';
import 'package:security_access/domain/usecases/consultar_invitaciones.dart';
import 'package:security_access/domain/usecases/consultar_usuarios.dart';
import 'package:security_access/domain/usecases/consultar_viviendas.dart';
import 'package:security_access/domain/usecases/crear_invitacion.dart';
import 'package:security_access/domain/usecases/crear_usuario.dart';
import 'package:security_access/domain/usecases/crear_vivienda.dart';
import 'package:security_access/domain/usecases/editar_usuario.dart';
import 'package:security_access/domain/usecases/editar_vivienda.dart';
import 'package:security_access/domain/usecases/iniciar_sesion.dart';
import 'package:security_access/domain/usecases/leer_qr.dart';
import 'package:security_access/domain/usecases/listar_viviendas_disponibles.dart';
import 'package:security_access/domain/usecases/rechazar_acceso.dart';
import 'package:security_access/domain/usecases/registrar_entrada.dart';
import 'package:security_access/presentation/login/cuenta_demo.dart';
import 'package:security_access/presentation/session/session_controller.dart';

class Dependencias {
  Dependencias({
    required this.iniciarSesion,
    required this.cerrarSesion,
    required this.session,
    required this.navigatorKey,
    required this.cuentasDemo,
    required this.crearVivienda,
    required this.consultarViviendas,
    required this.editarVivienda,
    required this.cambiarEstadoVivienda,
    required this.crearUsuario,
    required this.consultarUsuarios,
    required this.editarUsuario,
    required this.cambiarEstadoUsuario,
    required this.listarViviendasDisponibles,
    required this.crearInvitacion,
    required this.consultarInvitaciones,
    required this.buscarInvitacion,
    required this.cancelarInvitacion,
    required this.consultarHistorialVisitas,
    required this.leerQr,
    required this.registrarEntrada,
    required this.rechazarAcceso,
  });

  final IniciarSesion iniciarSesion;
  final CerrarSesion cerrarSesion;
  final SessionController session;
  final GlobalKey<NavigatorState> navigatorKey;
  final List<CuentaDemo> cuentasDemo;
  final CrearVivienda crearVivienda;
  final ConsultarViviendas consultarViviendas;
  final EditarVivienda editarVivienda;
  final CambiarEstadoVivienda cambiarEstadoVivienda;
  final CrearUsuario crearUsuario;
  final ConsultarUsuarios consultarUsuarios;
  final EditarUsuario editarUsuario;
  final CambiarEstadoUsuario cambiarEstadoUsuario;
  final ListarViviendasDisponibles listarViviendasDisponibles;
  final CrearInvitacion crearInvitacion;
  final ConsultarInvitaciones consultarInvitaciones;
  final BuscarInvitacion buscarInvitacion;
  final CancelarInvitacion cancelarInvitacion;
  final ConsultarHistorialVisitas consultarHistorialVisitas;
  final LeerQr leerQr;
  final RegistrarEntrada registrarEntrada;
  final RechazarAcceso rechazarAcceso;
}

class DependenciasApp extends InheritedWidget {
  const DependenciasApp({
    required this.dependencias,
    required super.child,
    super.key,
  });

  final Dependencias dependencias;

  static Dependencias of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<DependenciasApp>();
    assert(scope != null, 'DependenciasApp no está en el árbol de widgets.');
    return scope!.dependencias;
  }

  @override
  bool updateShouldNotify(DependenciasApp oldWidget) {
    return dependencias != oldWidget.dependencias;
  }
}
