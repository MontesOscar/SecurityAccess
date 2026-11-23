import 'package:flutter_test/flutter_test.dart';
import 'package:security_access/data/repositories/in_memory_invitacion_repository.dart';
import 'package:security_access/domain/entities/estado_cuenta.dart';
import 'package:security_access/domain/entities/estado_visita.dart';
import 'package:security_access/domain/entities/rol_usuario.dart';
import 'package:security_access/domain/entities/usuario.dart';
import 'package:security_access/domain/entities/visita.dart';
import 'package:security_access/domain/usecases/cierre_visita.dart';
import 'package:security_access/domain/usecases/consultar_visitas_dentro.dart';

void main() {
  const guardia = Usuario(
    id: 'usr-guardia',
    nombre: 'Marta Guardia',
    correo: 'guardia@securityaccess.com',
    rol: RolUsuario.guardia,
    estado: EstadoCuenta.activo,
  );
  late InMemoryInvitacionRepository repositorio;
  late ConsultarVisitasDentro consultar;

  Visita visita(
    String id, {
    required String vivienda,
    required DateTime? entrada,
    EstadoVisita estado = EstadoVisita.dentro,
    DateTime? salida,
  }) {
    return Visita(
      id: id,
      viviendaId: 'viv-$vivienda',
      viviendaNumero: vivienda,
      residenteId: 'usr-1',
      nombreVisitante: 'Visitante $id',
      fecha: entrada ?? DateTime(2026, 11, 5),
      entrada: entrada,
      salida: salida,
      estado: estado,
      tipoIdentificacion: 'INE',
      numeroIdentificacion: 'ID-$id',
    );
  }

  setUp(() {
    repositorio = InMemoryInvitacionRepository(
      visitas: [
        visita('c', vivienda: '102', entrada: DateTime(2026, 11, 5, 14)),
        visita('a', vivienda: '101', entrada: DateTime(2026, 11, 5, 9)),
        visita('b', vivienda: '101', entrada: DateTime(2026, 11, 5, 11)),
        visita(
          'completada',
          vivienda: '101',
          entrada: DateTime(2026, 11, 5, 8),
          salida: DateTime(2026, 11, 5, 10),
          estado: EstadoVisita.completada,
        ),
        visita(
          'sin-entrada',
          vivienda: '101',
          entrada: null,
          estado: EstadoVisita.sinEntrada,
        ),
      ],
    );
    consultar = ConsultarVisitasDentro(repositorio);
  });

  test('solo lista visitas "Dentro" ordenadas por hora de entrada', () async {
    final lista = await consultar(guardia: guardia);
    expect([for (final v in lista) v.id], ['a', 'b', 'c']);
  });

  test('permite filtrar por vivienda', () async {
    final lista = await consultar(guardia: guardia, viviendaId: 'viv-102');
    expect([for (final v in lista) v.id], ['c']);
  });

  test('una visita desaparece de la lista al registrar su salida', () async {
    final cierre = CierreVisita(repositorio);
    final activa = await cierre.buscarActiva('a');
    await cierre.cerrar(
      visita: activa!,
      guardia: guardia,
      momento: DateTime(2026, 11, 5, 15),
    );
    final lista = await consultar(guardia: guardia);
    expect([for (final v in lista) v.id], ['b', 'c']);
  });

  test('respeta los permisos del guardia', () async {
    final lista = await consultar(
      guardia: const Usuario(
        id: 'usr-1',
        nombre: 'Luis',
        correo: 'luis@securityaccess.com',
        rol: RolUsuario.residente,
        estado: EstadoCuenta.activo,
      ),
    );
    expect(lista, isEmpty);
  });
}
