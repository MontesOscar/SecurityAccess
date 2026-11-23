import 'package:flutter/foundation.dart';
import 'package:security_access/domain/entities/usuario.dart';
import 'package:security_access/domain/entities/visita.dart';
import 'package:security_access/domain/usecases/buscar_entrada_activa.dart';
import 'package:security_access/domain/usecases/registrar_salida.dart';
import 'package:security_access/domain/usecases/resultado_registrar_salida.dart';

class RegistrarSalidaState {
  const RegistrarSalidaState({
    this.busqueda,
    this.salida,
    this.guardando = false,
  });

  final ResultadoBusquedaSalida? busqueda;
  final Visita? salida;
  final bool guardando;

  bool get puedeConfirmar =>
      busqueda is EntradaActivaEncontrada && salida == null && !guardando;
}

class RegistrarSalidaViewModel extends ChangeNotifier {
  RegistrarSalidaViewModel({
    required this._buscar,
    required this._registrar,
    required this._guardia,
  });

  final BuscarEntradaActiva _buscar;
  final RegistrarSalida _registrar;
  final Usuario? _guardia;
  RegistrarSalidaState _state = const RegistrarSalidaState();

  RegistrarSalidaState get state => _state;

  Future<void> leer(String codigo) async {
    final busqueda = await _buscar(codigo);
    _state = RegistrarSalidaState(busqueda: busqueda);
    notifyListeners();
  }

  Future<String?> confirmar() async {
    final guardia = _guardia;
    final busqueda = _state.busqueda;
    if (guardia == null ||
        busqueda is! EntradaActivaEncontrada ||
        !_state.puedeConfirmar) {
      return null;
    }
    _state = RegistrarSalidaState(busqueda: busqueda, guardando: true);
    notifyListeners();
    final resultado = await _registrar(
      guardia: guardia,
      codigo: busqueda.codigo,
    );
    switch (resultado) {
      case SalidaRegistrada(:final visita):
        _state = RegistrarSalidaState(busqueda: busqueda, salida: visita);
        notifyListeners();
        return SalidaRegistrada.mensaje;
      case SalidaNoRegistrada(:final mensaje):
        _state = RegistrarSalidaState(busqueda: SalidaNoDisponible(mensaje));
        notifyListeners();
        return mensaje;
    }
  }
}
