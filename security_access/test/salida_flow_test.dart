import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:security_access/app/crear_aplicacion.dart';
import 'package:security_access/domain/entities/estado_visita.dart';
import 'package:security_access/domain/entities/visita.dart';
import 'package:security_access/presentation/entrada/simulador_lectura.dart';

void main() {
  setUp(() => mostrarSimuladorLectura = true);
  tearDown(() => mostrarSimuladorLectura = false);

  Future<void> cerrarAviso(WidgetTester tester) async {
    ScaffoldMessenger.of(tester.element(find.byType(Scaffold).first))
        .hideCurrentSnackBar();
    await tester.pumpAndSettle();
  }

  Future<void> tocar(WidgetTester tester, Key key) async {
    final finder = find.byKey(key);
    await tester.ensureVisible(finder);
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  Future<void> elegirTexto(WidgetTester tester, Key key, String texto) async {
    await tocar(tester, key);
    await tester.tap(find.text(texto).last);
    await tester.pumpAndSettle();
  }

  Future<void> entrar(
    WidgetTester tester, {
    required String correo,
    required String contrasena,
  }) async {
    await tester.enterText(find.byKey(const Key('campo-correo')), correo);
    await tester.enterText(
      find.byKey(const Key('campo-contrasena')),
      contrasena,
    );
    await tester.tap(find.byKey(const Key('boton-iniciar-sesion')));
    await tester.pumpAndSettle();
  }

  Future<void> salir(WidgetTester tester) async {
    await tocar(tester, const Key('menu-usuario'));
    await tester.tap(find.text('Cerrar sesión'));
    await tester.pumpAndSettle();
  }

  String fecha(DateTime valor) {
    final dia = valor.day.toString().padLeft(2, '0');
    final mes = valor.month.toString().padLeft(2, '0');
    return '$dia/$mes/${valor.year}';
  }

  Future<void> prepararInvitacion(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1400, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(crearAplicacion());
    await entrar(
      tester,
      correo: 'admin@securityaccess.com',
      contrasena: 'Admin1234',
    );
    await tocar(tester, const Key('abrir-viviendas'));
    await tocar(tester, const Key('boton-nueva-vivienda'));
    await tester.enterText(find.byKey(const Key('campo-numero')), '101');
    await tester.enterText(
      find.byKey(const Key('campo-direccion')),
      'Calle Uno',
    );
    await tester.tap(find.byKey(const Key('boton-guardar-vivienda')));
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tocar(tester, const Key('abrir-usuarios'));
    await tocar(tester, const Key('boton-nuevo-usuario'));
    await tester.enterText(
      find.byKey(const Key('campo-nombre-usuario')),
      'Carlos Residente',
    );
    await tester.enterText(
      find.byKey(const Key('campo-correo-usuario')),
      'carlos@securityaccess.com',
    );
    await tester.enterText(
      find.byKey(const Key('campo-telefono-usuario')),
      '5551234567',
    );
    await elegirTexto(tester, const Key('selector-rol'), 'Residente');
    await elegirTexto(tester, const Key('selector-vivienda'), '101');
    await tester.tap(find.byKey(const Key('boton-guardar-usuario')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await cerrarAviso(tester);
    await tester.pageBack();
    await tester.pumpAndSettle();
    await salir(tester);
    await entrar(
      tester,
      correo: 'carlos@securityaccess.com',
      contrasena: 'Acceso123',
    );
    await tocar(tester, const Key('abrir-invitaciones'));
    await tocar(tester, const Key('boton-nueva-invitacion'));
    final hoy = DateTime.now();
    await tester.enterText(
      find.byKey(const Key('campo-nombre-visitante')),
      'Ana Visitante',
    );
    await tester.enterText(
      find.byKey(const Key('campo-fecha-entrada')),
      fecha(hoy),
    );
    await tester.enterText(
      find.byKey(const Key('campo-hora-entrada')),
      '00:00',
    );
    await tester.enterText(
      find.byKey(const Key('campo-fecha-salida')),
      fecha(hoy),
    );
    await tester.enterText(find.byKey(const Key('campo-hora-salida')), '23:59');
    await tester.tap(find.byKey(const Key('boton-guardar-invitacion')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await cerrarAviso(tester);
    await tester.pageBack();
    await tester.pumpAndSettle();
    await salir(tester);
  }

  Future<void> registrarEntradaComoGuardia(WidgetTester tester) async {
    await entrar(
      tester,
      correo: 'guardia@securityaccess.com',
      contrasena: 'Guardia1234',
    );
    await tocar(tester, const Key('abrir-registrar-entrada'));
    await tester.enterText(
      find.byKey(const Key('campo-codigo-leido')),
      'SA-000001',
    );
    await tocar(tester, const Key('boton-leer-codigo'));
    await elegirTexto(tester, const Key('selector-tipo-identificacion'), 'INE');
    await tester.enterText(
      find.byKey(const Key('campo-numero-identificacion')),
      'ABC123',
    );
    await tocar(tester, const Key('opcion-coincide'));
    await tester.tap(find.byKey(const Key('boton-confirmar-entrada')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await cerrarAviso(tester);
    await tester.pageBack();
    await tester.pumpAndSettle();
  }

  Future<void> leerSalida(WidgetTester tester, String codigo) async {
    await tocar(tester, const Key('abrir-registrar-salida'));
    await tester.enterText(
      find.byKey(const Key('campo-codigo-salida')),
      codigo,
    );
    await tocar(tester, const Key('boton-leer-codigo-salida'));
  }

  testWidgets('R16: sin entrada activa muestra "No hay registro de entrada"', (
    tester,
  ) async {
    await prepararInvitacion(tester);
    await entrar(
      tester,
      correo: 'guardia@securityaccess.com',
      contrasena: 'Guardia1234',
    );
    await tocar(tester, const Key('abrir-registrar-salida'));
    // La lectura del código aparece de inmediato, sin pasos previos.
    expect(find.byKey(const Key('campo-codigo-salida')), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();

    await leerSalida(tester, 'SA-000001');
    expect(find.text('No hay registro de entrada'), findsOneWidget);
    expect(find.byKey(const Key('boton-confirmar-salida')), findsNothing);
  });

  testWidgets('R16: con entrada muestra los datos y al confirmar registra la '
      'hora de salida', (tester) async {
    await prepararInvitacion(tester);
    await registrarEntradaComoGuardia(tester);

    await leerSalida(tester, 'SA-000001');
    expect(find.text('Visitante: Ana Visitante'), findsOneWidget);
    expect(find.text('Vivienda: 101'), findsOneWidget);
    expect(find.text('INE: ABC123'), findsOneWidget);
    expect(find.byKey(const Key('selector-tipo-identificacion')), findsNothing);
    expect(find.byKey(const Key('hora-salida')), findsNothing);

    await tester.tap(find.byKey(const Key('boton-confirmar-salida')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Salida registrada correctamente'), findsWidgets);
    expect(find.byKey(const Key('hora-salida')), findsOneWidget);
    expect(find.byKey(const Key('boton-confirmar-salida')), findsNothing);
    await cerrarAviso(tester);

    await tester.pageBack();
    await tester.pumpAndSettle();
    await leerSalida(tester, 'SA-000001');
    expect(find.text('No hay registro de entrada'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    await salir(tester);
    await entrar(
      tester,
      correo: 'carlos@securityaccess.com',
      contrasena: 'Acceso123',
    );
    await tocar(tester, const Key('abrir-historial'));
    expect(find.text('Completada'), findsOneWidget);
  });

  testWidgets('R21: la visita aparece dentro y desaparece al registrar la '
      'salida', (tester) async {
    await prepararInvitacion(tester);
    await registrarEntradaComoGuardia(tester);

    await tocar(tester, const Key('abrir-visitas-dentro'));
    expect(find.text('Ana Visitante'), findsOneWidget);
    expect(find.textContaining('Vivienda: 101'), findsOneWidget);
    expect(find.textContaining('INE: ABC123'), findsOneWidget);
    expect(find.textContaining('Entrada: '), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();

    await leerSalida(tester, 'SA-000001');
    await tester.tap(find.byKey(const Key('boton-confirmar-salida')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await cerrarAviso(tester);
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tocar(tester, const Key('abrir-visitas-dentro'));
    expect(find.text('Ana Visitante'), findsNothing);
    expect(find.byKey(const Key('sin-visitas-dentro')), findsOneWidget);
  });

  testWidgets('R21: la lista se ordena por hora de entrada y se filtra por '
      'vivienda', (tester) async {
    tester.view.physicalSize = const Size(1400, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    Visita dentro(String id, String nombre, String vivienda, int hora) {
      return Visita(
        id: id,
        viviendaId: 'viv-$vivienda',
        viviendaNumero: vivienda,
        residenteId: 'usr-1',
        nombreVisitante: nombre,
        fecha: DateTime(2026, 11, 5, hora),
        entrada: DateTime(2026, 11, 5, hora),
        estado: EstadoVisita.dentro,
        tipoIdentificacion: 'INE',
        numeroIdentificacion: 'ID-$id',
      );
    }

    await tester.pumpWidget(
      crearAplicacion(
        visitasIniciales: [
          dentro('vis-a', 'Beto Tarde', '102', 15),
          dentro('vis-b', 'Ana Temprano', '101', 9),
        ],
      ),
    );
    await entrar(
      tester,
      correo: 'guardia@securityaccess.com',
      contrasena: 'Guardia1234',
    );
    await tocar(tester, const Key('abrir-visitas-dentro'));
    final primero = tester.getTopLeft(find.text('Ana Temprano')).dy;
    final segundo = tester.getTopLeft(find.text('Beto Tarde')).dy;
    expect(primero, lessThan(segundo));

    await elegirTexto(tester, const Key('filtro-vivienda-dentro'), '102');
    expect(find.text('Beto Tarde'), findsOneWidget);
    expect(find.text('Ana Temprano'), findsNothing);
  });
}
