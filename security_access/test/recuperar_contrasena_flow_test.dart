import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:security_access/app/crear_aplicacion.dart';

void main() {
  Future<void> preparar(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1400, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(crearAplicacion());
    await tester.tap(find.byKey(const Key('enlace-recuperar-contrasena')));
    await tester.pumpAndSettle();
  }

  Future<void> pedirCodigo(WidgetTester tester, String correo) async {
    await tester.enterText(
      find.byKey(const Key('campo-correo-recuperacion')),
      correo,
    );
    await tester.tap(find.byKey(const Key('boton-enviar-instrucciones')));
    await tester.pumpAndSettle();
  }

  String codigoMostrado(WidgetTester tester) {
    return tester
        .widget<SelectableText>(
          find.byKey(const Key('valor-codigo-demostracion')),
        )
        .data!;
  }

  Future<void> escribirCodigo(WidgetTester tester, String codigo) async {
    await tester.enterText(
      find.byKey(const Key('campo-codigo-recuperacion')),
      codigo,
    );
    await tester.tap(find.byKey(const Key('boton-validar-codigo')));
    await tester.pumpAndSettle();
  }

  testWidgets('R2: un correo no registrado ve lo mismo y su código no sirve', (
    tester,
  ) async {
    await preparar(tester);
    await pedirCodigo(tester, 'nadie@securityaccess.com');

    expect(
      find.text('Si está registrado, recibirás instrucciones'),
      findsOneWidget,
    );
    expect(find.byKey(const Key('codigo-demostracion')), findsOneWidget);
    expect(codigoMostrado(tester), hasLength(6));
    expect(find.byKey(const Key('campo-codigo-recuperacion')), findsOneWidget);

    await escribirCodigo(tester, codigoMostrado(tester));
    expect(find.text('El código no es válido o ya venció'), findsOneWidget);
    expect(find.byKey(const Key('campo-nueva-recuperacion')), findsNothing);
  });

  testWidgets('R2: un correo registrado ve la misma pantalla y con el código '
      'cambia la contraseña', (tester) async {
    await preparar(tester);
    await pedirCodigo(tester, 'residente@securityaccess.com');
    expect(
      find.text('Si está registrado, recibirás instrucciones'),
      findsOneWidget,
    );
    expect(find.byKey(const Key('codigo-demostracion')), findsOneWidget);

    await escribirCodigo(tester, '000000x');
    expect(find.text('El código no es válido o ya venció'), findsOneWidget);

    await escribirCodigo(tester, codigoMostrado(tester));
    expect(find.byKey(const Key('campo-nueva-recuperacion')), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('campo-nueva-recuperacion')),
      'Nueva1234',
    );
    await tester.enterText(
      find.byKey(const Key('campo-confirmar-recuperacion')),
      'Nueva1234',
    );
    await tester.tap(find.byKey(const Key('boton-restablecer-contrasena')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('pagina-recuperar-contrasena')), findsNothing);
    expect(find.byKey(const Key('boton-iniciar-sesion')), findsOneWidget);
    expect(
      find.text(
        'Contraseña actualizada correctamente. '
        'Inicia sesión con tu nueva contraseña.',
      ),
      findsOneWidget,
    );

    await tester.enterText(
      find.byKey(const Key('campo-correo')),
      'residente@securityaccess.com',
    );
    await tester.enterText(
      find.byKey(const Key('campo-contrasena')),
      'Nueva1234',
    );
    await tester.tap(find.byKey(const Key('boton-iniciar-sesion')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('menu-residente')), findsOneWidget);
  });
}
