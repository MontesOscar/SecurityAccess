import 'package:flutter_test/flutter_test.dart';
import 'package:security_access/data/repositories/in_memory_invitacion_repository.dart';
import 'package:security_access/data/repositories/in_memory_vivienda_repository.dart';
import 'package:security_access/domain/entities/estado_cuenta.dart';
import 'package:security_access/domain/entities/estado_invitacion.dart';
import 'package:security_access/domain/entities/estado_visita.dart';
import 'package:security_access/domain/entities/estado_vivienda.dart';
import 'package:security_access/domain/entities/invitacion.dart';
import 'package:security_access/domain/entities/rol_usuario.dart';
import 'package:security_access/domain/entities/tipo_identificacion.dart';
import 'package:security_access/domain/entities/usuario.dart';
import 'package:security_access/domain/entities/vivienda.dart';
import 'package:security_access/domain/usecases/buscar_entrada_activa.dart';
import 'package:security_access/domain/usecases/cierre_visita.dart';
import 'package:security_access/domain/usecases/leer_qr.dart';
import 'package:security_access/domain/usecases/registrar_entrada.dart';
import 'package:security_access/domain/usecases/registrar_salida.dart';
import 'package:security_access/domain/usecases/resultado_registrar_salida.dart';

void main() {
  final entrada = DateTime(2026, 11, 5, 12);
  final salida = DateTime(2026, 11, 5, 15, 30);
  const guardia = Usuario(
    id: 'usr-guardia',
    nombre: 'Marta Guardia',
    correo: 'guardia@securityaccess.com',
    rol: RolUsuario.guardia,
    estado: EstadoCuenta.activo,
  );
  late InMemoryInvitacionRepository invitaciones;
  late RegistrarEntrada registrarEntrada;
  late BuscarEntradaActiva buscar;
  late RegistrarSalida registrarSalida;

  setUp(() async {
    invitaciones = InMemoryInvitacionRepository();
    final viviendas = InMemoryViviendaRepository([
      const Vivienda(
        id: 'viv-1',
        numero: '101',
        direccion: 'Calle Uno',
        estado: EstadoVivienda.asignada,
        residenteId: 'usr-1',
        residenteNombre: 'Luis',
      ),
    ]);
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
        estado: EstadoInvitacion.activa,
        estadoVisita: EstadoVisita.sinEntrada,
      ),
    );
    final leer = LeerQr(invitaciones, viviendas, ahora: () => entrada);
    registrarEntrada = RegistrarEntrada(
      invitaciones,
      leer,
      ahora: () => entrada,
    );
    buscar = BuscarEntradaActiva(invitaciones);
    registrarSalida = RegistrarSalida(
      buscar,
      CierreVisita(invitaciones),
      ahora: () => salida,
    );
  });

  Future<void> registrarLaEntrada() async {
    await registrarEntrada(
      guardia: guardia,
      codigo: 'SA-000001',
      tipo: TipoIdentificacion.ine,
      numero: 'ABC123',
      identidadCoincide: true,
    );
  }

  test('sin entrada activa responde "No hay registro de entrada"', () async {
    final busqueda = await buscar('SA-000001');
    expect(busqueda, isA<SalidaNoDisponible>());
    expect(
      (busqueda as SalidaNoDisponible).mensaje,
      'No hay registro de entrada',
    );

    final resultado = await registrarSalida(
      guardia: guardia,
      codigo: 'SA-000001',
    );
    expect(resultado, isA<SalidaNoRegistrada>());
    expect(await invitaciones.listarVisitas(), isEmpty);
  });

  test('con entrada muestra los datos de la entrada activa', () async {
    await registrarLaEntrada();
    final busqueda = await buscar('SA-000001');
    expect(busqueda, isA<EntradaActivaEncontrada>());
    final visita = (busqueda as EntradaActivaEncontrada).visita;
    expect(visita.nombreVisitante, 'Ana Visitante');
    expect(visita.viviendaNumero, '101');
    expect(visita.entrada, entrada);
    expect(visita.numeroIdentificacion, 'ABC123');
  });

  test('al confirmar registra la hora de salida y la visita queda '
      '"Completada"', () async {
    await registrarLaEntrada();
    final resultado = await registrarSalida(
      guardia: guardia,
      codigo: 'SA-000001',
    );
    expect(resultado, isA<SalidaRegistrada>());
    final visita = (resultado as SalidaRegistrada).visita;
    expect(visita.salida, salida);
    expect(visita.estado, EstadoVisita.completada);
    expect(visita.guardiaSalidaId, guardia.id);
    expect(visita.motivoSalidaManual, isNull);

    final invitacion = await invitaciones.buscarPorCodigo('SA-000001');
    expect(invitacion!.estadoVisita, EstadoVisita.completada);

    final otraVez = await registrarSalida(
      guardia: guardia,
      codigo: 'SA-000001',
    );
    expect(
      (otraVez as SalidaNoRegistrada).mensaje,
      BuscarEntradaActiva.mensajeSinEntrada,
    );
  });

  test('un código ajeno o vacío no permite registrar la salida', () async {
    expect(
      ((await buscar('ajeno')) as SalidaNoDisponible).mensaje,
      LeerQr.mensajeInvalido,
    );
    expect(
      ((await buscar('  ')) as SalidaNoDisponible).mensaje,
      LeerQr.mensajeIlegible,
    );
  });

  test('solo un guardia registra la salida', () async {
    await registrarLaEntrada();
    final resultado = await registrarSalida(
      guardia: const Usuario(
        id: 'usr-1',
        nombre: 'Luis',
        correo: 'luis@securityaccess.com',
        rol: RolUsuario.residente,
        estado: EstadoCuenta.activo,
      ),
      codigo: 'SA-000001',
    );
    expect(resultado, isA<SalidaNoRegistrada>());
  });
}
