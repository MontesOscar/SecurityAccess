import 'package:flutter/material.dart';
import 'package:security_access/domain/usecases/cambiar_estado_vivienda.dart';
import 'package:security_access/domain/usecases/cerrar_sesion.dart';
import 'package:security_access/domain/usecases/consultar_viviendas.dart';
import 'package:security_access/domain/usecases/crear_vivienda.dart';
import 'package:security_access/domain/usecases/editar_vivienda.dart';
import 'package:security_access/domain/usecases/iniciar_sesion.dart';
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
