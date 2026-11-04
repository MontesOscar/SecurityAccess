import 'package:flutter/foundation.dart';
import 'package:security_access/domain/entities/usuario.dart';
import 'package:security_access/domain/usecases/iniciar_sesion.dart';
import 'package:security_access/domain/usecases/resultado_inicio_sesion.dart';
import 'package:security_access/presentation/login/login_state.dart';

class LoginViewModel extends ChangeNotifier {
  LoginViewModel({required this._iniciarSesion, required this._alIngresar});

  final IniciarSesion _iniciarSesion;
  final void Function(Usuario usuario) _alIngresar;

  LoginState state = const LoginState();

  static const correoObligatorio = 'El correo es obligatorio';
  static const contrasenaObligatoria = 'La contraseña es obligatoria';
  static const credencialesInvalidas = 'Credenciales inválidas';
  static const cuentaInactiva = 'Su cuenta se encuentra desactivada';

  Future<void> enviar({
    required String correo,
    required String contrasena,
  }) async {
    if (state.cargando) {
      return;
    }

    final errorCorreo = correo.trim().isEmpty ? correoObligatorio : null;
    final errorContrasena = contrasena.isEmpty ? contrasenaObligatoria : null;
    if (errorCorreo != null || errorContrasena != null) {
      state = state.copyWith(
        errorCorreo: errorCorreo,
        errorContrasena: errorContrasena,
        limpiarMensaje: true,
        limpiarErroresCampo: true,
      );
      notifyListeners();
      return;
    }

    state = state.copyWith(
      cargando: true,
      limpiarMensaje: true,
      limpiarErroresCampo: true,
    );
    notifyListeners();

    final resultado = await _iniciarSesion(
      correo: correo,
      contrasena: contrasena,
    );

    switch (resultado) {
      case InicioSesionExitoso(:final usuario):
        _alIngresar(usuario);
      case InicioSesionCredencialesInvalidas():
        state = state.copyWith(
          cargando: false,
          mensaje: credencialesInvalidas,
          limpiarMensaje: true,
          limpiarErroresCampo: true,
        );
        notifyListeners();
      case InicioSesionCuentaInactiva():
        state = state.copyWith(
          cargando: false,
          mensaje: cuentaInactiva,
          limpiarMensaje: true,
          limpiarErroresCampo: true,
        );
        notifyListeners();
    }
  }
}
