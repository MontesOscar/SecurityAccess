import 'package:security_access/domain/entities/acceso_rechazado.dart';
import 'package:security_access/domain/entities/motivo_rechazo.dart';
import 'package:security_access/domain/entities/rol_usuario.dart';
import 'package:security_access/domain/entities/usuario.dart';
import 'package:security_access/domain/repositories/invitacion_repository.dart';
import 'package:security_access/domain/usecases/leer_qr.dart';
import 'package:security_access/domain/usecases/resultado_lectura_qr.dart';
import 'package:security_access/domain/usecases/resultado_rechazar_acceso.dart';

class RechazarAcceso {
  RechazarAcceso(this._repositorio, {DateTime Function()? ahora})
    : _ahora = ahora ?? DateTime.now;

  final InvitacionRepository _repositorio;
  final DateTime Function() _ahora;

  static const mensajeDescripcion = 'Describe el motivo del rechazo';

  Future<ResultadoRechazarAcceso> call({
    required Usuario guardia,
    required ResultadoLecturaQr lectura,
    required MotivoRechazo? motivo,
    required String descripcion,
  }) async {
    if (guardia.rol != RolUsuario.guardia) {
      return const RechazoInvalido(
        'Solo un guardia puede registrar el rechazo',
      );
    }
    if (lectura.codigo.isEmpty &&
        lectura.invitacion == null &&
        lectura.mensaje != LeerQr.mensajeIlegible) {
      return const RechazoInvalido('Debe existir un código escaneado');
    }
    if (motivo == null) {
      return const RechazoInvalido('El motivo es obligatorio');
    }
    final detalle = descripcion.trim();
    if (motivo == MotivoRechazo.otro && detalle.isEmpty) {
      return const RechazoInvalido(mensajeDescripcion);
    }
    final invitacion = lectura.invitacion;
    final rechazo = AccesoRechazado(
      id: await _repositorio.reservarIdRechazo(),
      codigoQr: lectura.codigo,
      guardiaId: guardia.id,
      fecha: _ahora(),
      motivo: motivo,
      viviendaId: invitacion?.viviendaId,
      viviendaNumero: invitacion?.viviendaNumero,
      invitacionId: invitacion?.id,
      descripcion: detalle.isEmpty ? null : detalle,
    );
    await _repositorio.guardarRechazo(rechazo);
    return AccesoRechazadoRegistrado(rechazo);
  }
}
