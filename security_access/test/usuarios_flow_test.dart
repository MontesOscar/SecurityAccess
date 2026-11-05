import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:security_access/app/crear_aplicacion.dart';
import 'package:security_access/domain/entities/rol_usuario.dart';

void main() {
  Future<void> cerrarAviso(WidgetTester tester) async {
    ScaffoldMessenger.of(
      tester.element(find.byType(Scaffold).first),
    ).hideCurrentSnackBar();
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

  Future<void> preparar(WidgetTester tester) async {
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
  }

  testWidgets(
    'el administrador asigna un residente y la cuenta inactiva no entra',
    (tester) async {
      await preparar(tester);

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

    expect(find.text('Usuario registrado correctamente'), findsWidgets);
    expect(find.text('Contraseña inicial: Acceso123'), findsWidgets);
    await cerrarAviso(tester);
      expect(find.text('Vivienda: 101'), findsOneWidget);

      await tester.pageBack();
      await tester.pumpAndSettle();
      await tocar(tester, const Key('abrir-viviendas'));
      expect(
        tester.widget<Text>(find.byKey(const Key('estado-101'))).data,
        'Asignada',
      );
      expect(find.text('Responsable: Carlos Residente'), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();
      await salir(tester);

      await entrar(
        tester,
        correo: 'carlos@securityaccess.com',
        contrasena: 'Acceso123',
      );
      expect(find.byKey(const Key('menu-residente')), findsOneWidget);
      await salir(tester);

      await entrar(
        tester,
        correo: 'admin@securityaccess.com',
        contrasena: 'Admin1234',
      );
      await tocar(tester, const Key('abrir-usuarios'));
      await tocar(
        tester,
        const Key('boton-desactivar-usuario-carlos@securityaccess.com'),
      );
      await tester.tap(find.byKey(const Key('confirmar-desactivar-usuario')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('Usuario desactivado correctamente'), findsWidgets);
    await cerrarAviso(tester);
      expect(
        tester
            .widget<Text>(
              find.byKey(const Key('estado-usuario-carlos@securityaccess.com')),
            )
            .data,
        'Inactivo',
      );

      await tester.pageBack();
      await tester.pumpAndSettle();
      await tocar(tester, const Key('abrir-viviendas'));
      expect(
        tester.widget<Text>(find.byKey(const Key('estado-101'))).data,
        'Disponible',
      );
      await tester.pageBack();
      await tester.pumpAndSettle();
      await salir(tester);

      await entrar(
        tester,
        correo: 'carlos@securityaccess.com',
        contrasena: 'Acceso123',
      );
      expect(find.text('Su cuenta se encuentra desactivada'), findsOneWidget);
    },
  );

  testWidgets(
    'el correo queda bloqueado y cambiar de vivienda pide confirmación',
    (tester) async {
      await preparar(tester);
      await tocar(tester, const Key('abrir-viviendas'));
      await tocar(tester, const Key('boton-nueva-vivienda'));
      await tester.enterText(find.byKey(const Key('campo-numero')), '101');
      await tester.enterText(
        find.byKey(const Key('campo-direccion')),
        'Calle Uno',
      );
      await tester.tap(find.byKey(const Key('boton-guardar-vivienda')));
      await tester.pumpAndSettle();
      await tocar(tester, const Key('boton-nueva-vivienda'));
      await tester.enterText(find.byKey(const Key('campo-numero')), '202');
      await tester.enterText(
        find.byKey(const Key('campo-direccion')),
        'Calle Dos',
      );
      await tester.tap(find.byKey(const Key('boton-guardar-vivienda')));
      await tester.pumpAndSettle();
      await tester.pageBack();
      await tester.pumpAndSettle();

      await tocar(tester, const Key('abrir-usuarios'));
      await tocar(tester, const Key('boton-nuevo-usuario'));
      await tester.enterText(
        find.byKey(const Key('campo-nombre-usuario')),
        'Elena Residente',
      );
      await tester.enterText(
        find.byKey(const Key('campo-correo-usuario')),
        'elena@securityaccess.com',
      );
      await tester.enterText(
        find.byKey(const Key('campo-telefono-usuario')),
        '5550000000',
      );
      await elegirTexto(tester, const Key('selector-rol'), 'Residente');
      await elegirTexto(tester, const Key('selector-vivienda'), '101');
      await tester.tap(find.byKey(const Key('boton-guardar-usuario')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      await tocar(
        tester,
        const Key('boton-editar-usuario-elena@securityaccess.com'),
      );
      expect(
        tester
            .widget<TextField>(find.byKey(const Key('campo-correo-usuario')))
            .enabled,
        isFalse,
      );
      await elegirTexto(tester, const Key('selector-vivienda'), '202');
      await tester.tap(find.byKey(const Key('boton-guardar-usuario')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      await tester.tap(find.byKey(const Key('confirmar-cambio-vivienda')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('Usuario actualizado correctamente'), findsWidgets);
    await cerrarAviso(tester);
      expect(find.text('Vivienda: 202'), findsOneWidget);
      expect(RolUsuario.residente.etiqueta, 'Residente');
    },
  );
}
