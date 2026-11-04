import 'package:flutter/material.dart';
import 'package:security_access/app/dependencias_app.dart';
import 'package:security_access/data/repositories/in_memory_auth_repository.dart';
import 'package:security_access/data/repositories/in_memory_vivienda_repository.dart';
import 'package:security_access/data/seed/cuentas_semilla.dart';
import 'package:security_access/domain/entities/estado_cuenta.dart';
import 'package:security_access/domain/entities/vivienda.dart';
import 'package:security_access/domain/usecases/cambiar_estado_vivienda.dart';
import 'package:security_access/domain/usecases/cerrar_sesion.dart';
import 'package:security_access/domain/usecases/consultar_viviendas.dart';
import 'package:security_access/domain/usecases/crear_vivienda.dart';
import 'package:security_access/domain/usecases/editar_vivienda.dart';
import 'package:security_access/domain/usecases/iniciar_sesion.dart';
import 'package:security_access/presentation/login/cuenta_demo.dart';
import 'package:security_access/presentation/security_access_app.dart';
import 'package:security_access/presentation/session/session_controller.dart';

SecurityAccessApp crearAplicacion({
  List<Vivienda> viviendasIniciales = const [],
}) {
  final repositorio = InMemoryAuthRepository(CuentasSemilla.registros);
  final viviendas = InMemoryViviendaRepository(viviendasIniciales);
  final consultarViviendas = ConsultarViviendas(viviendas);
  return SecurityAccessApp(
    dependencias: Dependencias(
      iniciarSesion: IniciarSesion(repositorio),
      cerrarSesion: CerrarSesion(repositorio),
      session: SessionController(),
      navigatorKey: GlobalKey<NavigatorState>(),
      crearVivienda: CrearVivienda(viviendas),
      consultarViviendas: consultarViviendas,
      editarVivienda: EditarVivienda(viviendas),
      cambiarEstadoVivienda: CambiarEstadoVivienda(viviendas),
      cuentasDemo: [
        for (final registro in CuentasSemilla.registros)
          CuentaDemo(
            nombre: registro.nombre,
            correo: registro.correo,
            contrasena: registro.contrasena,
            detalle: registro.estado == EstadoCuenta.activo
                ? registro.rol.etiqueta
                : 'Cuenta inactiva',
          ),
      ],
    ),
  );
}
