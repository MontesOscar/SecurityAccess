import 'package:flutter/foundation.dart';
import 'package:security_access/domain/usecases/crear_vivienda.dart';
import 'package:security_access/domain/usecases/resultado_crear_vivienda.dart';

class CrearViviendaState {
  const CrearViviendaState({
    this.guardando = false,
    this.errorNumero,
    this.errorDireccion,
    this.mensaje,
  });

  final bool guardando;
  final String? errorNumero;
  final String? errorDireccion;
  final String? mensaje;

  CrearViviendaState copyWith({
    bool? guardando,
    String? errorNumero,
    String? errorDireccion,
    String? mensaje,
    bool limpiarErrores = false,
    bool limpiarMensaje = false,
  }) {
    return CrearViviendaState(
      guardando: guardando ?? this.guardando,
      errorNumero: limpiarErrores
          ? errorNumero
          : errorNumero ?? this.errorNumero,
      errorDireccion: limpiarErrores
          ? errorDireccion
          : errorDireccion ?? this.errorDireccion,
      mensaje: limpiarMensaje ? mensaje : mensaje ?? this.mensaje,
    );
  }
}

class CrearViviendaViewModel extends ChangeNotifier {
  CrearViviendaViewModel(this._crear);

  final CrearVivienda _crear;
  CrearViviendaState state = const CrearViviendaState();

  static const numeroObligatorio = 'El número de vivienda es obligatorio';
  static const direccionObligatoria = 'La dirección es obligatoria';
  static const yaRegistrada = 'La vivienda ya está registrada';

  Future<bool> guardar({
    required String numero,
    required String direccion,
  }) async {
    if (state.guardando) {
      return false;
    }

    final errorNumero = numero.trim().isEmpty ? numeroObligatorio : null;
    final errorDireccion = direccion.trim().isEmpty
        ? direccionObligatoria
        : null;
    if (errorNumero != null || errorDireccion != null) {
      state = state.copyWith(
        errorNumero: errorNumero,
        errorDireccion: errorDireccion,
        limpiarErrores: true,
        limpiarMensaje: true,
      );
      notifyListeners();
      return false;
    }

    state = state.copyWith(
      guardando: true,
      limpiarErrores: true,
      limpiarMensaje: true,
    );
    notifyListeners();

    final resultado = await _crear(numero: numero, direccion: direccion);
    switch (resultado) {
      case ViviendaCreada():
        return true;
      case ViviendaYaRegistrada():
        state = state.copyWith(
          guardando: false,
          mensaje: yaRegistrada,
          limpiarMensaje: true,
          limpiarErrores: true,
        );
        notifyListeners();
        return false;
      case DatosViviendaInvalidos():
        state = state.copyWith(
          guardando: false,
          errorNumero: errorNumero,
          errorDireccion: errorDireccion,
          limpiarErrores: true,
          limpiarMensaje: true,
        );
        notifyListeners();
        return false;
    }
  }
}
