import 'package:flutter_test/flutter_test.dart';
import 'package:security_access/data/repositories/in_memory_auth_repository.dart';
import 'package:security_access/data/repositories/in_memory_invitacion_repository.dart';
import 'package:security_access/data/repositories/in_memory_vivienda_repository.dart';
import 'package:security_access/data/seed/cuentas_semilla.dart';
import 'package:security_access/domain/entities/acceso_rechazado.dart';
import 'package:security_access/domain/entities/estado_cuenta.dart';
import 'package:security_access/domain/entities/estado_invitacion.dart';
import 'package:security_access/domain/entities/estado_visita.dart';
import 'package:security_access/domain/entities/estado_vivienda.dart';
import 'package:security_access/domain/entities/invitacion.dart';
import 'package:security_access/domain/entities/motivo_rechazo.dart';
import 'package:security_access/domain/entities/rol_usuario.dart';
import 'package:security_access/domain/entities/tipo_identificacion.dart';
import 'package:security_access/domain/entities/usuario.dart';
import 'package:security_access/domain/entities/visita.dart';
import 'package:security_access/domain/entities/vivienda.dart';
import 'package:security_access/domain/usecases/consultar_notificaciones.dart';
import 'package:security_access/domain/usecases/consultar_reporte_accesos.dart';
import 'package:security_access/domain/usecases/leer_qr.dart';
import 'package:security_access/domain/usecases/notificar_evento_visita.dart';
import 'package:security_access/domain/usecases/registrar_entrada.dart';
import 'package:security_access/domain/usecases/resultado_registrar_entrada.dart';

