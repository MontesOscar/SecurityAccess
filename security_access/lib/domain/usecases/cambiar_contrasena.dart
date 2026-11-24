import 'package:security_access/domain/entities/usuario.dart';
import 'package:security_access/domain/repositories/auth_repository.dart';
import 'package:security_access/domain/usecases/regla_contrasena.dart';

sealed class ResultadoCambioContrasena {
  const ResultadoCambioContrasena();
}

class ContrasenaActualizada extends ResultadoCambioContrasena {
  const ContrasenaActualizada();

  static const mensaje = 'Contraseña actualizada correctamente';
}

class CambioRechazado extends ResultadoCambioContrasena {
  const CambioRechazado(this.mensaje);

  final String mensaje;
}

class CambiarContrasena {
  const CambiarContrasena(this._repositorio);

  final AuthRepository _repositorio;

  static const actualIncorrecta = 'La contraseña actual es incorrecta';
  static const noCoinciden = 'Las contraseñas no coinciden';
  static const reutilizada = 'No se puede reutilizar la contraseña actual';

  Future<ResultadoCambioContrasena> call({
    required Usuario usuario,
    required String actual,
    required String nueva,
    required String confirmacion,
  }) async {
    if (nueva != confirmacion) {
      return const CambioRechazado(noCoinciden);
    }
    if (nueva == actual) {
      return const CambioRechazado(reutilizada);
    }
    final regla = reglaContrasena(nueva);
    if (regla != null) {
      return CambioRechazado(regla);
    }
    final coincide = await _repositorio.contrasenaCoincide(
      correo: usuario.correo,
      contrasena: actual,
    );
    if (!coincide) {
      return const CambioRechazado(actualIncorrecta);
    }
    await _repositorio.cambiarContrasena(
      correo: usuario.correo,
      contrasena: nueva,
    );
    return const ContrasenaActualizada();
  }
}
