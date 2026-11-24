import 'package:security_access/domain/entities/estado_visita.dart';
import 'package:security_access/domain/entities/rol_usuario.dart';
import 'package:security_access/domain/entities/usuario.dart';
import 'package:security_access/domain/entities/visita.dart';
import 'package:security_access/domain/repositories/invitacion_repository.dart';
import 'package:security_access/domain/usecases/resultado_registrar_salida.dart';

class RegistrarSalida {
  RegistrarSalida(this._repositorio, {DateTime Function()? ahora})
    : _ahora = ahora ?? DateTime.now;

  final InvitacionRepository _repositorio;
  final DateTime Function() _ahora;

  static const sinEntrada = 'No hay registro de entrada';
  static const yaCompletada = 'La visita ya fue completada';
  static const motivoObligatorio = 'El motivo es obligatorio';
  static const ilegible = 'No se pudo leer el código';

  Future<ResultadoRegistrarSalida> preparar({
    required Usuario guardia,
    required String codigo,
  }) async {
    if (guardia.rol != RolUsuario.guardia) {
      return const SalidaNoRegistrada(
        'Solo un guardia puede registrar la salida',
      );
    }
    final limpio = codigo.trim();
    if (limpio.isEmpty) {
      return const SalidaNoRegistrada(ilegible);
    }
    final invitacion = await _repositorio.buscarPorCodigo(limpio);
    if (invitacion == null) {
      return const SalidaNoRegistrada(sinEntrada);
    }
    final visitas = await _repositorio.listarVisitas();
    final activa = _activa(visitas, invitacion.id);
    if (activa == null) {
      final completada = visitas.any(
        (visita) =>
            visita.invitacionId == invitacion.id &&
            visita.estado == EstadoVisita.completada,
      );
      return SalidaNoRegistrada(completada ? yaCompletada : sinEntrada);
    }
    return SalidaPreparada(activa);
  }

  Future<ResultadoRegistrarSalida> porCodigo({
    required Usuario guardia,
    required String codigo,
  }) async {
    final preparada = await preparar(guardia: guardia, codigo: codigo);
    if (preparada is! SalidaPreparada) {
      return preparada;
    }
    return _cerrar(
      guardia: guardia,
      visita: preparada.visita,
      invitacionId: preparada.visita.invitacionId,
    );
  }

  Future<ResultadoRegistrarSalida> manual({
    required Usuario guardia,
    required String visitaId,
    required String motivo,
  }) async {
    if (guardia.rol != RolUsuario.guardia) {
      return const SalidaNoRegistrada(
        'Solo un guardia puede registrar la salida',
      );
    }
    final detalle = motivo.trim();
    if (detalle.isEmpty) {
      return const SalidaNoRegistrada(motivoObligatorio);
    }
    final visitas = await _repositorio.listarVisitas();
    Visita? visita;
    for (final actual in visitas) {
      if (actual.id == visitaId) {
        visita = actual;
        break;
      }
    }
    if (visita == null || !visita.estaDentro) {
      final cerrada = visita?.estado == EstadoVisita.completada;
      return SalidaNoRegistrada(cerrada ? yaCompletada : sinEntrada);
    }
    return _cerrar(
      guardia: guardia,
      visita: visita,
      invitacionId: visita.invitacionId,
      motivo: detalle,
    );
  }

  Visita? _activa(List<Visita> visitas, String invitacionId) {
    for (final visita in visitas) {
      if (visita.invitacionId == invitacionId && visita.estaDentro) {
        return visita;
      }
    }
    return null;
  }

  Future<ResultadoRegistrarSalida> _cerrar({
    required Usuario guardia,
    required Visita visita,
    required String? invitacionId,
    String? motivo,
  }) async {
    final momento = _ahora();
    final cerrada = visita.copyWith(
      salida: momento,
      estado: EstadoVisita.completada,
      guardiaSalidaId: guardia.id,
      motivoSalida: motivo,
    );
    await _repositorio.guardarVisita(cerrada);
    if (invitacionId != null) {
      final invitacion = await _repositorio.buscarPorId(invitacionId);
      if (invitacion != null) {
        await _repositorio.guardar(
          invitacion.copyWith(estadoVisita: EstadoVisita.completada),
        );
      }
    }
    return SalidaRegistrada(cerrada);
  }
}
