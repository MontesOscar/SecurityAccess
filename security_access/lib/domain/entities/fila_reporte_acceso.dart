class FilaReporteAcceso {
  const FilaReporteAcceso({
    required this.id,
    required this.visitante,
    required this.viviendaNumero,
    required this.momento,
    required this.guardia,
    required this.estado,
    required this.sinSalida,
    this.entrada,
    this.salida,
    this.identificacion = '',
  });

  final String id;
  final String visitante;
  final String viviendaNumero;
  final DateTime momento;
  final DateTime? entrada;
  final DateTime? salida;
  final String guardia;
  final String identificacion;
  final String estado;
  final bool sinSalida;
}
