import 'package:security_access/domain/entities/invitacion.dart';

sealed class ResultadoCrearInvitacion {
  const ResultadoCrearInvitacion();
}

class InvitacionCreada extends ResultadoCrearInvitacion {
  const InvitacionCreada(this.invitacion);

  final Invitacion invitacion;
}

class ViviendaNoActiva extends ResultadoCrearInvitacion {
  const ViviendaNoActiva();

  static const mensaje = 'Su vivienda no está activa';
}

class EntradaAnterior extends ResultadoCrearInvitacion {
  const EntradaAnterior();

  static const mensaje = 'La entrada no puede ser anterior a hoy';
}

class SalidaInvalida extends ResultadoCrearInvitacion {
  const SalidaInvalida();

  static const mensaje = 'La salida debe ser posterior a la entrada';
}

class VisitanteInvalido extends ResultadoCrearInvitacion {
  const VisitanteInvalido();
}
