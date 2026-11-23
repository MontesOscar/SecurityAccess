import 'package:flutter/foundation.dart';
import 'package:security_access/domain/entities/usuario.dart';
import 'package:security_access/domain/usecases/cambiar_contrasena.dart';
import 'package:security_access/domain/usecases/resultado_cambiar_contrasena.dart';

class CambiarContrasenaViewModel extends ChangeNotifier {
  CambiarContrasenaViewModel({required this._cambiar, required this._usuario});

  final CambiarContrasena _cambiar;
  final Usuario? _usuario;

  String? _error;
  var _guardando = false;

  String? get error => _error;
  bool get guardando => _guardando;

  /// Devuelve el mensaje de éxito, o `null` si hubo error (ver [error]).
  Future<String?> guardar({
    required String actual,
    required String nueva,
    required String confirmacion,
  }) async {
    final usuario = _usuario;
    if (usuario == null || _guardando) {
      return null;
    }
    _guardando = true;
    _error = null;
    notifyListeners();
    final resultado = await _cambiar(
      usuario: usuario,
      actual: actual,
      nueva: nueva,
      confirmacion: confirmacion,
    );
    _guardando = false;
    switch (resultado) {
      case ContrasenaActualizada():
        notifyListeners();
        return ContrasenaActualizada.mensaje;
      case ContrasenaNoActualizada(:final mensaje):
        _error = mensaje;
        notifyListeners();
        return null;
    }
  }
}
