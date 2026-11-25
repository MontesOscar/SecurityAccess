import 'dart:async';

import 'package:flutter/material.dart';
import 'package:security_access/app/dependencias_app.dart';
import 'package:security_access/presentation/comun/mostrar_aviso.dart';
import 'package:security_access/presentation/session/session_controller.dart';

class VigilarInactividad extends StatefulWidget {
  const VigilarInactividad({required this.child, super.key});

  final Widget child;

  static const mensaje = 'Tu sesión expiró por inactividad';

  @override
  State<VigilarInactividad> createState() => _VigilarInactividadState();
}

class _VigilarInactividadState extends State<VigilarInactividad> {
  SessionController? _session;
  Timer? _timer;
  var _cerrando = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final session = DependenciasApp.of(context).session;
    if (!identical(session, _session)) {
      _session?.removeListener(_alCambiarSesion);
      _session = session;
      session.addListener(_alCambiarSesion);
    }
    _programar();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _session?.removeListener(_alCambiarSesion);
    super.dispose();
  }

  void _alCambiarSesion() {
    _programar();
  }

  void _actividad() {
    if (_session?.usuario == null || _cerrando) {
      return;
    }
    _programar();
  }

  void _programar() {
    _timer?.cancel();
    final dependencias = DependenciasApp.of(context);
    if (dependencias.session.usuario == null) {
      return;
    }
    _timer = Timer(dependencias.inactividad, _expirar);
  }

  Future<void> _expirar() async {
    final dependencias = DependenciasApp.of(context);
    if (_cerrando || dependencias.session.usuario == null) {
      return;
    }
    _cerrando = true;
    dependencias.navigatorKey.currentState?.popUntil((route) => route.isFirst);
    await dependencias.session.cerrar(dependencias.cerrarSesion);
    final aviso = dependencias.navigatorKey.currentContext;
    if (aviso != null && aviso.mounted) {
      mostrarAviso(aviso, VigilarInactividad.mensaje);
    }
    _cerrando = false;
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => _actividad(),
      onPointerSignal: (_) => _actividad(),
      child: widget.child,
    );
  }
}
