enum EstadoVisita {
  sinEntrada('Sin entrada'),
  dentro('Dentro'),
  completada('Completada');

  const EstadoVisita(this.etiqueta);

  final String etiqueta;
}
