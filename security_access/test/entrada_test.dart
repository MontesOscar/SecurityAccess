import 'package:flutter_test/flutter_test.dart';
import 'package:security_access/data/repositories/in_memory_invitacion_repository.dart';
import 'package:security_access/data/repositories/in_memory_vivienda_repository.dart';
import 'package:security_access/domain/entities/estado_cuenta.dart';
import 'package:security_access/domain/entities/estado_invitacion.dart';
import 'package:security_access/domain/entities/estado_visita.dart';
import 'package:security_access/domain/entities/estado_vivienda.dart';
import 'package:security_access/domain/entities/invitacion.dart';
import 'package:security_access/domain/entities/motivo_rechazo.dart';
import 'package:security_access/domain/entities/rol_usuario.dart';
import 'package:security_access/domain/entities/tipo_identificacion.dart';
import 'package:security_access/domain/entities/usuario.dart';
import 'package:security_access/domain/entities/vivienda.dart';
import 'package:security_access/domain/usecases/leer_qr.dart';
import 'package:security_access/domain/usecases/rechazar_acceso.dart';
import 'package:security_access/domain/usecases/registrar_entrada.dart';
import 'package:security_access/domain/usecases/resultado_lectura_qr.dart';
import 'package:security_access/domain/usecases/resultado_rechazar_acceso.dart';
import 'package:security_access/domain/usecases/resultado_registrar_entrada.dart';

void main() {
  final ahora = DateTime(2026, 11, 5, 12);
  const guardia = Usuario(
    id: 'usr-guardia',
    nombre: 'Marta Guardia',
    correo: 'guardia@securityaccess.com',
    rol: RolUsuario.guardia,
    estado: EstadoCuenta.activo,
  );
  late InMemoryInvitacionRepository invitaciones;
  late LeerQr leer;
  late RegistrarEntrada registrar;
  late RechazarAcceso rechazar;

  Invitacion conHorario({
    required DateTime entrada,
    required DateTime salida,
    EstadoInvitacion estado = EstadoInvitacion.activa,
    String codigo = 'SA-000001',
    String id = 'inv-1',
  }) {
    return Invitacion(
      id: id,
      viviendaId: 'viv-1',
      viviendaNumero: '101',
      residenteId: 'usr-1',
      nombreVisitante: 'Ana Visitante',
      entrada: entrada,
      salida: salida,
      codigoQr: codigo,
      estado: estado,
      estadoVisita: EstadoVisita.sinEntrada,
    );
  }

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
      conHorario(
        entrada: DateTime(2026, 11, 5, 10),
        salida: DateTime(2026, 11, 5, 18),
      ),
    );
    leer = LeerQr(invitaciones, viviendas, ahora: () => ahora);
    registrar = RegistrarEntrada(invitaciones, leer, ahora: () => ahora);
    rechazar = RechazarAcceso(invitaciones, ahora: () => ahora);
  });

  test('clasifica el QR como válida, inválida o vencida', () async {
    expect((await leer('SA-000001')).etiqueta, 'Válida');
    expect((await leer('ajeno')).mensaje, LeerQr.mensajeInvalido);
    expect((await leer('   ')).mensaje, LeerQr.mensajeIlegible);

    await invitaciones.guardar(
      conHorario(
        id: 'inv-vencida',
        codigo: 'SA-VENCIDA',
        entrada: DateTime(2026, 11, 5, 8),
        salida: DateTime(2026, 11, 5, 9),
      ),
    );
    final vencida = await leer('SA-VENCIDA');
    expect(vencida.clasificacion, ClasificacionQr.vencida);
    expect(vencida.mensaje, 'Vencida');

    await invitaciones.guardar(
      conHorario(
        id: 'inv-cancelada',
        codigo: 'SA-CANCELADA',
        entrada: DateTime(2026, 11, 5, 10),
        salida: DateTime(2026, 11, 5, 18),
        estado: EstadoInvitacion.cancelada,
      ),
    );
    expect((await leer('SA-CANCELADA')).mensaje, 'Invitación cancelada');
  });

  test('confirma la entrada solo si la identidad coincide', () async {
    final lectura = await leer('SA-000001');
    final rechazada = await registrar(
      guardia: guardia,
      codigo: lectura.codigo,
      tipo: TipoIdentificacion.ine,
      numero: 'ABC123',
      identidadCoincide: false,
    );
    expect(rechazada, isA<EntradaNoAutorizada>());
    expect(await invitaciones.listarVisitas(), isEmpty);

    final creada = await registrar(
      guardia: guardia,
      codigo: 'SA-000001',
      tipo: TipoIdentificacion.ine,
      numero: ' ABC123 ',
      identidadCoincide: true,
    );
    expect(creada, isA<EntradaRegistrada>());
    final visita = (creada as EntradaRegistrada).visita;
    expect(visita.estado, EstadoVisita.dentro);
    expect(visita.numeroIdentificacion, 'ABC123');
    expect(visita.guardiaId, guardia.id);

    final actualizada = await invitaciones.buscarPorCodigo('SA-000001');
    expect(actualizada!.estado, EstadoInvitacion.usada);
    expect(actualizada.estadoVisita, EstadoVisita.dentro);
    expect((await leer('SA-000001')).mensaje, LeerQr.mensajeYaEntro);
  });

  test('un rechazo no crea la entrada', () async {
    final lectura = await leer('ajeno');
    final resultado = await rechazar(
      guardia: guardia,
      lectura: lectura,
      motivo: MotivoRechazo.qrInvalido,
      descripcion: '',
    );
    expect(resultado, isA<AccesoRechazadoRegistrado>());
    final registro = (resultado as AccesoRechazadoRegistrado).rechazo;
    expect(registro.guardiaId, guardia.id);
    expect(registro.motivo, MotivoRechazo.qrInvalido);
    expect(await invitaciones.listarVisitas(), isEmpty);

    final otro = await rechazar(
      guardia: guardia,
      lectura: lectura,
      motivo: MotivoRechazo.otro,
      descripcion: '   ',
    );
    expect(otro, isA<RechazoInvalido>());
  });
}
