import 'package:security_access/domain/entities/invitacion.dart';
import 'package:security_access/domain/entities/usuario.dart';
import 'package:security_access/domain/repositories/invitacion_repository.dart';

class BuscarInvitacion {
  BuscarInvitacion(this._repositorio, {DateTime Function()? ahora})
    : _ahora = ahora ?? DateTime.now;

  final InvitacionRepository _repositorio;
  final DateTime Function() _ahora;

  Future<Invitacion?> call({
    required Usuario residente,
    required String invitacionId,
  }) async {
    final encontrada = await _repositorio.buscarPorId(invitacionId);
    if (encontrada == null ||
        encontrada.residenteId != residente.id ||
        encontrada.viviendaId != residente.viviendaId) {
      return null;
    }
    final vigente = encontrada.vigenteEn(_ahora());
    if (vigente.estado != encontrada.estado) {
      await _repositorio.guardar(vigente);
    }
    return vigente;
  }
}
