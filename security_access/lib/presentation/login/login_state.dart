class LoginState {
  const LoginState({
    this.cargando = false,
    this.mensaje,
    this.errorCorreo,
    this.errorContrasena,
  });

  final bool cargando;
  final String? mensaje;
  final String? errorCorreo;
  final String? errorContrasena;

  LoginState copyWith({
    bool? cargando,
    String? mensaje,
    String? errorCorreo,
    String? errorContrasena,
    bool limpiarMensaje = false,
    bool limpiarErroresCampo = false,
  }) {
    return LoginState(
      cargando: cargando ?? this.cargando,
      mensaje: limpiarMensaje ? mensaje : mensaje ?? this.mensaje,
      errorCorreo: limpiarErroresCampo
          ? errorCorreo
          : errorCorreo ?? this.errorCorreo,
      errorContrasena: limpiarErroresCampo
          ? errorContrasena
          : errorContrasena ?? this.errorContrasena,
    );
  }
}
