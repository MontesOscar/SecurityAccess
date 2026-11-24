import 'package:flutter_test/flutter_test.dart';
import 'package:security_access/data/repositories/in_memory_auth_repository.dart';
import 'package:security_access/data/repositories/in_memory_invitacion_repository.dart';
import 'package:security_access/data/seed/cuentas_semilla.dart';
import 'package:security_access/domain/entities/estado_cuenta.dart';
import 'package:security_access/domain/entities/estado_invitacion.dart';
import 'package:security_access/domain/entities/estado_visita.dart';
import 'package:security_access/domain/entities/invitacion.dart';
import 'package:security_access/domain/entities/rol_usuario.dart';
import 'package:security_access/domain/entities/usuario.dart';
import 'package:security_access/domain/entities/visita.dart';
import 'package:security_access/domain/usecases/cambiar_contrasena.dart';
import 'package:security_access/domain/usecases/consultar_visitas_dentro.dart';
import 'package:security_access/domain/services/envio_codigo_recuperacion.dart';
import 'package:security_access/domain/usecases/recuperar_contrasena.dart';
import 'package:security_access/domain/usecases/registrar_salida.dart';
import 'package:security_access/domain/usecases/resultado_registrar_salida.dart';

void main() {
  final ahora = DateTime(2026, 11, 5, 16);
  const guardia = Usuario(
    id: 'usr-guardia',
    nombre: 'Marta Guardia',
    correo: 'guardia@securityaccess.com',
    rol: RolUsuario.guardia,
    estado: EstadoCuenta.activo,
  );
  late InMemoryInvitacionRepository invitaciones;
  late RegistrarSalida registrar;
  late ConsultarVisitasDentro consultar;

  setUp(() async {
    invitaciones = InMemoryInvitacionRepository();
    await invitaciones.guardar(
      Invitacion(
        id: 'inv-1',
        viviendaId: 'viv-1',
        viviendaNumero: '101',
        residenteId: 'usr-1',
        nombreVisitante: 'Ana Visitante',
        entrada: DateTime(2026, 11, 5, 10),
        salida: DateTime(2026, 11, 5, 18),
        codigoQr: 'SA-000001',
        estado: EstadoInvitacion.usada,
        estadoVisita: EstadoVisita.dentro,
      ),
    );
    await invitaciones.guardarVisita(
      Visita(
        id: 'vis-1',
        viviendaId: 'viv-1',
        viviendaNumero: '101',
        residenteId: 'usr-1',
        nombreVisitante: 'Ana Visitante',
        fecha: DateTime(2026, 11, 5, 11),
        entrada: DateTime(2026, 11, 5, 11),
        estado: EstadoVisita.dentro,
        numeroIdentificacion: 'ABC123',
        invitacionId: 'inv-1',
      ),
    );
    registrar = RegistrarSalida(invitaciones, ahora: () => ahora);
    consultar = ConsultarVisitasDentro(invitaciones);
  });

  test(
    'la salida por QR registra la hora y deja la visita completada',
    () async {
      final preparada = await registrar.preparar(
        guardia: guardia,
        codigo: 'SA-000001',
      );
      expect(preparada, isA<SalidaPreparada>());
      final resultado = await registrar.porCodigo(
        guardia: guardia,
        codigo: 'SA-000001',
      );
      expect(resultado, isA<SalidaRegistrada>());
      final visita = (resultado as SalidaRegistrada).visita;
      expect(visita.salida, ahora);
      expect(visita.estado, EstadoVisita.completada);
      expect(visita.guardiaSalidaId, guardia.id);
      expect(await consultar(), isEmpty);
      final invitacion = await invitaciones.buscarPorId('inv-1');
      expect(invitacion?.estadoVisita, EstadoVisita.completada);
    },
  );

  test('sin entrada activa responde el mensaje de la historia', () async {
    final resultado = await registrar.preparar(
      guardia: guardia,
      codigo: 'SA-999',
    );
    expect(resultado, isA<SalidaNoRegistrada>());
    expect(
      (resultado as SalidaNoRegistrada).mensaje,
      RegistrarSalida.sinEntrada,
    );
  });

  test('una visita completada no se puede cerrar otra vez', () async {
    await registrar.porCodigo(guardia: guardia, codigo: 'SA-000001');
    final resultado = await registrar.porCodigo(
      guardia: guardia,
      codigo: 'SA-000001',
    );
    expect(
      (resultado as SalidaNoRegistrada).mensaje,
      RegistrarSalida.yaCompletada,
    );
  });

  test('la salida manual exige motivo y desaparece de la lista', () async {
    final vacio = await registrar.manual(
      guardia: guardia,
      visitaId: 'vis-1',
      motivo: ' ',
    );
    expect(
      (vacio as SalidaNoRegistrada).mensaje,
      RegistrarSalida.motivoObligatorio,
    );
    final resultado = await registrar.manual(
      guardia: guardia,
      visitaId: 'vis-1',
      motivo: 'QR dañado',
    );
    final visita = (resultado as SalidaRegistrada).visita;
    expect(visita.motivoSalida, 'QR dañado');
    expect(visita.guardiaSalidaId, guardia.id);
    expect(await consultar(consulta: '101'), isEmpty);
  });

  test(
    'el listado filtra por vivienda y conserva solo las visitas dentro',
    () async {
      await invitaciones.guardarVisita(
        Visita(
          id: 'vis-2',
          viviendaId: 'viv-2',
          viviendaNumero: '202',
          residenteId: 'usr-2',
          nombreVisitante: 'Bruno',
          fecha: DateTime(2026, 11, 4, 9),
          entrada: DateTime(2026, 11, 4, 9),
          estado: EstadoVisita.dentro,
        ),
      );
      final porVivienda = await consultar(consulta: '101');
      expect(porVivienda, hasLength(1));
      expect(porVivienda.single.nombreVisitante, 'Ana Visitante');
      final porFecha = await consultar(fecha: DateTime(2026, 11, 4));
      expect(porFecha.single.id, 'vis-2');
    },
  );

  test(
    'cambiar la contraseña exige la actual y no permite reutilizarla',
    () async {
      final auth = InMemoryAuthRepository(CuentasSemilla.registros);
      final cambiar = CambiarContrasena(auth);
      const admin = Usuario(
        id: 'usr-admin',
        nombre: 'Ana Administradora',
        correo: 'admin@securityaccess.com',
        rol: RolUsuario.administrador,
        estado: EstadoCuenta.activo,
      );
      final distinta = await cambiar(
        usuario: admin,
        actual: 'Admin1234',
        nueva: 'Nueva1234',
        confirmacion: 'Otra1234',
      );
      expect(
        (distinta as CambioRechazado).mensaje,
        CambiarContrasena.noCoinciden,
      );
      final repetida = await cambiar(
        usuario: admin,
        actual: 'Admin1234',
        nueva: 'Admin1234',
        confirmacion: 'Admin1234',
      );
      expect(
        (repetida as CambioRechazado).mensaje,
        CambiarContrasena.reutilizada,
      );
      final incorrecta = await cambiar(
        usuario: admin,
        actual: 'mala',
        nueva: 'Nueva1234',
        confirmacion: 'Nueva1234',
      );
      expect(
        (incorrecta as CambioRechazado).mensaje,
        CambiarContrasena.actualIncorrecta,
      );
      final ok = await cambiar(
        usuario: admin,
        actual: 'Admin1234',
        nueva: 'Nueva1234',
        confirmacion: 'Nueva1234',
      );
      expect(ok, isA<ContrasenaActualizada>());
      expect(
        await auth.contrasenaCoincide(
          correo: admin.correo,
          contrasena: 'Nueva1234',
        ),
        isTrue,
      );
    },
  );

  test('recuperar la contraseña no confirma si el correo existe', () async {
    final auth = InMemoryAuthRepository(CuentasSemilla.registros);
    final envios = _EnviosDePrueba();
    final recuperar = RecuperarContrasena(
      auth,
      envio: envios,
      ahora: () => ahora,
    );
    final desconocido = await recuperar.solicitar('nadie@correo.com');
    final conocido = await recuperar.solicitar('admin@securityaccess.com');
    expect(desconocido, isA<SolicitudRecuperacionEmitida>());
    expect(conocido, isA<SolicitudRecuperacionEmitida>());
    expect(envios.correos, ['admin@securityaccess.com']);
    expect(
      SolicitudRecuperacionEmitida.mensaje,
      'Si está registrado, recibirás instrucciones',
    );
    final falso = await recuperar.restablecer(
      codigo: (desconocido as SolicitudRecuperacionEmitida).codigo,
      nueva: 'Nueva1234',
      confirmacion: 'Nueva1234',
    );
    expect(falso, isA<RestablecimientoRechazado>());
    final ok = await recuperar.restablecer(
      codigo: (conocido as SolicitudRecuperacionEmitida).codigo,
      nueva: 'Nueva1234',
      confirmacion: 'Nueva1234',
    );
    expect(ok, isA<ContrasenaRestablecida>());
    expect(
      await auth.contrasenaCoincide(
        correo: 'admin@securityaccess.com',
        contrasena: 'Nueva1234',
      ),
      isTrue,
    );
  });
}

class _EnviosDePrueba implements EnvioCodigoRecuperacion {
  final correos = <String>[];

  @override
  Future<void> enviar({required String correo, required String codigo}) async {
    correos.add(correo);
  }
}
