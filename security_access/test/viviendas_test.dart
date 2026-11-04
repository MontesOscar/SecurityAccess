import 'package:flutter_test/flutter_test.dart';
import 'package:security_access/data/repositories/in_memory_vivienda_repository.dart';
import 'package:security_access/domain/entities/estado_vivienda.dart';
import 'package:security_access/domain/entities/vivienda.dart';
import 'package:security_access/domain/usecases/cambiar_estado_vivienda.dart';
import 'package:security_access/domain/usecases/consultar_viviendas.dart';
import 'package:security_access/domain/usecases/crear_vivienda.dart';
import 'package:security_access/domain/usecases/editar_vivienda.dart';
import 'package:security_access/domain/usecases/listar_viviendas_asignables.dart';
import 'package:security_access/domain/usecases/resultado_cambio_estado_vivienda.dart';
import 'package:security_access/domain/usecases/resultado_crear_vivienda.dart';
import 'package:security_access/domain/usecases/resultado_editar_vivienda.dart';

void main() {
  late InMemoryViviendaRepository repositorio;
  late CrearVivienda crear;
  late ConsultarViviendas consultar;
  late EditarVivienda editar;
  late CambiarEstadoVivienda cambiarEstado;

  setUp(() {
    repositorio = InMemoryViviendaRepository();
    crear = CrearVivienda(repositorio);
    consultar = ConsultarViviendas(repositorio);
    editar = EditarVivienda(repositorio);
    cambiarEstado = CambiarEstadoVivienda(repositorio);
  });

  test('crea una vivienda disponible y rechaza el número repetido', () async {
    final creada = await crear(numero: ' 101 ', direccion: ' Calle 1 ');
    expect(creada, isA<ViviendaCreada>());
    final vivienda = (creada as ViviendaCreada).vivienda;
    expect(vivienda.numero, '101');
    expect(vivienda.direccion, 'Calle 1');
    expect(vivienda.estado, EstadoVivienda.disponible);
    expect(vivienda.residenteId, isNull);

    final repetida = await crear(numero: '101', direccion: 'Otra calle');
    expect(repetida, isA<ViviendaYaRegistrada>());

    final mayusculas = await crear(numero: 'A-1', direccion: 'Calle 2');
    expect(mayusculas, isA<ViviendaCreada>());
    final duplicada = await crear(numero: 'a-1', direccion: 'Calle 3');
    expect(duplicada, isA<ViviendaYaRegistrada>());
  });

  test('ordena por número y filtra por estado, número o residente', () async {
    await repositorio.guardar(
      const Vivienda(
        id: 'viv-10',
        numero: '10',
        direccion: 'Calle Diez',
        estado: EstadoVivienda.disponible,
      ),
    );
    await repositorio.guardar(
      const Vivienda(
        id: 'viv-2',
        numero: '2',
        direccion: 'Calle Dos',
        estado: EstadoVivienda.asignada,
        residenteId: 'usr-1',
        residenteNombre: 'Luis Residente',
      ),
    );
    await repositorio.guardar(
      const Vivienda(
        id: 'viv-4',
        numero: '4',
        direccion: 'Calle Cuatro',
        estado: EstadoVivienda.inactiva,
      ),
    );

    final todas = await consultar();
    expect(todas.map((vivienda) => vivienda.numero), ['2', '4', '10']);

    final asignadas = await consultar(estado: EstadoVivienda.asignada);
    expect(asignadas.single.residenteNombre, 'Luis Residente');

    final porResidente = await consultar(texto: 'luis');
    expect(porResidente.single.numero, '2');

    final porNumero = await consultar(texto: '10');
    expect(porNumero.single.direccion, 'Calle Diez');
  });

  test('editar cambia la dirección y conserva número e historial', () async {
    final creada = await crear(numero: '8', direccion: 'Calle Vieja');
    final vivienda = (creada as ViviendaCreada).vivienda;

    final actualizada = await editar(
      id: vivienda.id,
      direccion: ' Calle Nueva ',
      residenteId: vivienda.residenteId,
      residenteNombre: vivienda.residenteNombre,
      confirmarCambioResidente: false,
    );

    expect(actualizada, isA<ViviendaActualizada>());
    final viviendaActualizada = (actualizada as ViviendaActualizada).vivienda;
    expect(viviendaActualizada.id, vivienda.id);
    expect(viviendaActualizada.numero, '8');
    expect(viviendaActualizada.direccion, 'Calle Nueva');
    expect(await repositorio.buscarPorId(vivienda.id), isNotNull);
  });

  test(
    'cambiar de residente pide confirmación y conserva el anterior',
    () async {
      await repositorio.guardar(
        const Vivienda(
          id: 'viv-1',
          numero: '3',
          direccion: 'Calle 3',
          estado: EstadoVivienda.asignada,
          residenteId: 'usr-anterior',
          residenteNombre: 'Ana Anterior',
        ),
      );

      final sinConfirmar = await editar(
        id: 'viv-1',
        direccion: 'Calle 3',
        residenteId: 'usr-nuevo',
        residenteNombre: 'Luis Nuevo',
        confirmarCambioResidente: false,
      );
      expect(sinConfirmar, isA<EdicionRequiereConfirmacion>());
      expect(
        (await repositorio.buscarPorId('viv-1'))!.residenteId,
        'usr-anterior',
      );

      final confirmada = await editar(
        id: 'viv-1',
        direccion: 'Calle 3',
        residenteId: 'usr-nuevo',
        residenteNombre: 'Luis Nuevo',
        confirmarCambioResidente: true,
      );
      final vivienda = (confirmada as ViviendaActualizada).vivienda;
      expect(vivienda.residenteNombre, 'Luis Nuevo');
      expect(vivienda.estado, EstadoVivienda.asignada);
      expect(vivienda.numero, '3');
    },
  );

  test('desactivar oculta la vivienda del desplegable y reactivar conserva al residente', () async {
    await repositorio.guardar(
      const Vivienda(
        id: 'viv-1',
        numero: '5',
        direccion: 'Calle 5',
        estado: EstadoVivienda.asignada,
        residenteId: 'usr-1',
        residenteNombre: 'Luis Residente',
      ),
    );
    await repositorio.guardar(
      const Vivienda(
        id: 'viv-2',
        numero: '6',
        direccion: 'Calle 6',
        estado: EstadoVivienda.disponible,
      ),
    );

    final desactivada = await cambiarEstado(id: 'viv-1', activar: false);
    expect(desactivada, isA<EstadoViviendaActualizado>());
    final inactiva = (desactivada as EstadoViviendaActualizado).vivienda;
    expect(inactiva.estado, EstadoVivienda.inactiva);
    expect(inactiva.residenteNombre, 'Luis Residente');

    final asignables = await ListarViviendasAsignables(consultar)();
    expect(asignables.map((vivienda) => vivienda.numero), ['6']);

    final reactivada = await cambiarEstado(id: 'viv-1', activar: true);
    final asignada = (reactivada as EstadoViviendaActualizado).vivienda;
    expect(asignada.estado, EstadoVivienda.asignada);
    expect(asignada.residenteId, 'usr-1');
  });
}
