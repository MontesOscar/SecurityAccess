import 'package:flutter/foundation.dart';
import 'package:security_access/domain/entities/rol_usuario.dart';
import 'package:security_access/domain/entities/usuario.dart';
import 'package:security_access/domain/entities/vivienda.dart';
import 'package:security_access/domain/usecases/editar_usuario.dart';
import 'package:security_access/domain/usecases/listar_viviendas_disponibles.dart';
import 'package:security_access/presentation/comun/validacion_formulario.dart';
import 'package:security_access/domain/usecases/resultado_editar_usuario.dart';

class EditarUsuarioState {
  const EditarUsuarioState({
    required this.rol,
    this.guardando = false,
    this.viviendas = const [],
    this.viviendaId,
    this.errorNombre,
    this.errorTelefono,
    this.errorVivienda,
  });

  final bool guardando;
  final List<Vivienda> viviendas;
  final RolUsuario rol;
  final String? viviendaId;
  final String? errorNombre;
  final String? errorTelefono;
  final String? errorVivienda;

  EditarUsuarioState copyWith({
    bool? guardando,
    List<Vivienda>? viviendas,
    RolUsuario? rol,
    String? viviendaId,
    String? errorNombre,
    String? errorTelefono,
    String? errorVivienda,
    bool limpiarVivienda = false,
    bool limpiarErrores = false,
  }) {
    return EditarUsuarioState(
      guardando: guardando ?? this.guardando,
      viviendas: viviendas ?? this.viviendas,
      rol: rol ?? this.rol,
      viviendaId: limpiarVivienda ? viviendaId : viviendaId ?? this.viviendaId,
      errorNombre: limpiarErrores
          ? errorNombre
          : errorNombre ?? this.errorNombre,
      errorTelefono: limpiarErrores
          ? errorTelefono
          : errorTelefono ?? this.errorTelefono,
      errorVivienda: limpiarErrores
          ? errorVivienda
          : errorVivienda ?? this.errorVivienda,
    );
  }
}

class EditarUsuarioViewModel extends ChangeNotifier {
  EditarUsuarioViewModel({
    required this._editar,
    required this._listarViviendas,
    required this.usuario,
  }) : state = EditarUsuarioState(
         rol: usuario.rol,
         viviendaId: usuario.viviendaId,
       );

  final EditarUsuario _editar;
  final ListarViviendasDisponibles _listarViviendas;
  final Usuario usuario;
  EditarUsuarioState state;

  static const viviendaObligatoria = 'Debes asignar una vivienda';
  static const viviendaNoDisponible = 'La vivienda no está disponible';

  bool get cambiaAsignacion {
    final nuevaVivienda = state.rol == RolUsuario.residente
        ? state.viviendaId
        : null;
    return usuario.rol != state.rol || usuario.viviendaId != nuevaVivienda;
  }

  Future<void> cargar() async {
    final viviendas = await _listarViviendas(incluirId: usuario.viviendaId);
    state = state.copyWith(viviendas: viviendas);
    notifyListeners();
  }

  void seleccionarRol(RolUsuario? rol) {
    if (rol == null) {
      return;
    }
    final dejaLaVivienda = rol != RolUsuario.residente;
    state = state.copyWith(
      rol: rol,
      limpiarVivienda: dejaLaVivienda,
      errorVivienda: dejaLaVivienda ? null : state.errorVivienda,
      errorNombre: state.errorNombre,
      errorTelefono: state.errorTelefono,
      limpiarErrores: true,
    );
    notifyListeners();
  }

  void seleccionarVivienda(String? viviendaId) {
    state = state.copyWith(
      viviendaId: viviendaId,
      limpiarVivienda: true,
      errorVivienda: null,
      errorNombre: state.errorNombre,
      errorTelefono: state.errorTelefono,
      limpiarErrores: true,
    );
    notifyListeners();
  }

  void corregirNombre() {
    state = state.copyWith(
      errorNombre: null,
      errorTelefono: state.errorTelefono,
      errorVivienda: state.errorVivienda,
      limpiarErrores: true,
    );
    notifyListeners();
  }

  void corregirTelefono() {
    state = state.copyWith(
      errorTelefono: null,
      errorNombre: state.errorNombre,
      errorVivienda: state.errorVivienda,
      limpiarErrores: true,
    );
    notifyListeners();
  }

  Future<ResultadoEditarUsuario?> guardar({
    required String nombre,
    required String telefono,
    required bool confirmarCambioVivienda,
  }) async {
    if (state.guardando) {
      return null;
    }
    final errorNombre = ValidacionFormulario.nombre(nombre);
    final errorTelefono = ValidacionFormulario.telefono(telefono);
    final errorVivienda =
        state.rol == RolUsuario.residente && state.viviendaId == null
        ? viviendaObligatoria
        : null;
    if (errorNombre != null || errorTelefono != null || errorVivienda != null) {
      state = state.copyWith(
        errorNombre: errorNombre,
        errorTelefono: errorTelefono,
        errorVivienda: errorVivienda,
        limpiarErrores: true,
      );
      notifyListeners();
      return null;
    }

    state = state.copyWith(guardando: true, limpiarErrores: true);
    notifyListeners();

    final resultado = await _editar(
      id: usuario.id,
      nombre: nombre,
      telefono: telefono,
      rol: state.rol,
      viviendaId: state.viviendaId,
      confirmarCambioVivienda: confirmarCambioVivienda,
    );
    switch (resultado) {
      case UsuarioActualizado():
      case EdicionUsuarioRequiereConfirmacion():
        state = state.copyWith(guardando: false);
        notifyListeners();
        return resultado;
      case ViviendaEdicionObligatoria():
      case ViviendaEdicionNoDisponible():
        state = state.copyWith(
          guardando: false,
          errorVivienda: viviendaNoDisponible,
          limpiarErrores: true,
        );
        notifyListeners();
      case DatosEdicionUsuarioInvalidos():
      case UsuarioEdicionNoEncontrado():
        state = state.copyWith(
          guardando: false,
          errorNombre: 'No se pudo actualizar el usuario',
          limpiarErrores: true,
        );
        notifyListeners();
    }
    return null;
  }
}
