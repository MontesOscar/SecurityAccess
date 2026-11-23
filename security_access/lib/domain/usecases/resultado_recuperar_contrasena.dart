class SolicitudRecuperacion {
  const SolicitudRecuperacion({required this.codigoEnviado});

  static const mensaje = 'Si está registrado, recibirás instrucciones';

  /// Código que se mandaría por correo. Se muestra en pantalla solo como
  /// modo demostración, igual para cualquier correo.
  final String codigoEnviado;
}

sealed class ResultadoRestablecerContrasena {
  const ResultadoRestablecerContrasena();
}

class ContrasenaRestablecida extends ResultadoRestablecerContrasena {
  const ContrasenaRestablecida();

  static const mensaje =
      'Contraseña actualizada correctamente. Inicia sesión con tu nueva contraseña.';
}

class ContrasenaNoRestablecida extends ResultadoRestablecerContrasena {
  const ContrasenaNoRestablecida(this.mensaje);

  final String mensaje;
}
