import 'package:security_access/domain/entities/estado_cuenta.dart';
import 'package:security_access/domain/entities/rol_usuario.dart';
import 'package:security_access/domain/entities/usuario.dart';
import 'package:security_access/domain/repositories/auth_repository.dart';
import 'package:security_access/domain/usecases/asignacion_vivienda.dart';
import 'package:security_access/domain/usecases/resultado_crear_usuario.dart';

class CrearUsuario {
  const CrearUsuario(this._usuarios, this._asignacion);

  final AuthRepository _usuarios;
  final AsignacionVivienda _asignacion;

  static const contrasenaInicial = 'Acceso123';

  Future<ResultadoCrearUsuario> call({
    required String nombre,
    required String correo,
    required String telefono,
    required RolUsuario rol,
    String? viviendaId,
  }) async {
    final nombreLimpio = nombre.trim();
    final correoLimpio = correo.trim().toLowerCase();
    final telefonoLimpio = telefono.trim();
    if (nombreLimpio.isEmpty ||
        correoLimpio.isEmpty ||
        telefonoLimpio.isEmpty) {
      return const DatosUsuarioInvalidos();
    }

    if (await _usuarios.buscarPorCorreo(correoLimpio) != null) {
      return const CorreoYaRegistrado();
    }

    final esResidente = rol == RolUsuario.residente;
    final viviendaSeleccionada = viviendaId?.trim();
    if (esResidente &&
        (viviendaSeleccionada == null || viviendaSeleccionada.isEmpty)) {
      return const ViviendaObligatoria();
    }

    final vivienda = esResidente
        ? await _asignacion.buscarDisponible(viviendaSeleccionada!)
        : null;
    if (esResidente && vivienda == null) {
      return const ViviendaNoDisponible();
    }

    final usuario = Usuario(
      id: await _usuarios.reservarId(),
      nombre: nombreLimpio,
      correo: correoLimpio,
      telefono: telefonoLimpio,
      rol: rol,
      estado: EstadoCuenta.activo,
      viviendaId: vivienda?.id,
      viviendaNumero: vivienda?.numero,
    );
    await _usuarios.registrar(usuario, contrasena: contrasenaInicial);
    if (vivienda != null) {
      await _asignacion.asignar(
        vivienda: vivienda,
        residenteId: usuario.id,
        residenteNombre: usuario.nombre,
      );
    }
    return UsuarioCreado(usuario, contrasenaInicial: contrasenaInicial);
  }
}
