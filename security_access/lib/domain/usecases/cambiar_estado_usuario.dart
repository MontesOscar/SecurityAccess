import 'package:security_access/domain/entities/estado_cuenta.dart';
import 'package:security_access/domain/repositories/auth_repository.dart';
import 'package:security_access/domain/usecases/asignacion_vivienda.dart';
import 'package:security_access/domain/usecases/resultado_cambio_estado_usuario.dart';

class CambiarEstadoUsuario {
  const CambiarEstadoUsuario(this._usuarios, this._asignacion);

  final AuthRepository _usuarios;
  final AsignacionVivienda _asignacion;

  Future<ResultadoCambioEstadoUsuario> call({
    required String id,
    required bool activar,
  }) async {
    final actual = await _usuarios.buscarPorId(id);
    if (actual == null) {
      return const UsuarioEstadoNoEncontrado();
    }

    if (!activar && actual.viviendaId != null) {
      await _asignacion.liberar(actual.viviendaId);
    }

    final actualizado = actual.copyWith(
      estado: activar ? EstadoCuenta.activo : EstadoCuenta.inactivo,
      limpiarVivienda: !activar,
    );
    await _usuarios.actualizar(actualizado);
    return EstadoUsuarioActualizado(actualizado);
  }
}
