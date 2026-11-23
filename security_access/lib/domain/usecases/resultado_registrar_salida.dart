import 'package:security_access/domain/entities/invitacion.dart';
import 'package:security_access/domain/entities/visita.dart';

sealed class ResultadoBusquedaSalida {
  const ResultadoBusquedaSalida();
}

class EntradaActivaEncontrada extends ResultadoBusquedaSalida {
  const EntradaActivaEncontrada({
    required this.codigo,
    required this.invitacion,
    required this.visita,
  });

  final String codigo;
  final Invitacion invitacion;
  final Visita visita;
}

class SalidaNoDisponible extends ResultadoBusquedaSalida {
  const SalidaNoDisponible(this.mensaje);

  final String mensaje;
}

sealed class ResultadoRegistrarSalida {
  const ResultadoRegistrarSalida();
}

class SalidaRegistrada extends ResultadoRegistrarSalida {
  const SalidaRegistrada(this.visita);

  static const mensaje = 'Salida registrada correctamente';

  final Visita visita;
}

class SalidaNoRegistrada extends ResultadoRegistrarSalida {
  const SalidaNoRegistrada(this.mensaje);

  final String mensaje;
}
