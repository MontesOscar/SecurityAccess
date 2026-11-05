import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:security_access/app/crear_aplicacion.dart';
import 'package:security_access/domain/entities/estado_vivienda.dart';
import 'package:security_access/domain/entities/vivienda.dart';

void main() {
  Future<void> iniciarComoAdmin(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1400, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(crearAplicacion());
    await tester.enterText(
      find.byKey(const Key('campo-correo')),
      'admin@securityaccess.com',
    );
    await tester.enterText(
      find.byKey(const Key('campo-contrasena')),
      'Admin1234',
    );
    await tester.tap(find.byKey(const Key('boton-iniciar-sesion')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('abrir-viviendas')));
    await tester.pumpAndSettle();
  }

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

  Future<void> crearVivienda(
    WidgetTester tester, {
    required String numero,
    required String direccion,
  }) async {
    await tocar(tester, const Key('boton-nueva-vivienda'));
    await tester.enterText(find.byKey(const Key('campo-numero')), numero);
    await tester.enterText(find.byKey(const Key('campo-direccion')), direccion);
    await tester.tap(find.byKey(const Key('boton-guardar-vivienda')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
  }

  testWidgets('el administrador registra, consulta, edita y cambia el estado', (
    tester,
  ) async {
    await iniciarComoAdmin(tester);
    expect(find.text('No hay viviendas registradas.'), findsOneWidget);

    await crearVivienda(tester, numero: '101', direccion: 'Calle Uno');
    expect(find.text('Vivienda registrada correctamente'), findsWidgets);
    await cerrarAviso(tester);
    expect(find.byKey(const Key('vivienda-101')), findsOneWidget);
    expect(
      tester.widget<Text>(find.byKey(const Key('estado-101'))).data,
      'Disponible',
    );
    expect(find.text('Responsable: Sin residente'), findsOneWidget);

    await tocar(tester, const Key('boton-nueva-vivienda'));
    await tester.enterText(find.byKey(const Key('campo-numero')), '101');
    await tester.enterText(find.byKey(const Key('campo-direccion')), 'Otra');
    await tester.tap(find.byKey(const Key('boton-guardar-vivienda')));
    await tester.pumpAndSettle();
    expect(find.text('La vivienda ya está registrada'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();

    await crearVivienda(tester, numero: '202', direccion: 'Calle Dos');

    await tocar(tester, const Key('boton-editar-101'));
    expect(
      tester.widget<TextField>(find.byKey(const Key('campo-numero'))).enabled,
      isFalse,
    );
    await tester.enterText(
      find.byKey(const Key('campo-direccion')),
      'Calle Editada',
    );
    await tester.tap(find.byKey(const Key('boton-guardar-vivienda')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Vivienda actualizada correctamente'), findsWidgets);
    await cerrarAviso(tester);
    expect(find.text('Calle Editada'), findsOneWidget);

    await tocar(tester, const Key('boton-historial-101'));
    expect(find.text('Aún no hay visitas registradas.'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tocar(tester, const Key('boton-desactivar-202'));
    await tester.tap(find.byKey(const Key('confirmar-desactivar')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Vivienda desactivada correctamente'), findsWidgets);
    await cerrarAviso(tester);
    expect(
      tester.widget<Text>(find.byKey(const Key('estado-202'))).data,
      'Inactiva',
    );
    expect(find.byKey(const Key('boton-historial-202')), findsOneWidget);

    await tocar(tester, const Key('filtro-inactiva'));
    expect(find.byKey(const Key('vivienda-202')), findsOneWidget);
    expect(find.byKey(const Key('vivienda-101')), findsNothing);

    await tocar(tester, const Key('filtro-disponible'));
    expect(find.byKey(const Key('vivienda-101')), findsOneWidget);
    expect(find.byKey(const Key('vivienda-202')), findsNothing);

    await tester.enterText(
      find.byKey(const Key('campo-buscar-vivienda')),
      '101',
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('vivienda-101')), findsOneWidget);

    await tester.enterText(find.byKey(const Key('campo-buscar-vivienda')), '');
    await tester.pumpAndSettle();
    await tocar(tester, const Key('filtro-todas'));
    await tocar(tester, const Key('boton-reactivar-202'));
    await tester.tap(find.byKey(const Key('confirmar-reactivar')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Vivienda reactivada correctamente'), findsWidgets);
    await cerrarAviso(tester);
    expect(
      tester.widget<Text>(find.byKey(const Key('estado-202'))).data,
      'Disponible',
    );
  });

  testWidgets('muestra una vivienda asignada y la distingue del filtro', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1400, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      crearAplicacion(
        viviendasIniciales: const [
          Vivienda(
            id: 'viv-12',
            numero: '12',
            direccion: 'Calle Norte',
            estado: EstadoVivienda.asignada,
            residenteId: 'usr-residente',
            residenteNombre: 'Luis Residente',
          ),
        ],
      ),
    );
    await tester.enterText(
      find.byKey(const Key('campo-correo')),
      'admin@securityaccess.com',
    );
    await tester.enterText(
      find.byKey(const Key('campo-contrasena')),
      'Admin1234',
    );
    await tester.tap(find.byKey(const Key('boton-iniciar-sesion')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('abrir-viviendas')));
    await tester.pumpAndSettle();

    expect(find.text('Responsable: Luis Residente'), findsOneWidget);
    expect(
      tester.widget<Text>(find.byKey(const Key('estado-12'))).data,
      'Asignada',
    );

    await tocar(tester, const Key('filtro-asignada'));
    expect(find.byKey(const Key('vivienda-12')), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('campo-buscar-vivienda')),
      'Luis',
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('vivienda-12')), findsOneWidget);
  });
}
