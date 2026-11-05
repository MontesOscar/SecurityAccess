enum MotivoRechazo {
  qrInvalido('QR inválido'),
  vencido('Vencido'),
  cancelado('Cancelado'),
  identidadNoCoincide('Identidad no coincidente'),
  viviendaInactiva('Vivienda inactiva'),
  otro('Otro');

  const MotivoRechazo(this.etiqueta);

  final String etiqueta;
}
