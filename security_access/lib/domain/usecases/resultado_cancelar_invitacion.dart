import 'package:security_access/domain/entities/invitacion.dart';

sealed class ResultadoCancelarInvitacion {
  const ResultadoCancelarInvitacion();
}

class InvitacionCancelada extends ResultadoCancelarInvitacion {
  const InvitacionCancelada(this.invitacion);

  static const mensaje = 'Invitación cancelada correctamente';
  static const mensajeGuardia = 'Invitación cancelada';

  final Invitacion invitacion;
}

class InvitacionNoCancelable extends ResultadoCancelarInvitacion {
  const InvitacionNoCancelable();

  static const mensaje =
      'Solo se puede cancelar una invitación activa sin entrada';
}
