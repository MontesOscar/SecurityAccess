import 'package:security_access/domain/entities/estado_invitacion.dart';
import 'package:security_access/domain/entities/usuario.dart';
import 'package:security_access/domain/repositories/invitacion_repository.dart';
import 'package:security_access/domain/usecases/resultado_cancelar_invitacion.dart';

class CancelarInvitacion {
  CancelarInvitacion(this._repositorio, {DateTime Function()? ahora})
    : _ahora = ahora ?? DateTime.now;

  final InvitacionRepository _repositorio;
  final DateTime Function() _ahora;

  Future<ResultadoCancelarInvitacion> call({
    required Usuario residente,
    required String invitacionId,
  }) async {
    final actual = await _repositorio.buscarPorId(invitacionId);
    if (actual == null ||
        actual.residenteId != residente.id ||
        actual.viviendaId != residente.viviendaId) {
      return const InvitacionNoCancelable();
    }
    final vigente = actual.vigenteEn(_ahora());
    if (!vigente.puedeCancelarse) {
      if (vigente.estado != actual.estado) {
        await _repositorio.guardar(vigente);
      }
      return const InvitacionNoCancelable();
    }
    final cancelada = vigente.copyWith(estado: EstadoInvitacion.cancelada);
    await _repositorio.guardar(cancelada);
    return InvitacionCancelada(cancelada);
  }
}
