import 'package:flutter_test/flutter_test.dart';
import 'package:security_access/data/repositories/in_memory_invitacion_repository.dart';
import 'package:security_access/domain/entities/estado_cuenta.dart';
import 'package:security_access/domain/entities/estado_invitacion.dart';
import 'package:security_access/domain/entities/estado_visita.dart';
import 'package:security_access/domain/entities/invitacion.dart';
import 'package:security_access/domain/entities/rol_usuario.dart';
import 'package:security_access/domain/entities/usuario.dart';
import 'package:security_access/domain/entities/visita.dart';
import 'package:security_access/domain/usecases/buscar_visitas_activas.dart';
import 'package:security_access/domain/usecases/cierre_visita.dart';
import 'package:security_access/domain/usecases/consultar_visitas_dentro.dart';
import 'package:security_access/domain/usecases/registrar_salida_manual.dart';
import 'package:security_access/domain/usecases/resultado_registrar_salida.dart';

void main() {
  final ahora = DateTime(2026, 11, 5, 16, 45);
  const guardia = Usuario(
    id: 'usr-guardia',
    nombre: 'Marta Guardia',
    correo: 'guardia@securityaccess.com',
    rol: RolUsuario.guardia,
    estado: EstadoCuenta.activo,
  );
  late InMemoryInvitacionRepository repositorio;
  late BuscarVisitasActivas buscar;
  late RegistrarSalidaManual registrar;

  Visita dentro(String id, String nombre, String vivienda, String folio) {
    return Visita(
      id: id,
      invitacionId: 'inv-$id',
      viviendaId: 'viv-$vivienda',
      viviendaNumero: vivienda,
      residenteId: 'usr-1',
      nombreVisitante: nombre,
      fecha: DateTime(2026, 11, 5, 10),
      entrada: DateTime(2026, 11, 5, 10),
      estado: EstadoVisita.dentro,
      tipoIdentificacion: 'INE',
      numeroIdentificacion: folio,
    );
  }

  setUp(() async {
    repositorio = InMemoryInvitacionRepository(
      visitas: [
        dentro('a', 'Ana Visitante', '101', 'ABC123'),
        dentro('b', 'Beto Visitante', '202', 'XYZ789'),
      ],
    );
    await repositorio.guardar(
      Invitacion(
        id: 'inv-a',
        viviendaId: 'viv-101',
        viviendaNumero: '101',
        residenteId: 'usr-1',
        nombreVisitante: 'Ana Visitante',
        entrada: DateTime(2026, 11, 5, 9),
        salida: DateTime(2026, 11, 5, 18),
        codigoQr: 'SA-000001',
        estado: EstadoInvitacion.usada,
        estadoVisita: EstadoVisita.dentro,
      ),
    );
    buscar = BuscarVisitasActivas(ConsultarVisitasDentro(repositorio));
    registrar = RegistrarSalidaManual(
      CierreVisita(repositorio),
      ahora: () => ahora,
    );
  });

  test(
    'busca la visita activa por vivienda, visitante o identificación',
    () async {
      Future<List<String>> ids(String texto) async => [
        for (final v in await buscar(guardia: guardia, texto: texto)) v.id,
      ];
      expect(await ids(''), ['a', 'b']);
      expect(await ids('202'), ['b']);
      expect(await ids('ana'), ['a']);
      expect(await ids('xyz7'), ['b']);
      expect(await ids('nadie'), isEmpty);
    },
  );

  test('registra guardia, fecha, hora y motivo y completa la visita', () async {
    final resultado = await registrar(
      guardia: guardia,
      visitaId: 'a',
      motivo: '  El visitante perdió su QR  ',
    );
    expect(resultado, isA<SalidaRegistrada>());
    final visita = (resultado as SalidaRegistrada).visita;
    expect(visita.guardiaSalidaId, guardia.id);
    expect(visita.salida, ahora);
    expect(visita.motivoSalidaManual, 'El visitante perdió su QR');
    expect(visita.estado, EstadoVisita.completada);

    final invitacion = await repositorio.buscarPorId('inv-a');
    expect(invitacion!.estadoVisita, EstadoVisita.completada);
  });

  test('una visita completada no puede cerrarse nuevamente', () async {
    await registrar(guardia: guardia, visitaId: 'a', motivo: 'Sin QR');
    final otraVez = await registrar(
      guardia: guardia,
      visitaId: 'a',
      motivo: 'Sin QR',
    );
    expect(otraVez, isA<SalidaNoRegistrada>());
    expect(
      (otraVez as SalidaNoRegistrada).mensaje,
      RegistrarSalidaManual.mensajeNoActiva,
    );
  });

  test('el motivo es obligatorio', () async {
    final resultado = await registrar(
      guardia: guardia,
      visitaId: 'a',
      motivo: '   ',
    );
    expect(
      (resultado as SalidaNoRegistrada).mensaje,
      RegistrarSalidaManual.mensajeMotivo,
    );
    expect((await buscar(guardia: guardia)).length, 2);
  });

  test('solo un guardia puede registrar la salida manual', () async {
    final resultado = await registrar(
      guardia: const Usuario(
        id: 'usr-admin',
        nombre: 'Ana Administradora',
        correo: 'admin@securityaccess.com',
        rol: RolUsuario.administrador,
        estado: EstadoCuenta.activo,
      ),
      visitaId: 'a',
      motivo: 'Sin QR',
    );
    expect(
      (resultado as SalidaNoRegistrada).mensaje,
      RegistrarSalidaManual.mensajeNoAutorizado,
    );
  });
}