void main() {
  final ahora = DateTime(2026, 11, 24, 12);
  const guardia = Usuario(
    id: 'usr-guardia',
    nombre: 'Marta Guardia',
    correo: 'guardia@securityaccess.com',
    rol: RolUsuario.guardia,
    estado: EstadoCuenta.activo,
  );
  const residente = Usuario(
    id: 'usr-residente',
    nombre: 'Luis Residente',
    correo: 'residente@securityaccess.com',
    rol: RolUsuario.residente,
    estado: EstadoCuenta.activo,
  );

  test(
    'la entrada avisa al residente actual y no incluye la identificación',
    () async {
      final invitaciones = InMemoryInvitacionRepository();
      final viviendas = InMemoryViviendaRepository(const [
        Vivienda(
          id: 'viv-1',
          numero: '101',
          direccion: 'Calle Uno',
          estado: EstadoVivienda.asignada,
          residenteId: 'usr-residente',
          residenteNombre: 'Luis Residente',
        ),
      ]);
      await invitaciones.guardar(
        Invitacion(
          id: 'inv-1',
          viviendaId: 'viv-1',
          viviendaNumero: '101',
          residenteId: 'usr-anterior',
          nombreVisitante: 'Ana Visitante',
          entrada: DateTime(2026, 11, 24, 10),
          salida: DateTime(2026, 11, 24, 18),
          codigoQr: 'SA-000001',
          estado: EstadoInvitacion.activa,
          estadoVisita: EstadoVisita.sinEntrada,
        ),
      );
      final leer = LeerQr(invitaciones, viviendas, ahora: () => ahora);
      final registrar = RegistrarEntrada(
        invitaciones,
        leer,
        ahora: () => ahora,
        notificar: NotificarEventoVisita(invitaciones, viviendas),
      );
      final resultado = await registrar(
        guardia: guardia,
        codigo: 'SA-000001',
        tipo: TipoIdentificacion.ine,
        numero: 'ABC123',
        identidadCoincide: true,
      );
      expect(resultado, isA<EntradaRegistrada>());
      final avisos = await ConsultarNotificaciones(invitaciones)(residente);
      expect(avisos, hasLength(1));
      expect(avisos.single.texto, 'Ana Visitante entró a las 12:00');
      expect(avisos.single.texto.contains('ABC123'), isFalse);
    },
  );

  test(
    'el reporte muestra el historial completo y destaca la visita sin salida',
    () async {
      final invitaciones = InMemoryInvitacionRepository(
        visitas: [
          Visita(
            id: 'vis-1',
            viviendaId: 'viv-1',
            viviendaNumero: '101',
            residenteId: 'usr-anterior',
            nombreVisitante: 'Ana Visitante',
            fecha: DateTime(2026, 11, 20, 9),
            entrada: DateTime(2026, 11, 20, 9),
            salida: DateTime(2026, 11, 20, 11),
            estado: EstadoVisita.completada,
            guardiaId: 'usr-guardia',
            tipoIdentificacion: 'INE',
            numeroIdentificacion: 'ABC123',
          ),
          Visita(
            id: 'vis-2',
            viviendaId: 'viv-1',
            viviendaNumero: '101',
            residenteId: 'usr-residente',
            nombreVisitante: 'Bruno',
            fecha: DateTime(2026, 11, 24, 8),
            entrada: DateTime(2026, 11, 24, 8),
            estado: EstadoVisita.dentro,
            guardiaId: 'usr-guardia',
          ),
        ],
      );
      await invitaciones.guardarRechazo(
        AccesoRechazado(
          id: 'rec-1',
          codigoQr: 'SA-000009',
          guardiaId: 'usr-guardia',
          fecha: DateTime(2026, 11, 24, 7),
          motivo: MotivoRechazo.vencido,
          viviendaNumero: '101',
          nombreVisitante: 'Carla',
        ),
      );
      final reporte = ConsultarReporteAccesos(
        invitaciones,
        InMemoryAuthRepository(CuentasSemilla.registros),
      );
      final todo = await reporte(vivienda: '101');
      expect(todo.map((fila) => fila.visitante), [
        'Bruno',
        'Carla',
        'Ana Visitante',
      ]);
      expect(todo.first.sinSalida, isTrue);
      expect(todo.first.guardia, 'Marta Guardia');
      expect(todo.last.identificacion, 'INE ABC123');
      final dentro = await reporte(estado: EstadoVisita.dentro.etiqueta);
      expect(dentro.single.visitante, 'Bruno');
    },
  );

  test('un fallo al notificar no impide la entrada', () async {
    final invitaciones = InMemoryInvitacionRepository();
    final viviendas = InMemoryViviendaRepository(const [
      Vivienda(
        id: 'viv-1',
        numero: '101',
        direccion: 'Calle Uno',
        estado: EstadoVivienda.asignada,
        residenteId: 'usr-residente',
      ),
    ]);
    await invitaciones.guardar(
      Invitacion(
        id: 'inv-1',
        viviendaId: 'viv-1',
        viviendaNumero: '101',
        residenteId: 'usr-residente',
        nombreVisitante: 'Ana Visitante',
        entrada: DateTime(2026, 11, 24, 10),
        salida: DateTime(2026, 11, 24, 18),
        codigoQr: 'SA-000001',
        estado: EstadoInvitacion.activa,
        estadoVisita: EstadoVisita.sinEntrada,
      ),
    );
    final leer = LeerQr(invitaciones, viviendas, ahora: () => ahora);
    final registrar = RegistrarEntrada(
      invitaciones,
      leer,
      ahora: () => ahora,
      notificar: NotificarEventoVisita(_RepoQueFalla(), viviendas),
    );
    final resultado = await registrar(
      guardia: guardia,
      codigo: 'SA-000001',
      tipo: TipoIdentificacion.ine,
      numero: 'ABC123',
      identidadCoincide: true,
    );
    expect(resultado, isA<EntradaRegistrada>());
    expect(await invitaciones.listarVisitas(), hasLength(1));
  });
}

class _RepoQueFalla extends InMemoryInvitacionRepository {
  @override
  Future<String> reservarIdNotificacion() async {
    throw StateError('fallo');
  }
}
