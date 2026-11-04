enum EstadoVivienda {
  disponible('Disponible'),
  asignada('Asignada'),
  inactiva('Inactiva');

  const EstadoVivienda(this.etiqueta);

  final String etiqueta;
}
