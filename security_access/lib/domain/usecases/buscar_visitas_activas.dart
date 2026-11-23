import 'package:security_access/domain/entities/usuario.dart';
import 'package:security_access/domain/entities/visita.dart';
import 'package:security_access/domain/usecases/consultar_visitas_dentro.dart';

/// Busca visitas "Dentro" por vivienda, visitante o identificación.
class BuscarVisitasActivas {
  const BuscarVisitasActivas(this._consultar);

  final ConsultarVisitasDentro _consultar;

  Future<List<Visita>> call({
    required Usuario guardia,
    String texto = '',
  }) async {
    final activas = await _consultar(guardia: guardia);
    final buscado = texto.trim().toLowerCase();
    if (buscado.isEmpty) {
      return activas;
    }
    return activas.where((visita) {
      final campos = [
        visita.viviendaNumero ?? visita.viviendaId,
        visita.nombreVisitante,
        visita.numeroIdentificacion ?? '',
      ];
      return campos.any((campo) => campo.toLowerCase().contains(buscado));
    }).toList();
  }
}
