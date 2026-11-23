class CodigoRecuperacion {
  const CodigoRecuperacion({
    required this.correo,
    required this.codigo,
    required this.vence,
  });

  final String correo;
  final String codigo;
  final DateTime vence;

  bool vigenteEn(DateTime momento) => momento.isBefore(vence);
}
