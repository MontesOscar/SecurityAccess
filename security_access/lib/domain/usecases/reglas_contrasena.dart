/// Requisitos mínimos de una contraseña nueva: al menos 8 caracteres,
/// una letra mayúscula y un número.
abstract final class ReglasContrasena {
  static const mensajeRequisitos =
      'La contraseña debe tener al menos 8 caracteres, una mayúscula y un número';
  static const mensajeNoCoinciden = 'Las contraseñas no coinciden';

  static bool cumple(String contrasena) {
    return contrasena.length >= 8 &&
        RegExp('[A-ZÁÉÍÓÚÜÑ]').hasMatch(contrasena) &&
        RegExp('[0-9]').hasMatch(contrasena);
  }
}
