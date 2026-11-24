String? reglaContrasena(String valor) {
  final tieneMayuscula = RegExp(r'[A-ZÁÉÍÓÚÜÑ]').hasMatch(valor);
  final tieneNumero = RegExp(r'[0-9]').hasMatch(valor);
  if (valor.length < 8 || !tieneMayuscula || !tieneNumero) {
    return 'La contraseña debe tener al menos 8 caracteres, una mayúscula y un número';
  }
  return null;
}
