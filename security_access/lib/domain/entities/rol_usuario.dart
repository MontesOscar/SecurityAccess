enum RolUsuario {
  administrador('Administrador'),
  residente('Residente'),
  guardia('Guardia');

  const RolUsuario(this.etiqueta);

  final String etiqueta;
}
