import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:security_access/app/crear_aplicacion.dart';
import 'package:security_access/domain/entities/estado_visita.dart';
import 'package:security_access/domain/entities/notificacion.dart';
import 'package:security_access/domain/entities/tipo_notificacion.dart';
import 'package:security_access/domain/entities/visita.dart';
import 'package:security_access/presentation/session/vigilar_inactividad.dart';

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

  Future<void> preparar(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1400, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  testWidgets(
    'el administrador ve el historial completo y la visita sin salida',
    (tester) async {
      await preparar(tester);
      await tester.pumpWidget(
        crearAplicacion(
          visitasIniciales: [
            Visita(
              id: 'vis-1',
              viviendaId: 'viv-1',
              viviendaNumero: '101',
              residenteId: 'usr-anterior',
              nombreVisitante: 'Ana Visitante',
              fecha: DateTime(2026, 11, 20, 9),
              entrada: DateTime(2026, 11, 20, 9),
              salida: DateTime(2026, 11, 20, 11),
              estado: EstadoVisita.completada,
              guardiaId: 'usr-guardia',
              numeroIdentificacion: 'ABC123',
            ),
            Visita(
              id: 'vis-2',
              viviendaId: 'viv-1',
              viviendaNumero: '101',
              residenteId: 'usr-residente',
              nombreVisitante: 'Bruno',
              fecha: DateTime(2026, 11, 24, 8),
              entrada: DateTime(2026, 11, 24, 8),
              estado: EstadoVisita.dentro,
              guardiaId: 'usr-guardia',
            ),
          ],
        ),
      );
      await entrar(
        tester,
        correo: 'admin@securityaccess.com',
        contrasena: 'Admin1234',
      );
      await tester.tap(find.byKey(const Key('abrir-reporte')));
      await tester.pumpAndSettle();
      expect(find.textContaining('Ana Visitante'), findsOneWidget);
      expect(find.textContaining('Bruno'), findsOneWidget);
      expect(find.byKey(const Key('marca-sin-salida-vis-2')), findsOneWidget);
      expect(find.byKey(const Key('marca-sin-salida-vis-1')), findsNothing);
    },
  );

  testWidgets('el residente consulta el aviso de su visita', (tester) async {
    await preparar(tester);
    await tester.pumpWidget(
      crearAplicacion(
        notificacionesIniciales: [
          Notificacion(
            id: 'not-1',
            residenteId: 'usr-residente',
            viviendaId: 'viv-1',
            nombreVisitante: 'Ana Visitante',
            fecha: DateTime(2026, 11, 24, 12),
            tipo: TipoNotificacion.salida,
          ),
        ],
      ),
    );
    await entrar(
      tester,
      correo: 'residente@securityaccess.com',
      contrasena: 'Residente1',
    );
    await tester.tap(find.byKey(const Key('abrir-notificaciones')));
    await tester.pumpAndSettle();
    expect(find.text('Ana Visitante salió a las 12:00'), findsOneWidget);
  });

  testWidgets('la sesión inactiva regresa al inicio de sesión', (tester) async {
    await preparar(tester);
    await tester.pumpWidget(
      crearAplicacion(inactividad: const Duration(seconds: 5)),
    );
    await entrar(
      tester,
      correo: 'guardia@securityaccess.com',
      contrasena: 'Guardia1234',
    );
    expect(find.byKey(const Key('menu-guardia')), findsOneWidget);
    await tester.pump(const Duration(seconds: 5));
    await tester.pump();
    expect(find.text(VigilarInactividad.mensaje), findsWidgets);
    expect(find.byKey(const Key('campo-correo')), findsOneWidget);
    expect(find.byKey(const Key('menu-guardia')), findsNothing);
  });
}
