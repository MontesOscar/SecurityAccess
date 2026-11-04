import 'package:flutter_test/flutter_test.dart';
import 'package:security_access/data/repositories/in_memory_auth_repository.dart';
import 'package:security_access/data/seed/cuentas_semilla.dart';
import 'package:security_access/domain/entities/rol_usuario.dart';
import 'package:security_access/domain/usecases/cerrar_sesion.dart';
import 'package:security_access/domain/usecases/iniciar_sesion.dart';
import 'package:security_access/domain/usecases/resultado_inicio_sesion.dart';

void main() {
  late InMemoryAuthRepository repositorio;
  late IniciarSesion iniciarSesion;

  setUp(() {
    repositorio = InMemoryAuthRepository(CuentasSemilla.registros);
    iniciarSesion = IniciarSesion(repositorio);
  });

  test('abre sesión cuando el correo y la contraseña coinciden', () async {
    final resultado = await iniciarSesion(
      correo: ' Admin@SecurityAccess.com ',
      contrasena: 'Admin1234',
    );

    expect(resultado, isA<InicioSesionExitoso>());
    final usuario = (resultado as InicioSesionExitoso).usuario;
    expect(usuario.rol, RolUsuario.administrador);
    expect(repositorio.sesionActual?.id, usuario.id);
  });

  test('rechaza un correo que no existe', () async {
    final resultado = await iniciarSesion(
      correo: 'nadie@securityaccess.com',
      contrasena: 'Admin1234',
    );

    expect(resultado, isA<InicioSesionCredencialesInvalidas>());
    expect(repositorio.sesionActual, isNull);
  });

  test('rechaza una contraseña incorrecta', () async {
    final resultado = await iniciarSesion(
      correo: 'admin@securityaccess.com',
      contrasena: 'otra-clave',
    );

    expect(resultado, isA<InicioSesionCredencialesInvalidas>());
    expect(repositorio.sesionActual, isNull);
  });

  test('una cuenta inactiva con contraseña correcta no abre sesión', () async {
    final resultado = await iniciarSesion(
      correo: 'inactivo@securityaccess.com',
      contrasena: 'Inactivo1',
    );

    expect(resultado, isA<InicioSesionCuentaInactiva>());
    expect(repositorio.sesionActual, isNull);
  });

  test(
    'una cuenta inactiva con contraseña incorrecta no revela el estado',
    () async {
      final resultado = await iniciarSesion(
        correo: 'inactivo@securityaccess.com',
        contrasena: 'clave-erronea',
      );

      expect(resultado, isA<InicioSesionCredencialesInvalidas>());
    },
  );

  test('cerrar sesión invalida la sesión abierta', () async {
    await iniciarSesion(
      correo: 'guardia@securityaccess.com',
      contrasena: 'Guardia1234',
    );
    expect(repositorio.sesionActual, isNotNull);

    await CerrarSesion(repositorio)();

    expect(repositorio.sesionActual, isNull);
  });
}
