import 'package:flutter/foundation.dart';
import 'package:security_access/domain/entities/vivienda.dart';
import 'package:security_access/domain/usecases/editar_vivienda.dart';
import 'package:security_access/domain/usecases/resultado_editar_vivienda.dart';
import 'package:security_access/presentation/comun/validacion_formulario.dart';

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

  void corregirDireccion() {
    if (state.errorDireccion == null && state.mensaje == null) {
      return;
    }
    state = state.copyWith(
      errorDireccion: null,
      limpiarErrores: true,
      limpiarMensaje: true,
    );
    notifyListeners();
  }

  Future<bool> guardar(String direccion) async {
    if (state.guardando) {
      return false;
    }

    final errorDireccion = ValidacionFormulario.direccion(direccion);
    if (errorDireccion != null) {
      state = state.copyWith(
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
          errorDireccion: 'No se pudo actualizar la vivienda',
          limpiarErrores: true,
          limpiarMensaje: true,
        );
        notifyListeners();
        return false;
    }
  }
}
