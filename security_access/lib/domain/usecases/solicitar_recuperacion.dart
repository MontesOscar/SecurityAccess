import 'dart:math';

import 'package:security_access/domain/entities/codigo_recuperacion.dart';
import 'package:security_access/domain/repositories/auth_repository.dart';
import 'package:security_access/domain/repositories/recuperacion_repository.dart';
import 'package:security_access/domain/usecases/resultado_recuperar_contrasena.dart';

/// Pide un código para restablecer la contraseña.
///
/// Para no revelar si el correo existe, siempre genera un código y responde
/// lo mismo. El código solo se guarda (y por lo tanto solo sirve) cuando el
/// correo está registrado.
class SolicitarRecuperacion {
  SolicitarRecuperacion(
    this._usuarios,
    this._codigos, {
    DateTime Function()? ahora,
    String Function()? generarCodigo,
  }) : _ahora = ahora ?? DateTime.now,
       _generarCodigo = generarCodigo ?? _codigoAleatorio;

  final AuthRepository _usuarios;
  final RecuperacionRepository _codigos;
  final DateTime Function() _ahora;
  final String Function() _generarCodigo;

  static const vigencia = Duration(minutes: 15);

  Future<SolicitudRecuperacion> call(String correo) async {
    final normalizado = correo.trim().toLowerCase();
    final codigo = _generarCodigo();
    final usuario = normalizado.isEmpty
        ? null
        : await _usuarios.buscarPorCorreo(normalizado);
    if (usuario != null) {
      await _codigos.guardar(
        CodigoRecuperacion(
          correo: usuario.correo.toLowerCase(),
          codigo: codigo,
          vence: _ahora().add(vigencia),
        ),
      );
    }
    return SolicitudRecuperacion(codigoEnviado: codigo);
  }

  static final _aleatorio = Random.secure();

  static String _codigoAleatorio() {
    return _aleatorio.nextInt(1000000).toString().padLeft(6, '0');
  }
}
