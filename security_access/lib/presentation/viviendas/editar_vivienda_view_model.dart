import 'package:flutter/foundation.dart';
import 'package:security_access/domain/entities/vivienda.dart';
import 'package:security_access/domain/usecases/editar_vivienda.dart';
import 'package:security_access/domain/usecases/resultado_editar_vivienda.dart';

class EditarViviendaState {
  const EditarViviendaState({
    this.guardando = false,
    this.errorDireccion,
    this.mensaje,
  });

  final bool guardando;
  final String? errorDireccion;
  final String? mensaje;

  EditarViviendaState copyWith({
    bool? guardando,
    String? errorDireccion,
    String? mensaje,
    bool limpiarErrores = false,
    bool limpiarMensaje = false,
  }) {
    return EditarViviendaState(
      guardando: guardando ?? this.guardando,
      errorDireccion: limpiarErrores
          ? errorDireccion
          : errorDireccion ?? this.errorDireccion,
      mensaje: limpiarMensaje ? mensaje : mensaje ?? this.mensaje,
    );
  }
}

class EditarViviendaViewModel extends ChangeNotifier {
  EditarViviendaViewModel({required this._editar, required this.vivienda});

  final EditarVivienda _editar;
  final Vivienda vivienda;
  EditarViviendaState state = const EditarViviendaState();

  static const direccionObligatoria = 'La dirección es obligatoria';

  Future<bool> guardar(String direccion) async {
    if (state.guardando) {
      return false;
    }

    if (direccion.trim().isEmpty) {
      state = state.copyWith(
        errorDireccion: direccionObligatoria,
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

    final resultado = await _editar(
      id: vivienda.id,
      direccion: direccion,
      residenteId: vivienda.residenteId,
      residenteNombre: vivienda.residenteNombre,
      confirmarCambioResidente: false,
    );

    switch (resultado) {
      case ViviendaActualizada():
        return true;
      case DatosEdicionInvalidos():
      case EdicionRequiereConfirmacion():
      case ViviendaEdicionNoEncontrada():
        state = state.copyWith(
          guardando: false,
          mensaje: 'No se pudo actualizar la vivienda',
          limpiarMensaje: true,
          limpiarErrores: true,
        );
        notifyListeners();
        return false;
    }
  }
}
