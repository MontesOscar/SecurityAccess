import 'dart:math';

import 'package:security_access/domain/repositories/auth_repository.dart';
import 'package:security_access/domain/services/envio_codigo_recuperacion.dart';
import 'package:security_access/domain/usecases/regla_contrasena.dart';

sealed class ResultadoSolicitudRecuperacion {
  const ResultadoSolicitudRecuperacion();
}

class SolicitudRecuperacionEmitida extends ResultadoSolicitudRecuperacion {
  const SolicitudRecuperacionEmitida(this.codigo);

  static const mensaje = 'Si está registrado, recibirás instrucciones';

  final String codigo;
}

sealed class ResultadoRestablecerContrasena {
  const ResultadoRestablecerContrasena();
}

class ContrasenaRestablecida extends ResultadoRestablecerContrasena {
  const ContrasenaRestablecida();

  static const mensaje = 'Contraseña actualizada correctamente';
}

class RestablecimientoRechazado extends ResultadoRestablecerContrasena {
  const RestablecimientoRechazado(this.mensaje);

  final String mensaje;
}

class _CodigoRecuperacion {
  const _CodigoRecuperacion({required this.correo, required this.vence});

  final String correo;
  final DateTime vence;
}

class RecuperarContrasena {
  RecuperarContrasena(
    this._repositorio, {
    EnvioCodigoRecuperacion? envio,
    DateTime Function()? ahora,
    Random? aleatorio,
  }) : _envio = envio,
       _ahora = ahora ?? DateTime.now,
       _aleatorio = aleatorio ?? Random();

  final AuthRepository _repositorio;
  final EnvioCodigoRecuperacion? _envio;
  final DateTime Function() _ahora;
  final Random _aleatorio;
  final Map<String, _CodigoRecuperacion> _codigos = {};

  static const vigencia = Duration(minutes: 15);
  static const noCoinciden = 'Las contraseñas no coinciden';
  static const reutilizada = 'No se puede reutilizar la contraseña anterior';
  static const codigoInvalido = 'El código no es válido o ya venció';

  Future<ResultadoSolicitudRecuperacion> solicitar(String correo) async {
    final codigo = _generar();
    final cuenta = await _repositorio.buscarPorCorreo(correo);
    if (cuenta != null) {
      _codigos[codigo] = _CodigoRecuperacion(
        correo: cuenta.correo,
        vence: _ahora().add(vigencia),
      );
      await _envio?.enviar(correo: cuenta.correo, codigo: codigo);
    }
    return SolicitudRecuperacionEmitida(codigo);
  }

  Future<ResultadoRestablecerContrasena> restablecer({
    required String codigo,
    required String nueva,
    required String confirmacion,
  }) async {
    if (nueva != confirmacion) {
      return const RestablecimientoRechazado(noCoinciden);
    }
    final regla = reglaContrasena(nueva);
    if (regla != null) {
      return RestablecimientoRechazado(regla);
    }
    final registro = _codigos[codigo.trim()];
    if (registro == null || !_ahora().isBefore(registro.vence)) {
      return const RestablecimientoRechazado(codigoInvalido);
    }
    final coincide = await _repositorio.contrasenaCoincide(
      correo: registro.correo,
      contrasena: nueva,
    );
    if (coincide) {
      return const RestablecimientoRechazado(reutilizada);
    }
    await _repositorio.cambiarContrasena(
      correo: registro.correo,
      contrasena: nueva,
    );
    _codigos.remove(codigo.trim());
    return const ContrasenaRestablecida();
  }

  String _generar() {
    return List.generate(6, (_) => _aleatorio.nextInt(10)).join();
  }
}
