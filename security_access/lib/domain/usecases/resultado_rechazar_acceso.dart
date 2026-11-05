import 'package:security_access/domain/entities/acceso_rechazado.dart';

sealed class ResultadoRechazarAcceso {
  const ResultadoRechazarAcceso();
}

class AccesoRechazadoRegistrado extends ResultadoRechazarAcceso {
  const AccesoRechazadoRegistrado(this.rechazo);

  static const mensaje = 'Acceso rechazado correctamente';

  final AccesoRechazado rechazo;
}

class RechazoInvalido extends ResultadoRechazarAcceso {
  const RechazoInvalido(this.mensaje);

  final String mensaje;
}
