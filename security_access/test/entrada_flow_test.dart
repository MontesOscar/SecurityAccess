import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:security_access/app/crear_aplicacion.dart';
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

  testWidgets('el guardia autoriza la entrada cuando la identidad coincide', (
    tester,
  ) async {
    await prepararInvitacion(tester);
    await entrar(
      tester,
      correo: 'guardia@securityaccess.com',
      contrasena: 'Guardia1234',
    );
    await tocar(tester, const Key('abrir-registrar-entrada'));

    expect(find.byKey(const Key('selector-tipo-identificacion')), findsNothing);
    expect(find.byKey(const Key('boton-confirmar-entrada')), findsNothing);

    await tester.enterText(
      find.byKey(const Key('campo-codigo-leido')),
      'SA-000001',
    );
    await tocar(tester, const Key('boton-leer-codigo'));
    expect(find.text('Válida'), findsOneWidget);
    expect(find.text('Visitante: Ana Visitante'), findsOneWidget);
    expect(
      tester
          .widget<FilledButton>(
            find.byKey(const Key('boton-confirmar-entrada')),
          )
          .onPressed,
      isNull,
    );

    await elegirTexto(tester, const Key('selector-tipo-identificacion'), 'INE');
    await tester.enterText(
      find.byKey(const Key('campo-numero-identificacion')),
      'ABC123',
    );
    await tocar(tester, const Key('opcion-no-coincide'));
    expect(
      tester
          .widget<FilledButton>(
            find.byKey(const Key('boton-confirmar-entrada')),
          )
          .onPressed,
      isNull,
    );
    await tocar(tester, const Key('opcion-coincide'));
    await tester.tap(find.byKey(const Key('boton-confirmar-entrada')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Entrada registrada correctamente'), findsWidgets);
    await cerrarAviso(tester);

    await tester.pageBack();
    await tester.pumpAndSettle();
    await salir(tester);
    await entrar(
      tester,
      correo: 'carlos@securityaccess.com',
      contrasena: 'Acceso123',
    );
    await tocar(tester, const Key('abrir-historial'));
    expect(find.text('Ana Visitante'), findsOneWidget);
    expect(find.text('Dentro'), findsOneWidget);
  });

  testWidgets('un QR inválido no abre la identificación y se puede rechazar', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1400, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(crearAplicacion());
    await entrar(
      tester,
      correo: 'guardia@securityaccess.com',
      contrasena: 'Guardia1234',
    );
    await tocar(tester, const Key('abrir-registrar-entrada'));
    await tester.tap(find.byKey(const Key('boton-qr-ilegible')));
    await tester.pump();
    expect(find.text('No se pudo leer el código'), findsWidgets);
    expect(find.byKey(const Key('selector-tipo-identificacion')), findsNothing);

    await tester.pageBack();
    await tester.pumpAndSettle();
    await tocar(tester, const Key('abrir-registrar-entrada'));
    await tester.enterText(
      find.byKey(const Key('campo-codigo-leido')),
      'ajeno',
    );
    await tocar(tester, const Key('boton-leer-codigo'));
    expect(find.text('Código QR inválido'), findsOneWidget);
    expect(find.byKey(const Key('selector-tipo-identificacion')), findsNothing);

    await tocar(tester, const Key('boton-rechazar-acceso'));
    await elegirTexto(
      tester,
      const Key('selector-motivo-rechazo'),
      'QR inválido',
    );
    await tester.tap(find.byKey(const Key('confirmar-rechazo')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Acceso rechazado correctamente'), findsWidgets);
  });
}
