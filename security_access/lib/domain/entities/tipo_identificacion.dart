enum TipoIdentificacion {
  ine('INE'),
  pasaporte('Pasaporte'),
  licencia('Licencia de conducir'),
  otro('Otro');

  const TipoIdentificacion(this.etiqueta);

  final String etiqueta;
}
