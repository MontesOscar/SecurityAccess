import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:security_access/app/crear_aplicacion.dart';
import 'package:security_access/presentation/invitaciones/compartir_qr.dart';
import 'package:security_access/presentation/invitaciones/resultado_compartir_qr.dart';

void main() {
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

  Future<void> prepararResidente(WidgetTester tester) async {
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
  }

  testWidgets(
    'el residente crea, consulta, comparte y cancela una invitación',
    (tester) async {
      await prepararResidente(tester);
      await tocar(tester, const Key('abrir-invitaciones'));
      await tocar(tester, const Key('boton-nueva-invitacion'));
      await tester.tap(find.byKey(const Key('boton-guardar-invitacion')));
      await tester.pump();

      expect(find.text('El nombre es obligatorio'), findsOneWidget);
      expect(find.text('La fecha de entrada es obligatoria'), findsOneWidget);
      expect(find.text('La hora de entrada es obligatoria'), findsOneWidget);

      final ayer = DateTime.now().subtract(const Duration(days: 1));
      await tester.enterText(
        find.byKey(const Key('campo-nombre-visitante')),
        'Ana Visitante',
      );
      await tester.enterText(
        find.byKey(const Key('campo-fecha-entrada')),
        fecha(ayer),
      );
      await tester.enterText(
        find.byKey(const Key('campo-hora-entrada')),
        '10:00',
      );
      await tester.enterText(
        find.byKey(const Key('campo-fecha-salida')),
        fecha(ayer),
      );
      await tester.enterText(
        find.byKey(const Key('campo-hora-salida')),
        '12:00',
      );
      await tester.tap(find.byKey(const Key('boton-guardar-invitacion')));
      await tester.pump();
      expect(find.text('La entrada no puede ser anterior a hoy'), findsWidgets);

      final manana = DateTime.now().add(const Duration(days: 1));
      await tester.enterText(
        find.byKey(const Key('campo-fecha-entrada')),
        fecha(manana),
      );
      await tester.enterText(
        find.byKey(const Key('campo-fecha-salida')),
        fecha(manana),
      );
      await tester.tap(find.byKey(const Key('boton-guardar-invitacion')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('Invitación registrada correctamente'), findsWidgets);
      expect(find.text('Código QR: SA-000001'), findsWidgets);
      await cerrarAviso(tester);
      expect(find.text('Ana Visitante'), findsOneWidget);
      expect(
        tester
            .widget<Text>(find.byKey(const Key('estado-invitacion-inv-1')))
            .data,
        'Activa',
      );

      await tocar(tester, const Key('invitacion-inv-1'));
      expect(find.byKey(const Key('imagen-qr')), findsOneWidget);
      expect(find.text('SA-000001'), findsOneWidget);
      expect(find.text('Sin entrada'), findsOneWidget);

      List<int>? png;
      String? nombre;
      String? texto;
      compartirQrParaPruebas = (imagen, archivo, mensaje) async {
        png = imagen;
        nombre = archivo;
        texto = mensaje;
        return ResultadoCompartirQr.menu;
      };
      addTearDown(() => compartirQrParaPruebas = null);
      await tester.runAsync(() async {
        await tester.tap(find.byKey(const Key('boton-compartir-qr')));
        await Future<void>.delayed(const Duration(milliseconds: 300));
      });
      await tester.pump();
      expect(png, isNotNull);
      expect(png!.take(8).toList(), [
        0x89,
        0x50,
        0x4E,
        0x47,
        0x0D,
        0x0A,
        0x1A,
        0x0A,
      ]);
      expect(nombre, 'qr-SA-000001.png');
      expect(texto, contains('Ana Visitante'));
      expect(texto, contains('Vivienda: 101'));

      await tocar(tester, const Key('boton-cancelar-invitacion'));
      await tester.tap(find.byKey(const Key('confirmar-cancelar-invitacion')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('Invitación cancelada correctamente'), findsWidgets);
      await cerrarAviso(tester);
      expect(
        tester
            .widget<Text>(find.byKey(const Key('estado-invitacion-inv-1')))
            .data,
        'Cancelada',
      );

      await tester.pageBack();
      await tester.pumpAndSettle();
      await tocar(tester, const Key('abrir-historial'));
      expect(find.text('Aún no hay visitas registradas.'), findsOneWidget);
    },
  );

  testWidgets('sin vivienda activa no se puede crear la invitación', (
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
    await tocar(tester, const Key('abrir-invitaciones'));
    await tocar(tester, const Key('boton-nueva-invitacion'));
    final manana = DateTime.now().add(const Duration(days: 1));
    await tester.enterText(
      find.byKey(const Key('campo-nombre-visitante')),
      'Ana Visitante',
    );
    await tester.enterText(
      find.byKey(const Key('campo-fecha-entrada')),
      fecha(manana),
    );
    await tester.enterText(
      find.byKey(const Key('campo-hora-entrada')),
      '10:00',
    );
    await tester.enterText(
      find.byKey(const Key('campo-fecha-salida')),
      fecha(manana),
    );
    await tester.enterText(find.byKey(const Key('campo-hora-salida')), '12:00');
    await tester.tap(find.byKey(const Key('boton-guardar-invitacion')));
    await tester.pump();

    expect(find.text('Su vivienda no está activa'), findsOneWidget);
  });
}
