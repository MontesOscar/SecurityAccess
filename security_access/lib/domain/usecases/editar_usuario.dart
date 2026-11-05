import 'package:security_access/domain/entities/rol_usuario.dart';
import 'package:security_access/domain/repositories/auth_repository.dart';
import 'package:security_access/domain/usecases/asignacion_vivienda.dart';
import 'package:security_access/domain/usecases/resultado_editar_usuario.dart';

class EditarUsuario {
  const EditarUsuario(this._usuarios, this._asignacion);

  final AuthRepository _usuarios;
  final AsignacionVivienda _asignacion;

  Future<ResultadoEditarUsuario> call({
    required String id,
    required String nombre,
    required String telefono,
    required RolUsuario rol,
    String? viviendaId,
    required bool confirmarCambioVivienda,
  }) async {
    final actual = await _usuarios.buscarPorId(id);
    if (actual == null) {
      return const UsuarioEdicionNoEncontrado();
    }

    final nombreLimpio = nombre.trim();
    final telefonoLimpio = telefono.trim();
    if (nombreLimpio.isEmpty || telefonoLimpio.isEmpty) {
      return const DatosEdicionUsuarioInvalidos();
    }

    final esResidente = rol == RolUsuario.residente;
    final nuevaViviendaId = esResidente ? _vacioANulo(viviendaId) : null;
    if (esResidente && nuevaViviendaId == null) {
      return const ViviendaEdicionObligatoria();
    }

    final cambiaAsignacion =
        actual.rol != rol || actual.viviendaId != nuevaViviendaId;
    if (cambiaAsignacion && !confirmarCambioVivienda) {
      return const EdicionUsuarioRequiereConfirmacion();
    }

    final vivienda = nuevaViviendaId == null
        ? null
        : await _asignacion.buscarDisponible(
            nuevaViviendaId,
            residenteActualId: actual.id,
          );
    if (nuevaViviendaId != null && vivienda == null) {
      return const ViviendaEdicionNoDisponible();
    }

    if (actual.viviendaId != null && actual.viviendaId != nuevaViviendaId) {
      await _asignacion.liberar(actual.viviendaId);
    }
    if (vivienda != null) {
      await _asignacion.asignar(
        vivienda: vivienda,
        residenteId: actual.id,
        residenteNombre: nombreLimpio,
      );
    }

    final actualizado = actual.copyWith(
      nombre: nombreLimpio,
      telefono: telefonoLimpio,
      rol: rol,
      viviendaId: vivienda?.id,
      viviendaNumero: vivienda?.numero,
      limpiarVivienda: true,
    );
    await _usuarios.actualizar(actualizado);
    return UsuarioActualizado(actualizado);
  }

  String? _vacioANulo(String? valor) {
    final limpio = valor?.trim();
    if (limpio == null || limpio.isEmpty) {
      return null;
    }
    return limpio;
  }
}
