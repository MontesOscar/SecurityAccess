abstract final class ValidacionFormulario {
  static final _correo = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  static final _nombre = RegExp(
    r"^[A-Za-zÁÉÍÓÚÜÑáéíóúüñ]+(?:[ '\-][A-Za-zÁÉÍÓÚÜÑáéíóúüñ]+)*$",
  );
  static final _numeroVivienda = RegExp(r'^[A-Za-z0-9][A-Za-z0-9-]{0,19}$');

  static String? nombre(String valor) {
    final limpio = valor.trim();
    if (limpio.isEmpty) {
      return 'El nombre es obligatorio';
    }
    if (limpio.length < 2 || !_nombre.hasMatch(limpio)) {
      return 'Ingresa un nombre válido';
    }
    return null;
  }

  static String? correo(String valor) {
    final limpio = valor.trim();
    if (limpio.isEmpty) {
      return 'El correo es obligatorio';
    }
    if (!_correo.hasMatch(limpio)) {
      return 'Ingresa un correo válido';
    }
    return null;
  }

  static String? telefono(String valor) {
    final limpio = valor.trim();
    if (limpio.isEmpty) {
      return 'El teléfono es obligatorio';
    }
    final digitos = limpio.replaceAll(RegExp(r'[\s().-]'), '');
    if (!RegExp(r'^\+?[0-9]{10,15}$').hasMatch(digitos)) {
      return 'Ingresa un teléfono de 10 a 15 dígitos';
    }
    return null;
  }

  static String? numeroVivienda(String valor) {
    final limpio = valor.trim();
    if (limpio.isEmpty) {
      return 'El número de vivienda es obligatorio';
    }
    if (!_numeroVivienda.hasMatch(limpio)) {
      return 'Usa letras, números o guion, sin espacios';
    }
    return null;
  }

  static String? direccion(String valor) {
    final limpio = valor.trim();
    if (limpio.isEmpty) {
      return 'La dirección es obligatoria';
    }
    if (limpio.length < 4) {
      return 'La dirección es demasiado corta';
    }
    return null;
  }

  static String? contrasena(String valor) {
    if (valor.isEmpty) {
      return 'La contraseña es obligatoria';
    }
    return null;
  }
}
