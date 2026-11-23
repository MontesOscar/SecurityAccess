import 'package:flutter_test/flutter_test.dart';
import 'package:security_access/data/repositories/in_memory_auth_repository.dart';
import 'package:security_access/data/repositories/in_memory_recuperacion_repository.dart';
import 'package:security_access/data/seed/cuentas_semilla.dart';
import 'package:security_access/domain/usecases/iniciar_sesion.dart';
import 'package:security_access/domain/usecases/reglas_contrasena.dart';
import 'package:security_access/domain/usecases/restablecer_contrasena.dart';
import 'package:security_access/domain/usecases/resultado_inicio_sesion.dart';
import 'package:security_access/domain/usecases/resultado_recuperar_contrasena.dart';
import 'package:security_access/domain/usecases/solicitar_recuperacion.dart';
import 'package:security_access/domain/usecases/validar_codigo_recuperacion.dart';

void main() {
  const correo = 'residente@securityaccess.com';
  late DateTime ahora;
  late InMemoryAuthRepository usuarios;
  late SolicitarRecuperacion solicitar;
  late ValidarCodigoRecuperacion validar;
  late RestablecerContrasena restablecer;
  late List<String> codigos;

  setUp(() {
    ahora = DateTime(2026, 11, 5, 12);
    codigos = ['111111', '222222', '333333'];
    usuarios = InMemoryAuthRepository(CuentasSemilla.registros);
    final repositorio = InMemoryRecuperacionRepository();
    solicitar = SolicitarRecuperacion(
      usuarios,
      repositorio,
      ahora: () => ahora,
      generarCodigo: () => codigos.removeAt(0),
    );
    validar = ValidarCodigoRecuperacion(repositorio, ahora: () => ahora);
    restablecer = RestablecerContrasena(usuarios, repositorio, validar);
  });

  test('correo no registrado: misma respuesta y el código no sirve', () async {
    final noRegistrado = await solicitar('nadie@securityaccess.com');
    final registrado = await solicitar(correo);

    expect(
      SolicitudRecuperacion.mensaje,
      'Si está registrado, recibirás instrucciones',
    );
    // Ambos reciben un código con el mismo formato: no se distingue nada.
    expect(noRegistrado.codigoEnviado, hasLength(6));
    expect(registrado.codigoEnviado, hasLength(6));

    expect(
      await validar(
        correo: 'nadie@securityaccess.com',
        codigo: noRegistrado.codigoEnviado,
      ),
      isFalse,
    );
    final intento = await restablecer(
      correo: 'nadie@securityaccess.com',
      codigo: noRegistrado.codigoEnviado,
      nueva: 'Nueva1234',
      confirmacion: 'Nueva1234',
    );
    expect(
      (intento as ContrasenaNoRestablecida).mensaje,
      ValidarCodigoRecuperacion.mensajeInvalido,
    );
  });

  test('el código de un correo no sirve para otro correo', () async {
    final otro = await solicitar('nadie@securityaccess.com');
    await solicitar(correo);
    expect(await validar(correo: correo, codigo: otro.codigoEnviado), isFalse);
  });

  test('código válido da paso al formulario; vencido no', () async {
    final solicitud = await solicitar(correo);
    expect(await validar(correo: correo, codigo: '999999'), isFalse);
    expect(
      await validar(correo: correo, codigo: solicitud.codigoEnviado),
      isTrue,
    );

    ahora = ahora.add(SolicitarRecuperacion.vigencia);
    expect(
      await validar(correo: correo, codigo: solicitud.codigoEnviado),
      isFalse,
    );
  });

  test(
    'valida la nueva contraseña y no permite reutilizar la anterior',
    () async {
      final codigo = (await solicitar(correo)).codigoEnviado;
      Future<String> mensaje(String nueva, String confirmacion) async {
        final resultado = await restablecer(
          correo: correo,
          codigo: codigo,
          nueva: nueva,
          confirmacion: confirmacion,
        );
        return (resultado as ContrasenaNoRestablecida).mensaje;
      }

      expect(
        await mensaje('Nueva1234', 'Otra12345'),
        ReglasContrasena.mensajeNoCoinciden,
      );
      expect(
        await mensaje('corta', 'corta'),
        ReglasContrasena.mensajeRequisitos,
      );
      expect(
        await mensaje('Residente1', 'Residente1'),
        RestablecerContrasena.mensajeIgualAnterior,
      );
    },
  );

  test('al actualizar se entra con la nueva y el código ya no sirve', () async {
    final codigo = (await solicitar(correo)).codigoEnviado;
    final resultado = await restablecer(
      correo: correo,
      codigo: codigo,
      nueva: 'Nueva1234',
      confirmacion: 'Nueva1234',
    );
    expect(resultado, isA<ContrasenaRestablecida>());

    final iniciar = IniciarSesion(usuarios);
    expect(
      await iniciar(correo: correo, contrasena: 'Nueva1234'),
      isA<InicioSesionExitoso>(),
    );
    expect(await validar(correo: correo, codigo: codigo), isFalse);
  });
}
