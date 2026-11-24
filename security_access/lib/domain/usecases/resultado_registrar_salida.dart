import 'package:security_access/domain/entities/visita.dart';

sealed class ResultadoRegistrarSalida {
  const ResultadoRegistrarSalida();
}

class SalidaRegistrada extends ResultadoRegistrarSalida {
  const SalidaRegistrada(this.visita);

  static const mensaje = 'Salida registrada correctamente';

  final Visita visita;
}

class SalidaPreparada extends ResultadoRegistrarSalida {
  const SalidaPreparada(this.visita);

  final Visita visita;
}

class SalidaNoRegistrada extends ResultadoRegistrarSalida {
  const SalidaNoRegistrada(this.mensaje);

  final String mensaje;
}
