import 'package:flutter_test/flutter_test.dart';
import 'package:security_access/data/repositories/in_memory_invitacion_repository.dart';
import 'package:security_access/data/repositories/in_memory_vivienda_repository.dart';
import 'package:security_access/domain/entities/estado_cuenta.dart';
import 'package:security_access/domain/entities/estado_invitacion.dart';
import 'package:security_access/domain/entities/estado_visita.dart';
import 'package:security_access/domain/entities/estado_vivienda.dart';
import 'package:security_access/domain/entities/rol_usuario.dart';
import 'package:security_access/domain/entities/usuario.dart';
import 'package:security_access/domain/entities/visita.dart';
import 'package:security_access/domain/entities/vivienda.dart';
import 'package:security_access/domain/usecases/buscar_invitacion.dart';
import 'package:security_access/domain/usecases/cancelar_invitacion.dart';
import 'package:security_access/domain/usecases/consultar_historial_visitas.dart';
import 'package:security_access/domain/usecases/consultar_invitaciones.dart';
import 'package:security_access/domain/usecases/crear_invitacion.dart';
import 'package:security_access/domain/usecases/resultado_cancelar_invitacion.dart';
import 'package:security_access/domain/usecases/resultado_crear_invitacion.dart';

void main() {
  final ahora = DateTime(2026, 11, 5, 9);
  const residente = Usuario(
    id: 'usr-1',
    nombre: 'Luis Residente',
    correo: 'luis@securityaccess.com',
    rol: RolUsuario.residente,
    estado: EstadoCuenta.activo,
    viviendaId: 'viv-1',
    viviendaNumero: '101',
  );
  const otro = Usuario(
    id: 'usr-2',
    nombre: 'Ana Residente',
    correo: 'ana@securityaccess.com',
    rol: RolUsuario.residente,
    estado: EstadoCuenta.activo,
    viviendaId: 'viv-2',
    viviendaNumero: '202',
  );

  late InMemoryInvitacionRepository invitaciones;
  late CrearInvitacion crear;
  late ConsultarInvitaciones consultar;
  late CancelarInvitacion cancelar;
  late ConsultarHistorialVisitas historial;

  setUp(() {
    invitaciones = InMemoryInvitacionRepository(
      visitas: [
        Visita(
          id: 'vis-1',
          viviendaId: 'viv-1',
          residenteId: 'usr-1',
          nombreVisitante: 'Visita propia',
          fecha: DateTime(2026, 11, 4, 15),
          entrada: DateTime(2026, 11, 4, 15),
          salida: DateTime(2026, 11, 4, 16),
          estado: EstadoVisita.completada,
        ),
        Visita(
          id: 'vis-2',
          viviendaId: 'viv-1',
          residenteId: 'usr-anterior',
          nombreVisitante: 'Visita anterior',
          fecha: DateTime(2026, 11, 1, 10),
          estado: EstadoVisita.completada,
        ),
        Visita(
          id: 'vis-3',
          viviendaId: 'viv-2',
          residenteId: 'usr-2',
          nombreVisitante: 'Visita ajena',
          fecha: DateTime(2026, 11, 3, 11),
          estado: EstadoVisita.dentro,
        ),
      ],
    );
    final viviendas = InMemoryViviendaRepository([
      const Vivienda(
        id: 'viv-1',
        numero: '101',
        direccion: 'Calle Uno',
        estado: EstadoVivienda.asignada,
        residenteId: 'usr-1',
        residenteNombre: 'Luis Residente',
      ),
      const Vivienda(
        id: 'viv-9',
        numero: '9',
        direccion: 'Calle Inactiva',
        estado: EstadoVivienda.inactiva,
        residenteId: 'usr-inactiva',
        residenteNombre: 'Inactiva',
      ),
    ]);
    crear = CrearInvitacion(invitaciones, viviendas, ahora: () => ahora);
    consultar = ConsultarInvitaciones(invitaciones, ahora: () => ahora);
    cancelar = CancelarInvitacion(invitaciones, ahora: () => ahora);
    historial = ConsultarHistorialVisitas(invitaciones);
  });

  test('crea una invitación activa con QR único y valida el horario', () async {
    final creada = await crear(
      residente: residente,
      nombreVisitante: ' Carlos Visitante ',
      entrada: DateTime(2026, 11, 5, 10),
      salida: DateTime(2026, 11, 5, 12),
    );
    expect(creada, isA<InvitacionCreada>());
    final invitacion = (creada as InvitacionCreada).invitacion;
    expect(invitacion.estado, EstadoInvitacion.activa);
    expect(invitacion.estadoVisita, EstadoVisita.sinEntrada);
    expect(invitacion.nombreVisitante, 'Carlos Visitante');
    expect(invitacion.codigoQr, 'SA-000001');

    final segunda = await crear(
      residente: residente,
      nombreVisitante: 'Otra',
      entrada: DateTime(2026, 11, 6, 10),
      salida: DateTime(2026, 11, 6, 11),
    );
    expect((segunda as InvitacionCreada).invitacion.codigoQr, 'SA-000002');

    expect(
      await crear(
        residente: residente,
        nombreVisitante: 'Tarde',
        entrada: DateTime(2026, 11, 4, 10),
        salida: DateTime(2026, 11, 4, 12),
      ),
      isA<EntradaAnterior>(),
    );
    expect(
      await crear(
        residente: residente,
        nombreVisitante: 'Mal horario',
        entrada: DateTime(2026, 11, 5, 18),
        salida: DateTime(2026, 11, 5, 18),
      ),
      isA<SalidaInvalida>(),
    );
  });

  test('una vivienda inactiva no permite crear invitaciones', () async {
    const residenteInactivo = Usuario(
      id: 'usr-inactiva',
      nombre: 'Casa Inactiva',
      correo: 'inactiva@securityaccess.com',
      rol: RolUsuario.residente,
      estado: EstadoCuenta.activo,
      viviendaId: 'viv-9',
    );
    final resultado = await crear(
      residente: residenteInactivo,
      nombreVisitante: 'Visita',
      entrada: DateTime(2026, 11, 5, 10),
      salida: DateTime(2026, 11, 5, 12),
    );
    expect(resultado, isA<ViviendaNoActiva>());
  });

  test(
    'lista solo las invitaciones de la vivienda y marca las vencidas',
    () async {
      await crear(
        residente: residente,
        nombreVisitante: 'Vigente',
        entrada: DateTime(2026, 11, 5, 10),
        salida: DateTime(2026, 11, 5, 18),
      );
      await crear(
        residente: residente,
        nombreVisitante: 'Vencida',
        entrada: DateTime(2026, 11, 5, 1),
        salida: DateTime(2026, 11, 5, 2),
      );
      await crear(
        residente: otro,
        nombreVisitante: 'Ajena',
        entrada: DateTime(2026, 11, 5, 10),
        salida: DateTime(2026, 11, 5, 12),
      );

      final lista = await consultar(residente: residente);
      expect(lista.map((invitacion) => invitacion.nombreVisitante), [
        'Vigente',
        'Vencida',
      ]);
      expect(
        lista
            .firstWhere((invitacion) => invitacion.nombreVisitante == 'Vencida')
            .estado,
        EstadoInvitacion.vencida,
      );

      final soloActivas = await consultar(
        residente: residente,
        estado: EstadoInvitacion.activa,
      );
      expect(soloActivas, hasLength(1));
      expect(soloActivas.single.nombreVisitante, 'Vigente');

      final detalle = await BuscarInvitacion(invitaciones, ahora: () => ahora)(
        residente: residente,
        invitacionId: lista.last.id,
      );
      expect(detalle!.estado, EstadoInvitacion.vencida);
    },
  );

  test('cancela una invitación activa y la conserva en el historial', () async {
    final creada = await crear(
      residente: residente,
      nombreVisitante: 'Para cancelar',
      entrada: DateTime(2026, 11, 5, 10),
      salida: DateTime(2026, 11, 5, 18),
    );
    final id = (creada as InvitacionCreada).invitacion.id;

    expect(
      await cancelar(residente: otro, invitacionId: id),
      isA<InvitacionNoCancelable>(),
    );
    final cancelada = await cancelar(residente: residente, invitacionId: id);
    expect(cancelada, isA<InvitacionCancelada>());
    expect(
      (cancelada as InvitacionCancelada).invitacion.estado,
      EstadoInvitacion.cancelada,
    );
    expect(InvitacionCancelada.mensajeGuardia, 'Invitación cancelada');

    final lista = await consultar(
      residente: residente,
      estado: EstadoInvitacion.cancelada,
    );
    expect(lista.single.nombreVisitante, 'Para cancelar');
    expect(
      await cancelar(residente: residente, invitacionId: id),
      isA<InvitacionNoCancelable>(),
    );
  });

  test('el historial solo muestra visitas de la asignación actual', () async {
    final visitas = await historial(residente: residente);
    expect(visitas.map((visita) => visita.nombreVisitante), ['Visita propia']);

    final filtradas = await historial(
      residente: residente,
      desde: DateTime(2026, 11, 5),
      hasta: DateTime(2026, 11, 5),
    );
    expect(filtradas, isEmpty);

    final sinVivienda = await historial(
      residente: const Usuario(
        id: 'usr-1',
        nombre: 'Luis Residente',
        correo: 'luis@securityaccess.com',
        rol: RolUsuario.residente,
        estado: EstadoCuenta.activo,
      ),
    );
    expect(sinVivienda, isEmpty);
  });
}
