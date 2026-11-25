import 'package:flutter/material.dart';
import 'package:security_access/app/dependencias_app.dart';
import 'package:security_access/data/correo/envio_codigo_emailjs.dart';
import 'package:security_access/data/repositories/in_memory_auth_repository.dart';
import 'package:security_access/data/repositories/in_memory_invitacion_repository.dart';
import 'package:security_access/data/repositories/in_memory_vivienda_repository.dart';
import 'package:security_access/data/seed/cuentas_semilla.dart';
import 'package:security_access/domain/entities/estado_cuenta.dart';
import 'package:security_access/domain/services/envio_codigo_recuperacion.dart';
import 'package:security_access/domain/entities/invitacion.dart';
import 'package:security_access/domain/entities/notificacion.dart';
import 'package:security_access/domain/entities/visita.dart';
import 'package:security_access/domain/entities/vivienda.dart';
import 'package:security_access/domain/usecases/asignacion_vivienda.dart';
import 'package:security_access/domain/usecases/buscar_invitacion.dart';
import 'package:security_access/domain/usecases/cancelar_invitacion.dart';
import 'package:security_access/domain/usecases/consultar_historial_visitas.dart';
import 'package:security_access/domain/usecases/consultar_invitaciones.dart';
import 'package:security_access/domain/usecases/crear_invitacion.dart';
import 'package:security_access/domain/usecases/cambiar_estado_usuario.dart';
import 'package:security_access/domain/usecases/cambiar_estado_vivienda.dart';
import 'package:security_access/domain/usecases/cerrar_sesion.dart';
import 'package:security_access/domain/usecases/consultar_usuarios.dart';
import 'package:security_access/domain/usecases/consultar_viviendas.dart';
import 'package:security_access/domain/usecases/crear_usuario.dart';
import 'package:security_access/domain/usecases/crear_vivienda.dart';
import 'package:security_access/domain/usecases/editar_usuario.dart';
import 'package:security_access/domain/usecases/editar_vivienda.dart';
import 'package:security_access/domain/usecases/iniciar_sesion.dart';
import 'package:security_access/domain/usecases/leer_qr.dart';
import 'package:security_access/domain/usecases/listar_viviendas_disponibles.dart';
import 'package:security_access/domain/usecases/rechazar_acceso.dart';
import 'package:security_access/domain/usecases/cambiar_contrasena.dart';
import 'package:security_access/domain/usecases/consultar_visitas_dentro.dart';
import 'package:security_access/domain/usecases/consultar_notificaciones.dart';
import 'package:security_access/domain/usecases/consultar_reporte_accesos.dart';
import 'package:security_access/domain/usecases/notificar_evento_visita.dart';
import 'package:security_access/domain/usecases/recuperar_contrasena.dart';
import 'package:security_access/domain/usecases/registrar_entrada.dart';
import 'package:security_access/domain/usecases/registrar_salida.dart';
import 'package:security_access/presentation/login/cuenta_demo.dart';
import 'package:security_access/presentation/security_access_app.dart';
import 'package:security_access/presentation/session/session_controller.dart';

SecurityAccessApp crearAplicacion({
  List<Vivienda> viviendasIniciales = const [],
  List<Invitacion> invitacionesIniciales = const [],
  List<Visita> visitasIniciales = const [],
  List<Notificacion> notificacionesIniciales = const [],
  EnvioCodigoRecuperacion? envioRecuperacion,
  Duration inactividad = const Duration(minutes: 15),
}) {
  final repositorio = InMemoryAuthRepository(CuentasSemilla.registros);
  final viviendas = InMemoryViviendaRepository(viviendasIniciales);
  final invitaciones = InMemoryInvitacionRepository(
    invitaciones: invitacionesIniciales,
    visitas: visitasIniciales,
    notificaciones: notificacionesIniciales,
  );
  final consultarViviendas = ConsultarViviendas(viviendas);
  final asignacion = AsignacionVivienda(viviendas);
  final listarViviendasDisponibles = ListarViviendasDisponibles(
    consultarViviendas,
  );
  final leerQr = LeerQr(invitaciones, viviendas);
  final notificar = NotificarEventoVisita(invitaciones, viviendas);
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
      crearUsuario: CrearUsuario(repositorio, asignacion),
      consultarUsuarios: ConsultarUsuarios(repositorio),
      editarUsuario: EditarUsuario(repositorio, asignacion),
      cambiarEstadoUsuario: CambiarEstadoUsuario(repositorio, asignacion),
      listarViviendasDisponibles: listarViviendasDisponibles,
      crearInvitacion: CrearInvitacion(invitaciones, viviendas),
      consultarInvitaciones: ConsultarInvitaciones(invitaciones),
      buscarInvitacion: BuscarInvitacion(invitaciones),
      cancelarInvitacion: CancelarInvitacion(invitaciones),
      consultarHistorialVisitas: ConsultarHistorialVisitas(invitaciones),
      leerQr: leerQr,
      registrarEntrada: RegistrarEntrada(
        invitaciones,
        leerQr,
        notificar: notificar,
      ),
      rechazarAcceso: RechazarAcceso(invitaciones, notificar: notificar),
      registrarSalida: RegistrarSalida(invitaciones, notificar: notificar),
      consultarVisitasDentro: ConsultarVisitasDentro(invitaciones),
      cambiarContrasena: CambiarContrasena(repositorio),
      recuperarContrasena: RecuperarContrasena(
        repositorio,
        envio: envioRecuperacion ?? const EnvioCodigoEmailJs(),
      ),
      consultarNotificaciones: ConsultarNotificaciones(invitaciones),
      consultarReporteAccesos: ConsultarReporteAccesos(
        invitaciones,
        repositorio,
      ),
      inactividad: inactividad,
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
