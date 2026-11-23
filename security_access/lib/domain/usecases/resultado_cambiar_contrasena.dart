sealed class ResultadoCambiarContrasena {
  const ResultadoCambiarContrasena();
}

class ContrasenaActualizada extends ResultadoCambiarContrasena {
  const ContrasenaActualizada();

  static const mensaje = 'Contraseña actualizada correctamente';
}

class ContrasenaNoActualizada extends ResultadoCambiarContrasena {
  const ContrasenaNoActualizada(this.mensaje);

  final String mensaje;
}
