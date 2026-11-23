import 'package:flutter_test/flutter_test.dart';
import 'package:security_access/data/repositories/in_memory_auth_repository.dart';
import 'package:security_access/data/seed/cuentas_semilla.dart';
import 'package:security_access/domain/usecases/cambiar_contrasena.dart';
import 'package:security_access/domain/usecases/iniciar_sesion.dart';
import 'package:security_access/domain/usecases/reglas_contrasena.dart';
import 'package:security_access/domain/usecases/resultado_cambiar_contrasena.dart';
import 'package:security_access/domain/usecases/resultado_inicio_sesion.dart';

void main() {
  late InMemoryAuthRepository repositorio;
  late CambiarContrasena cambiar;
  late IniciarSesion iniciar;

  setUp(() {
    repositorio = InMemoryAuthRepository(CuentasSemilla.registros);
    cambiar = CambiarContrasena(repositorio);
    iniciar = IniciarSesion(repositorio);
  });

  Future<String> mensaje({
    required String actual,
    required String nueva,
    required String confirmacion,
  }) async {
    final usuario = await repositorio.buscarPorCorreo(
      'guardia@securityaccess.com',
    );
    final resultado = await cambiar(
      usuario: usuario!,
      actual: actual,
      nueva: nueva,
      confirmacion: confirmacion,
    );
    return switch (resultado) {
      ContrasenaActualizada() => ContrasenaActualizada.mensaje,
      ContrasenaNoActualizada(:final mensaje) => mensaje,
    };
  }

  test('contraseña actual incorrecta muestra un error', () async {
    expect(
      await mensaje(
        actual: 'Otra1234',
        nueva: 'Nueva1234',
        confirmacion: 'Nueva1234',
      ),
      CambiarContrasena.mensajeActualIncorrecta,
    );
  });

  test('si no coinciden responde "Las contraseñas no coinciden"', () async {
    expect(
      await mensaje(
        actual: 'Guardia1234',
        nueva: 'Nueva1234',
        confirmacion: 'Nueva12345',
      ),
      'Las contraseñas no coinciden',
    );
  });

  test('exige requisitos mínimos y no reutilizar la actual', () async {
    for (final debil in ['Corta1', 'sinmayuscula1', 'SinNumeroAqui']) {
      expect(
        await mensaje(actual: 'Guardia1234', nueva: debil, confirmacion: debil),
        ReglasContrasena.mensajeRequisitos,
      );
    }
    expect(
      await mensaje(
        actual: 'Guardia1234',
        nueva: 'Guardia1234',
        confirmacion: 'Guardia1234',
      ),
      CambiarContrasena.mensajeIgualActual,
    );
    expect(
      await mensaje(actual: '', nueva: '', confirmacion: ''),
      CambiarContrasena.mensajeObligatorios,
    );
  });

  test('éxito: "Contraseña actualizada correctamente" y se entra con la '
      'nueva', () async {
    expect(
      await mensaje(
        actual: 'Guardia1234',
        nueva: 'Nueva1234',
        confirmacion: 'Nueva1234',
      ),
      'Contraseña actualizada correctamente',
    );
    expect(
      await iniciar(
        correo: 'guardia@securityaccess.com',
        contrasena: 'Nueva1234',
      ),
      isA<InicioSesionExitoso>(),
    );
    expect(
      await iniciar(
        correo: 'guardia@securityaccess.com',
        contrasena: 'Guardia1234',
      ),
      isA<InicioSesionCredencialesInvalidas>(),
    );
  });
}
