import 'package:security_access/domain/entities/rol_usuario.dart';
import 'package:security_access/domain/entities/usuario.dart';
import 'package:security_access/domain/entities/visita.dart';
import 'package:security_access/domain/repositories/invitacion_repository.dart';

/// Visitas con entrada registrada y sin salida, ordenadas por hora de entrada.
class ConsultarVisitasDentro {
  const ConsultarVisitasDentro(this._repositorio);

  final InvitacionRepository _repositorio;

  Future<List<Visita>> call({
    required Usuario guardia,
    String? viviendaId,
  }) async {
    if (guardia.rol != RolUsuario.guardia) {
      return const [];
    }
    final visitas = await _repositorio.listarVisitas();
    final dentro = visitas
        .where(
          (visita) =>
              visita.estaDentro &&
              (viviendaId == null || visita.viviendaId == viviendaId),
        )
        .toList();
    dentro.sort((a, b) => a.entrada!.compareTo(b.entrada!));
    return dentro;
  }
}
