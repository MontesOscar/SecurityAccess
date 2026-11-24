import 'package:security_access/domain/entities/visita.dart';
import 'package:security_access/domain/repositories/invitacion_repository.dart';

class ConsultarVisitasDentro {
  const ConsultarVisitasDentro(this._repositorio);

  final InvitacionRepository _repositorio;

  Future<List<Visita>> call({String consulta = '', DateTime? fecha}) async {
    final texto = consulta.trim().toLowerCase();
    final visitas = await _repositorio.listarVisitas();
    final dentro = visitas.where((visita) {
      if (!visita.estaDentro) {
        return false;
      }
      if (fecha != null) {
        final entrada = visita.entrada ?? visita.fecha;
        final mismoDia =
            entrada.year == fecha.year &&
            entrada.month == fecha.month &&
            entrada.day == fecha.day;
        if (!mismoDia) {
          return false;
        }
      }
      if (texto.isEmpty) {
        return true;
      }
      final campos = [
        visita.nombreVisitante,
        visita.viviendaNumero,
        visita.numeroIdentificacion ?? '',
        visita.tipoIdentificacion ?? '',
      ].join(' ').toLowerCase();
      return campos.contains(texto);
    }).toList();
    dentro.sort(
      (a, b) => (a.entrada ?? a.fecha).compareTo(b.entrada ?? b.fecha),
    );
    return dentro;
  }
}
