import 'package:flutter_test/flutter_test.dart';
import 'package:security_access/app/crear_aplicacion.dart';

void main() {
  testWidgets('la aplicación abre en el inicio de sesión', (tester) async {
    await tester.pumpWidget(crearAplicacion());

    expect(find.text('Security Access'), findsOneWidget);
    expect(find.text('Iniciar sesión'), findsOneWidget);
  });
}
