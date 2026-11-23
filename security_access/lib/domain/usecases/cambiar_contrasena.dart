import 'package:security_access/domain/entities/usuario.dart';
import 'package:security_access/domain/repositories/auth_repository.dart';
import 'package:security_access/domain/usecases/reglas_contrasena.dart';
import 'package:security_access/domain/usecases/resultado_cambiar_contrasena.dart';

class CambiarContrasena {
  const CambiarContrasena(this._repositorio);

  final AuthRepository _repositorio;

  static const mensajeObligatorios = 'Todos los campos son obligatorios';
  static const mensajeActualIncorrecta = 'La contraseña actual es incorrecta';
  static const mensajeIgualActual =
      'La nueva contraseña no puede ser igual a la actual';

  Future<ResultadoCambiarContrasena> call({
    required Usuario usuario,
    required String actual,
    required String nueva,
    required String confirmacion,
  }) async {
    if (actual.isEmpty || nueva.isEmpty || confirmacion.isEmpty) {
      return const ContrasenaNoActualizada(mensajeObligatorios);
    }
    final correcta = await _repositorio.contrasenaCoincide(
      correo: usuario.correo,
      contrasena: actual,
    );
    if (!correcta) {
      return const ContrasenaNoActualizada(mensajeActualIncorrecta);
    }
    if (nueva != confirmacion) {
      return const ContrasenaNoActualizada(ReglasContrasena.mensajeNoCoinciden);
    }
    if (!ReglasContrasena.cumple(nueva)) {
      return const ContrasenaNoActualizada(ReglasContrasena.mensajeRequisitos);
    }
    if (nueva == actual) {
      return const ContrasenaNoActualizada(mensajeIgualActual);
    }
    await _repositorio.actualizarContrasena(id: usuario.id, contrasena: nueva);
    return const ContrasenaActualizada();
  }
}
