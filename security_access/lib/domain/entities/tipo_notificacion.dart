enum TipoNotificacion {
  entrada('Entrada'),
  salida('Salida'),
  rechazo('Rechazo');

  const TipoNotificacion(this.etiqueta);

  final String etiqueta;
}
