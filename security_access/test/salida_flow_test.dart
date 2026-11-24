import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:security_access/app/crear_aplicacion.dart';
import 'package:security_access/domain/services/envio_codigo_recuperacion.dart';
import 'package:security_access/domain/entities/estado_invitacion.dart';
import 'package:security_access/domain/entities/estado_visita.dart';
import 'package:security_access/domain/entities/invitacion.dart';
import 'package:security_access/domain/entities/visita.dart';
import 'package:security_access/presentation/entrada/simulador_lectura.dart';

void main() {
  final entrada = DateTime(2026, 11, 5, 11);

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

  Future<void> preparar(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1400, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      crearAplicacion(
        invitacionesIniciales: [
          Invitacion(
            id: 'inv-1',
            viviendaId: 'viv-1',
            viviendaNumero: '101',
            residenteId: 'usr-1',
            nombreVisitante: 'Ana Visitante',
            entrada: entrada,
            salida: DateTime(2026, 11, 5, 18),
            codigoQr: 'SA-000001',
            estado: EstadoInvitacion.usada,
            estadoVisita: EstadoVisita.dentro,
          ),
          Invitacion(
            id: 'inv-2',
            viviendaId: 'viv-2',
            viviendaNumero: '202',
            residenteId: 'usr-2',
            nombreVisitante: 'Bruno',
            entrada: entrada,
            salida: DateTime(2026, 11, 5, 18),
            codigoQr: 'SA-000002',
            estado: EstadoInvitacion.usada,
            estadoVisita: EstadoVisita.dentro,
          ),
        ],
        visitasIniciales: [
          Visita(
            id: 'vis-1',
            viviendaId: 'viv-1',
            viviendaNumero: '101',
            residenteId: 'usr-1',
            nombreVisitante: 'Ana Visitante',
            fecha: entrada,
            entrada: entrada,
            estado: EstadoVisita.dentro,
            numeroIdentificacion: 'ABC123',
            tipoIdentificacion: 'INE',
            invitacionId: 'inv-1',
          ),
          Visita(
            id: 'vis-2',
            viviendaId: 'viv-2',
            viviendaNumero: '202',
            residenteId: 'usr-2',
            nombreVisitante: 'Bruno',
            fecha: entrada,
            entrada: entrada,
            estado: EstadoVisita.dentro,
            numeroIdentificacion: 'XYZ9',
            invitacionId: 'inv-2',
          ),
        ],
      ),
    );
    await entrar(
      tester,
      correo: 'guardia@securityaccess.com',
      contrasena: 'Guardia1234',
    );
  }

  testWidgets(
    'el guardia registra la salida con el QR y la visita sale de la lista',
    (tester) async {
      await preparar(tester);
      await tocar(tester, const Key('abrir-registrar-salida'));
      await tester.enterText(
        find.byKey(const Key('campo-codigo-leido')),
        'SA-999',
      );
      await tocar(tester, const Key('boton-leer-codigo'));
      expect(find.text('No hay registro de entrada'), findsOneWidget);

      await tester.enterText(
        find.byKey(const Key('campo-codigo-leido')),
        'SA-000001',
      );
      await tocar(tester, const Key('boton-leer-codigo'));
      expect(find.text('Visitante: Ana Visitante'), findsOneWidget);
      expect(
        find.byKey(const Key('campo-numero-identificacion')),
        findsNothing,
      );
      await tester.tap(find.byKey(const Key('boton-confirmar-salida')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('Salida registrada correctamente'), findsWidgets);
      await cerrarAviso(tester);

      await tester.pageBack();
      await tester.pumpAndSettle();
      await tocar(tester, const Key('abrir-visitas-dentro'));
      expect(find.byKey(const Key('visita-dentro-vis-1')), findsNothing);
      expect(find.byKey(const Key('visita-dentro-vis-2')), findsOneWidget);

      await tester.enterText(
        find.byKey(const Key('campo-buscar-visita')),
        '101',
      );
      await tocar(tester, const Key('boton-filtrar-visitas'));
      expect(find.text('No hay visitas dentro del conjunto'), findsOneWidget);

      await tester.enterText(find.byKey(const Key('campo-buscar-visita')), '');
      await tocar(tester, const Key('boton-filtrar-visitas'));
      await tocar(tester, const Key('boton-salida-manual-vis-2'));
      await tester.enterText(
        find.byKey(const Key('campo-motivo-salida')),
        'QR dañado',
      );
      await tester.tap(find.byKey(const Key('confirmar-salida-manual')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('Salida registrada correctamente'), findsWidgets);
      await cerrarAviso(tester);
      expect(find.byKey(const Key('visita-dentro-vis-2')), findsNothing);
    },
  );

  testWidgets('el usuario cambia la contraseña desde el menú de perfil', (
    tester,
  ) async {
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
    await tocar(tester, const Key('menu-usuario'));
    await tester.tap(find.text('Cambiar contraseña'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('campo-contrasena-actual')),
      'Admin1234',
    );
    await tester.enterText(
      find.byKey(const Key('campo-contrasena-nueva')),
      'Nueva1234',
    );
    await tester.enterText(
      find.byKey(const Key('campo-contrasena-confirmacion')),
      'Otra1234',
    );
    await tester.tap(find.byKey(const Key('boton-guardar-contrasena')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Las contraseñas no coinciden'), findsWidgets);
    await cerrarAviso(tester);

    await tester.enterText(
      find.byKey(const Key('campo-contrasena-confirmacion')),
      'Nueva1234',
    );
    await tester.tap(find.byKey(const Key('boton-guardar-contrasena')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Contraseña actualizada correctamente'), findsWidgets);
    await cerrarAviso(tester);

    await tocar(tester, const Key('menu-usuario'));
    await tester.tap(find.text('Cerrar sesión'));
    await tester.pumpAndSettle();
    await entrar(
      tester,
      correo: 'admin@securityaccess.com',
      contrasena: 'Nueva1234',
    );
    expect(find.byKey(const Key('menu-administrador')), findsOneWidget);
  });

  testWidgets(
    'recuperar la contraseña muestra el mismo aviso y vuelve al login',
    (tester) async {
      tester.view.physicalSize = const Size(1400, 2400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final envios = _CodigosEnviados();
      await tester.pumpWidget(crearAplicacion(envioRecuperacion: envios));
      await tester.tap(find.byKey(const Key('enlace-recuperar-contrasena')));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const Key('campo-correo-recuperacion')),
        'nadie@correo.com',
      );
      await tester.tap(find.byKey(const Key('boton-solicitar-recuperacion')));
      await tester.pumpAndSettle();
      expect(
        find.text('Si está registrado, recibirás instrucciones'),
        findsOneWidget,
      );
      expect(find.textContaining('no existe'), findsNothing);
      expect(find.textContaining('Código de recuperación'), findsNothing);
      expect(envios.codigos, isEmpty);

      await tester.enterText(
        find.byKey(const Key('campo-correo-recuperacion')),
        'admin@securityaccess.com',
      );
      await tester.tap(find.byKey(const Key('boton-solicitar-recuperacion')));
      await tester.pumpAndSettle();
      expect(
        find.text('Si está registrado, recibirás instrucciones'),
        findsOneWidget,
      );
      final codigo = envios.codigos['admin@securityaccess.com']!;
      expect(find.textContaining(codigo), findsNothing);
      await tester.enterText(
        find.byKey(const Key('campo-codigo-recuperacion')),
        codigo,
      );
      await tester.enterText(
        find.byKey(const Key('campo-contrasena-nueva')),
        'Nueva1234',
      );
      await tester.enterText(
        find.byKey(const Key('campo-contrasena-confirmacion')),
        'Nueva1234',
      );
      await tester.tap(find.byKey(const Key('boton-restablecer-contrasena')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('Contraseña actualizada correctamente'), findsWidgets);
      await cerrarAviso(tester);
      expect(
        find.byKey(const Key('pagina-recuperar-contrasena')),
        findsNothing,
      );
      await entrar(
        tester,
        correo: 'admin@securityaccess.com',
        contrasena: 'Nueva1234',
      );
      expect(find.byKey(const Key('menu-administrador')), findsOneWidget);
    },
  );
}

class _CodigosEnviados implements EnvioCodigoRecuperacion {
  final codigos = <String, String>{};

  @override
  Future<void> enviar({required String correo, required String codigo}) async {
    codigos[correo] = codigo;
  }
}
