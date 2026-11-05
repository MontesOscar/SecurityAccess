import 'package:flutter/foundation.dart';
import 'package:security_access/domain/entities/rol_usuario.dart';
import 'package:security_access/domain/entities/vivienda.dart';
import 'package:security_access/domain/usecases/crear_usuario.dart';
import 'package:security_access/domain/usecases/listar_viviendas_disponibles.dart';
import 'package:security_access/presentation/comun/validacion_formulario.dart';
import 'package:security_access/domain/usecases/resultado_crear_usuario.dart';

class CrearUsuarioState {
  const CrearUsuarioState({
    this.guardando = false,
    this.viviendas = const [],
    this.rol,
    this.viviendaId,
    this.errorNombre,
    this.errorCorreo,
    this.errorTelefono,
    this.errorRol,
    this.errorVivienda,
  });

  final bool guardando;
  final List<Vivienda> viviendas;
  final RolUsuario? rol;
  final String? viviendaId;
  final String? errorNombre;
  final String? errorCorreo;
  final String? errorTelefono;
  final String? errorRol;
  final String? errorVivienda;

  CrearUsuarioState copyWith({
    bool? guardando,
    List<Vivienda>? viviendas,
    RolUsuario? rol,
    String? viviendaId,
    String? errorNombre,
    String? errorCorreo,
    String? errorTelefono,
    String? errorRol,
    String? errorVivienda,
    bool limpiarRol = false,
    bool limpiarViviendaSeleccion = false,
    bool limpiarErrores = false,
  }) {
    return CrearUsuarioState(
      guardando: guardando ?? this.guardando,
      viviendas: viviendas ?? this.viviendas,
      rol: limpiarRol ? rol : rol ?? this.rol,
      viviendaId: limpiarViviendaSeleccion
          ? viviendaId
          : viviendaId ?? this.viviendaId,
      errorNombre: limpiarErrores
          ? errorNombre
          : errorNombre ?? this.errorNombre,
      errorCorreo: limpiarErrores
          ? errorCorreo
          : errorCorreo ?? this.errorCorreo,
      errorTelefono: limpiarErrores
          ? errorTelefono
          : errorTelefono ?? this.errorTelefono,
      errorRol: limpiarErrores ? errorRol : errorRol ?? this.errorRol,
      errorVivienda: limpiarErrores
          ? errorVivienda
          : errorVivienda ?? this.errorVivienda,
    );
  }
}

class CrearUsuarioViewModel extends ChangeNotifier {
  CrearUsuarioViewModel({required this._crear, required this._listarViviendas});

  final CrearUsuario _crear;
  final ListarViviendasDisponibles _listarViviendas;
  CrearUsuarioState state = const CrearUsuarioState();

  static const rolObligatorio = 'El rol es obligatorio';
  static const viviendaObligatoria = 'Debes asignar una vivienda';
  static const correoRegistrado = 'El correo ya está registrado';
  static const viviendaNoDisponible = 'La vivienda no está disponible';

  Future<void> cargar() async {
    final viviendas = await _listarViviendas();
    state = state.copyWith(viviendas: viviendas);
    notifyListeners();
  }

  void seleccionarRol(RolUsuario? rol) {
    final limpiarVivienda = rol != RolUsuario.residente;
    state = state.copyWith(
      rol: rol,
      limpiarRol: true,
      limpiarViviendaSeleccion: limpiarVivienda,
      errorRol: null,
      errorVivienda: limpiarVivienda ? null : state.errorVivienda,
      limpiarErrores: true,
      errorNombre: state.errorNombre,
      errorCorreo: state.errorCorreo,
      errorTelefono: state.errorTelefono,
    );
    notifyListeners();
  }

  void seleccionarVivienda(String? viviendaId) {
    state = state.copyWith(
      viviendaId: viviendaId,
      limpiarViviendaSeleccion: true,
      errorVivienda: null,
      limpiarErrores: true,
      errorNombre: state.errorNombre,
      errorCorreo: state.errorCorreo,
      errorTelefono: state.errorTelefono,
      errorRol: state.errorRol,
    );
    notifyListeners();
  }

  Future<UsuarioCreado?> guardar({
    required String nombre,
    required String correo,
    required String telefono,
  }) async {
    if (state.guardando) {
      return null;
    }
    final errorNombre = ValidacionFormulario.nombre(nombre);
    final errorCorreo = ValidacionFormulario.correo(correo);
    final errorTelefono = ValidacionFormulario.telefono(telefono);
    final errorRol = state.rol == null ? rolObligatorio : null;
    final errorVivienda =
        state.rol == RolUsuario.residente && state.viviendaId == null
        ? viviendaObligatoria
        : null;
    if (errorNombre != null ||
        errorCorreo != null ||
        errorTelefono != null ||
        errorRol != null ||
        errorVivienda != null) {
      state = state.copyWith(
        errorNombre: errorNombre,
        errorCorreo: errorCorreo,
        errorTelefono: errorTelefono,
        errorRol: errorRol,
        errorVivienda: errorVivienda,
        limpiarErrores: true,
      );
      notifyListeners();
      return null;
    }

    state = state.copyWith(guardando: true, limpiarErrores: true);
    notifyListeners();

    final resultado = await _crear(
      nombre: nombre,
      correo: correo,
      telefono: telefono,
      rol: state.rol!,
      viviendaId: state.viviendaId,
    );
    switch (resultado) {
      case UsuarioCreado():
        return resultado;
      case CorreoYaRegistrado():
        _errorEn(errorCorreo: correoRegistrado);
      case ViviendaObligatoria():
      case ViviendaNoDisponible():
        _errorEn(errorVivienda: viviendaNoDisponible);
      case DatosUsuarioInvalidos():
        _errorEn();
    }
    return null;
  }

  void _conservarErrores({
    String? errorNombre,
    String? errorCorreo,
    String? errorTelefono,
    bool limpiarNombre = false,
    bool limpiarCorreo = false,
    bool limpiarTelefono = false,
  }) {
    state = state.copyWith(
      errorNombre: limpiarNombre ? errorNombre : state.errorNombre,
      errorCorreo: limpiarCorreo ? errorCorreo : state.errorCorreo,
      errorTelefono: limpiarTelefono ? errorTelefono : state.errorTelefono,
      errorRol: state.errorRol,
      errorVivienda: state.errorVivienda,
      limpiarErrores: true,
    );
    notifyListeners();
  }

  void corregirNombre() => _conservarErrores(limpiarNombre: true);

  void corregirCorreo() => _conservarErrores(limpiarCorreo: true);

  void corregirTelefono() => _conservarErrores(limpiarTelefono: true);

  void _errorEn({String? errorCorreo, String? errorVivienda}) {
    state = state.copyWith(
      guardando: false,
      errorCorreo: errorCorreo,
      errorVivienda: errorVivienda,
      limpiarErrores: true,
    );
    notifyListeners();
  }
}
