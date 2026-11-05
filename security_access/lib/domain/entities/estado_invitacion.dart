enum EstadoInvitacion {
  activa('Activa'),
  usada('Usada'),
  vencida('Vencida'),
  cancelada('Cancelada');

  const EstadoInvitacion(this.etiqueta);

  final String etiqueta;
}
