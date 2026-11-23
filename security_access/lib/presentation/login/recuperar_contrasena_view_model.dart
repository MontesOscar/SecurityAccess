import 'package:flutter/foundation.dart';
import 'package:security_access/domain/usecases/restablecer_contrasena.dart';
import 'package:security_access/domain/usecases/resultado_recuperar_contrasena.dart';
import 'package:security_access/domain/usecases/solicitar_recuperacion.dart';
import 'package:security_access/domain/usecases/validar_codigo_recuperacion.dart';
import 'package:security_access/presentation/comun/validacion_formulario.dart';

enum PasoRecuperacion { correo, codigo, nuevaContrasena }

class RecuperarContrasenaViewModel extends ChangeNotifier {
  RecuperarContrasenaViewModel({
    required this._solicitar,
    required this._validar,
    required this._restablecer,
  });

  final SolicitarRecuperacion _solicitar;
  final ValidarCodigoRecuperacion _validar;
  final RestablecerContrasena _restablecer;

  PasoRecuperacion _paso = PasoRecuperacion.correo;
  String _correo = '';
  String _codigo = '';
  String? _codigoDemostracion;
  String? _error;
  var _ocupado = false;

  PasoRecuperacion get paso => _paso;
  String? get codigoDemostracion => _codigoDemostracion;
  String? get error => _error;
  bool get ocupado => _ocupado;

  Future<void> enviar(String correo) async {
    final invalido = ValidacionFormulario.correo(correo);
    if (invalido != null) {
      _error = invalido;
      notifyListeners();
      return;
    }
    _ocupado = true;
    notifyListeners();
    final solicitud = await _solicitar(correo);
    _correo = correo;
    _codigoDemostracion = solicitud.codigoEnviado;
    _paso = PasoRecuperacion.codigo;
    _error = null;
    _ocupado = false;
    notifyListeners();
  }

  Future<void> validarCodigo(String codigo) async {
    _ocupado = true;
    notifyListeners();
    final valido = await _validar(correo: _correo, codigo: codigo);
    _ocupado = false;
    if (valido) {
      _codigo = codigo;
      _paso = PasoRecuperacion.nuevaContrasena;
      _error = null;
    } else {
      _error = ValidarCodigoRecuperacion.mensajeInvalido;
    }
    notifyListeners();
  }

  /// Devuelve el mensaje de éxito, o `null` si hubo error (ver [error]).
  Future<String?> restablecer({
    required String nueva,
    required String confirmacion,
  }) async {
    _ocupado = true;
    notifyListeners();
    final resultado = await _restablecer(
      correo: _correo,
      codigo: _codigo,
      nueva: nueva,
      confirmacion: confirmacion,
    );
    _ocupado = false;
    switch (resultado) {
      case ContrasenaRestablecida():
        _error = null;
        notifyListeners();
        return ContrasenaRestablecida.mensaje;
      case ContrasenaNoRestablecida(:final mensaje):
        _error = mensaje;
        if (mensaje == ValidarCodigoRecuperacion.mensajeInvalido) {
          _paso = PasoRecuperacion.codigo;
        }
        notifyListeners();
        return null;
    }
  }
}
