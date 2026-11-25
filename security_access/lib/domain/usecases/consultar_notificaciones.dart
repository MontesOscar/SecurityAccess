import 'package:security_access/domain/entities/notificacion.dart';
import 'package:security_access/domain/entities/usuario.dart';
import 'package:security_access/domain/repositories/invitacion_repository.dart';

class ConsultarNotificaciones {
  const ConsultarNotificaciones(this._repositorio);

  final InvitacionRepository _repositorio;

  Future<List<Notificacion>> call(Usuario residente) async {
    final avisos = await _repositorio.listarNotificaciones();
    final propias = avisos
        .where((aviso) => aviso.residenteId == residente.id)
        .toList();
    propias.sort((a, b) => b.fecha.compareTo(a.fecha));
    return propias;
  }
}
