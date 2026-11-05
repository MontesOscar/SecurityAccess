import 'package:security_access/domain/entities/estado_invitacion.dart';
import 'package:security_access/domain/entities/estado_visita.dart';
import 'package:security_access/domain/entities/rol_usuario.dart';
import 'package:security_access/domain/entities/tipo_identificacion.dart';
import 'package:security_access/domain/entities/usuario.dart';
import 'package:security_access/domain/entities/visita.dart';
import 'package:security_access/domain/repositories/invitacion_repository.dart';
import 'package:security_access/domain/usecases/leer_qr.dart';
import 'package:security_access/domain/usecases/resultado_registrar_entrada.dart';

class RegistrarEntrada {
  RegistrarEntrada(this._invitaciones, this._leer, {DateTime Function()? ahora})
    : _ahora = ahora ?? DateTime.now;

  final InvitacionRepository _invitaciones;
  final LeerQr _leer;
  final DateTime Function() _ahora;

  static const mensajeIdentidad =
      'Si la identidad no coincide, no se puede autorizar la entrada';
  static const mensajeDatos =
      'El tipo y el número de identificación son obligatorios';

  Future<ResultadoRegistrarEntrada> call({
    required Usuario guardia,
    required String codigo,
    required TipoIdentificacion? tipo,
    required String numero,
    required bool identidadCoincide,
  }) async {
    if (guardia.rol != RolUsuario.guardia) {
      return const EntradaNoAutorizada(
        'Solo un guardia puede registrar la entrada',
      );
    }
    if (!identidadCoincide) {
      return const EntradaNoAutorizada(mensajeIdentidad);
    }
    final folio = numero.trim();
    if (tipo == null || folio.isEmpty) {
      return const EntradaNoAutorizada(mensajeDatos);
    }
    final lectura = await _leer(codigo);
    if (!lectura.esValida || lectura.invitacion == null) {
      return EntradaNoAutorizada(lectura.mensaje);
    }
    final invitacion = lectura.invitacion!;
    final momento = _ahora();
    final visita = Visita(
      id: await _invitaciones.reservarIdVisita(),
      viviendaId: invitacion.viviendaId,
      residenteId: invitacion.residenteId,
      nombreVisitante: invitacion.nombreVisitante,
      fecha: momento,
      entrada: momento,
      estado: EstadoVisita.dentro,
      guardiaId: guardia.id,
      tipoIdentificacion: tipo.etiqueta,
      numeroIdentificacion: folio,
    );
    await _invitaciones.guardarVisita(visita);
    await _invitaciones.guardar(
      invitacion.copyWith(
        estado: EstadoInvitacion.usada,
        estadoVisita: EstadoVisita.dentro,
      ),
    );
    return EntradaRegistrada(visita);
  }
}
