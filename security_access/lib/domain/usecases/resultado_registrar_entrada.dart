import 'package:security_access/domain/entities/visita.dart';

sealed class ResultadoRegistrarEntrada {
  const ResultadoRegistrarEntrada();
}

class EntradaRegistrada extends ResultadoRegistrarEntrada {
  const EntradaRegistrada(this.visita);

  static const mensaje = 'Entrada registrada correctamente';

  final Visita visita;
}

class EntradaNoAutorizada extends ResultadoRegistrarEntrada {
  const EntradaNoAutorizada(this.mensaje);

  final String mensaje;
}
