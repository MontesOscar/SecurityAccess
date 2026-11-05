import 'package:security_access/domain/entities/estado_invitacion.dart';
import 'package:security_access/domain/entities/estado_visita.dart';
import 'package:security_access/domain/entities/estado_vivienda.dart';
import 'package:security_access/domain/repositories/invitacion_repository.dart';
import 'package:security_access/domain/repositories/vivienda_repository.dart';
import 'package:security_access/domain/usecases/resultado_lectura_qr.dart';

class LeerQr {
  LeerQr(this._invitaciones, this._viviendas, {DateTime Function()? ahora})
    : _ahora = ahora ?? DateTime.now;

  final InvitacionRepository _invitaciones;
  final ViviendaRepository _viviendas;
  final DateTime Function() _ahora;

  static const mensajeIlegible = 'No se pudo leer el código';
  static const mensajeInvalido = 'Código QR inválido';
  static const mensajeCancelada = 'Invitación cancelada';
  static const mensajeVencida = 'Vencida';
  static const mensajeVivienda = 'La vivienda no está activa';
  static const mensajeAunNo = 'La invitación aún no está vigente';
  static const mensajeYaEntro = 'La visita ya registró entrada';
  static const mensajeValida = 'Válida';

  Future<ResultadoLecturaQr> call(String codigo) async {
    final limpio = codigo.trim();
    if (limpio.isEmpty) {
      return const ResultadoLecturaQr(
        clasificacion: ClasificacionQr.invalida,
        mensaje: mensajeIlegible,
        codigo: '',
      );
    }
    final encontrada = await _invitaciones.buscarPorCodigo(limpio);
    if (encontrada == null) {
      return ResultadoLecturaQr(
        clasificacion: ClasificacionQr.invalida,
        mensaje: mensajeInvalido,
        codigo: limpio,
      );
    }
    final momento = _ahora();
    final vigente = encontrada.vigenteEn(momento);
    if (vigente.estado != encontrada.estado) {
      await _invitaciones.guardar(vigente);
    }
    if (vigente.estado == EstadoInvitacion.cancelada) {
      return ResultadoLecturaQr(
        clasificacion: ClasificacionQr.invalida,
        mensaje: mensajeCancelada,
        codigo: limpio,
        invitacion: vigente,
      );
    }
    if (vigente.estado == EstadoInvitacion.vencida) {
      return ResultadoLecturaQr(
        clasificacion: ClasificacionQr.vencida,
        mensaje: mensajeVencida,
        codigo: limpio,
        invitacion: vigente,
      );
    }
    final vivienda = await _viviendas.buscarPorId(vigente.viviendaId);
    if (vivienda == null || vivienda.estado == EstadoVivienda.inactiva) {
      return ResultadoLecturaQr(
        clasificacion: ClasificacionQr.invalida,
        mensaje: mensajeVivienda,
        codigo: limpio,
        invitacion: vigente,
      );
    }
    if (momento.isBefore(vigente.entrada)) {
      return ResultadoLecturaQr(
        clasificacion: ClasificacionQr.invalida,
        mensaje: mensajeAunNo,
        codigo: limpio,
        invitacion: vigente,
      );
    }
    if (vigente.estadoVisita != EstadoVisita.sinEntrada ||
        vigente.estado == EstadoInvitacion.usada) {
      return ResultadoLecturaQr(
        clasificacion: ClasificacionQr.invalida,
        mensaje: mensajeYaEntro,
        codigo: limpio,
        invitacion: vigente,
      );
    }
    if (vigente.estado != EstadoInvitacion.activa) {
      return ResultadoLecturaQr(
        clasificacion: ClasificacionQr.invalida,
        mensaje: mensajeInvalido,
        codigo: limpio,
        invitacion: vigente,
      );
    }
    return ResultadoLecturaQr(
      clasificacion: ClasificacionQr.valida,
      mensaje: mensajeValida,
      codigo: limpio,
      invitacion: vigente,
    );
  }
}
