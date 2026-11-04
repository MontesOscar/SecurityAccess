import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:security_access/app/crear_aplicacion.dart';

void main() {
  Future<void> iniciar(
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

  Future<void> cerrarSesion(WidgetTester tester) async {
    await tester.tap(find.byKey(const Key('menu-usuario')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cerrar sesión'));
    await tester.pumpAndSettle();
  }

  testWidgets('marca correo y contraseña como obligatorios', (tester) async {
    await tester.pumpWidget(crearAplicacion());

    expect(find.text('Correo electrónico *'), findsOneWidget);
    expect(find.text('Contraseña *'), findsOneWidget);
    expect(find.text('Recuperar contraseña'), findsOneWidget);

    await tester.tap(find.byKey(const Key('boton-iniciar-sesion')));
    await tester.pump();

    expect(find.text('El correo es obligatorio'), findsOneWidget);
    expect(find.text('La contraseña es obligatoria'), findsOneWidget);
  });

  testWidgets('muestra credenciales inválidas', (tester) async {
    await tester.pumpWidget(crearAplicacion());

    await iniciar(
      tester,
      correo: 'admin@securityaccess.com',
      contrasena: 'incorrecta',
    );

    expect(find.text('Credenciales inválidas'), findsOneWidget);
    expect(find.byKey(const Key('menu-administrador')), findsNothing);
  });

  testWidgets('muestra cuenta desactivada', (tester) async {
    await tester.pumpWidget(crearAplicacion());

    await iniciar(
      tester,
      correo: 'inactivo@securityaccess.com',
      contrasena: 'Inactivo1',
    );

    expect(find.text('Su cuenta se encuentra desactivada'), findsOneWidget);
    expect(find.byKey(const Key('menu-residente')), findsNothing);
  });

  testWidgets(
    'el administrador entra a su menú y la bienvenida usa su nombre',
    (tester) async {
      await tester.pumpWidget(crearAplicacion());

      await iniciar(
        tester,
        correo: 'admin@securityaccess.com',
        contrasena: 'Admin1234',
      );

      expect(find.byKey(const Key('menu-administrador')), findsOneWidget);
      expect(find.text('Bienvenido, Ana Administradora'), findsOneWidget);
      expect(find.byKey(const Key('menu-residente')), findsNothing);
      expect(find.byKey(const Key('menu-guardia')), findsNothing);
    },
  );

  testWidgets('el residente entra a su menú', (tester) async {
    await tester.pumpWidget(crearAplicacion());

    await iniciar(
      tester,
      correo: 'residente@securityaccess.com',
      contrasena: 'Residente1',
    );

    expect(find.byKey(const Key('menu-residente')), findsOneWidget);
    expect(find.text('Bienvenido, Luis Residente'), findsOneWidget);
  });

  testWidgets('el guardia entra a su menú', (tester) async {
    await tester.pumpWidget(crearAplicacion());

    await iniciar(
      tester,
      correo: 'guardia@securityaccess.com',
      contrasena: 'Guardia1234',
    );

    expect(find.byKey(const Key('menu-guardia')), findsOneWidget);
    expect(find.text('Bienvenido, Marta Guardia'), findsOneWidget);
  });

  testWidgets('recuperar contraseña abre la pantalla prevista', (tester) async {
    await tester.pumpWidget(crearAplicacion());

    await tester.tap(find.byKey(const Key('enlace-recuperar-contrasena')));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('pagina-recuperar-contrasena')),
      findsOneWidget,
    );

    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('pagina-recuperar-contrasena')), findsNothing);
    expect(find.byKey(const Key('boton-iniciar-sesion')), findsOneWidget);
  });

  testWidgets(
    'cerrar sesión vuelve al inicio y no deja el menú en el historial',
    (tester) async {
      await tester.pumpWidget(crearAplicacion());

      await iniciar(
        tester,
        correo: 'admin@securityaccess.com',
        contrasena: 'Admin1234',
      );
      await cerrarSesion(tester);

      expect(find.byKey(const Key('boton-iniciar-sesion')), findsOneWidget);
      expect(find.byKey(const Key('menu-administrador')), findsNothing);
      expect(find.text('Bienvenido, Ana Administradora'), findsNothing);

      final navigator = tester.state<NavigatorState>(find.byType(Navigator));
      expect(navigator.canPop(), isFalse);
    },
  );
}
