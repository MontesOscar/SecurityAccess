import 'package:flutter/foundation.dart';
import 'package:security_access/domain/entities/usuario.dart';
import 'package:security_access/domain/entities/visita.dart';
import 'package:security_access/domain/usecases/registrar_salida.dart';
import 'package:security_access/domain/usecases/resultado_registrar_salida.dart';

class RegistrarSalidaState {
  const RegistrarSalidaState({
    this.visita,
    this.mensaje,
    this.guardando = false,
  });

  final Visita? visita;
  final String? mensaje;
  final bool guardando;

  bool get puedeConfirmar => visita != null && !guardando;
}

class RegistrarSalidaViewModel extends ChangeNotifier {
  RegistrarSalidaViewModel({required this._registrar, required this._guardia});

  final RegistrarSalida _registrar;
  final Usuario? _guardia;
  var _state = const RegistrarSalidaState();
  var _codigo = '';

  RegistrarSalidaState get state => _state;

  Future<void> leer(String codigo) async {
    final guardia = _guardia;
    if (guardia == null) {
      _state = const RegistrarSalidaState(mensaje: 'No hay una sesión activa');
      notifyListeners();
      return;
    }
    _codigo = codigo.trim();
    final resultado = await _registrar.preparar(
      guardia: guardia,
      codigo: _codigo,
    );
    if (resultado is SalidaPreparada) {
      _state = RegistrarSalidaState(visita: resultado.visita);
    } else if (resultado is SalidaNoRegistrada) {
      _state = RegistrarSalidaState(mensaje: resultado.mensaje);
    }
    notifyListeners();
  }

  Future<ResultadoRegistrarSalida?> confirmar() async {
    final guardia = _guardia;
    final visita = _state.visita;
    if (guardia == null || visita == null || _state.guardando) {
      return null;
    }
    _state = RegistrarSalidaState(visita: visita, guardando: true);
    notifyListeners();
    final resultado = await _registrar.porCodigo(
      guardia: guardia,
      codigo: _codigo,
    );
    if (resultado is SalidaRegistrada) {
      _state = const RegistrarSalidaState();
    } else if (resultado is SalidaNoRegistrada) {
      _state = RegistrarSalidaState(mensaje: resultado.mensaje);
    }
    notifyListeners();
    return resultado;
  }
}
