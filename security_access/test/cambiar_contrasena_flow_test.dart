import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:security_access/app/crear_aplicacion.dart';

void main() {
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

  Future<void> llenar(
    WidgetTester tester, {
    required String actual,
    required String nueva,
    required String confirmacion,
  }) async {
    await tester.enterText(
      find.byKey(const Key('campo-contrasena-actual')),
      actual,
    );
    await tester.enterText(
      find.byKey(const Key('campo-contrasena-nueva')),
      nueva,
    );
    await tester.enterText(
      find.byKey(const Key('campo-contrasena-confirmacion')),
      confirmacion,
    );
    await tester.tap(find.byKey(const Key('boton-guardar-contrasena')));
    await tester.pumpAndSettle();
  }

  testWidgets('R3: cambiar la contraseña desde el menú de perfil', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1400, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(crearAplicacion());
    await entrar(
      tester,
      correo: 'residente@securityaccess.com',
      contrasena: 'Residente1',
    );

    await tester.tap(find.byKey(const Key('menu-usuario')));
    await tester.pumpAndSettle();
    expect(find.text('Cambiar contraseña'), findsOneWidget);
    await tester.tap(find.text('Cambiar contraseña'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('pagina-cambiar-contrasena')), findsOneWidget);

    await llenar(
      tester,
      actual: 'Equivocada1',
      nueva: 'Nueva1234',
      confirmacion: 'Nueva1234',
    );
    expect(find.text('La contraseña actual es incorrecta'), findsOneWidget);

    await llenar(
      tester,
      actual: 'Residente1',
      nueva: 'Nueva1234',
      confirmacion: 'Distinta1234',
    );
    expect(find.text('Las contraseñas no coinciden'), findsOneWidget);

    await llenar(
      tester,
      actual: 'Residente1',
      nueva: 'Nueva1234',
      confirmacion: 'Nueva1234',
    );
    expect(find.text('Contraseña actualizada correctamente'), findsOneWidget);
    expect(find.byKey(const Key('menu-residente')), findsOneWidget);

    ScaffoldMessenger.of(tester.element(find.byType(Scaffold).first))
        .hideCurrentSnackBar();
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('menu-usuario')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cerrar sesión'));
    await tester.pumpAndSettle();
    await entrar(
      tester,
      correo: 'residente@securityaccess.com',
      contrasena: 'Nueva1234',
    );
    expect(find.byKey(const Key('menu-residente')), findsOneWidget);
  });
}
