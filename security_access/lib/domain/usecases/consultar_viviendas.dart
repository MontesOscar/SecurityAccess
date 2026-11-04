import 'package:security_access/domain/entities/estado_vivienda.dart';
import 'package:security_access/domain/entities/vivienda.dart';
import 'package:security_access/domain/repositories/vivienda_repository.dart';

class ConsultarViviendas {
  const ConsultarViviendas(this._repositorio);

  final ViviendaRepository _repositorio;

  Future<List<Vivienda>> call({
    EstadoVivienda? estado,
    String texto = '',
  }) async {
    final consulta = texto.trim().toLowerCase();
    final viviendas = await _repositorio.listar();
    final filtradas = viviendas.where((vivienda) {
      final coincideEstado = estado == null || vivienda.estado == estado;
      if (!coincideEstado) {
        return false;
      }
      if (consulta.isEmpty) {
        return true;
      }
      final residente = vivienda.residenteNombre?.toLowerCase() ?? '';
      return vivienda.numero.toLowerCase().contains(consulta) ||
          residente.contains(consulta);
    }).toList();

    filtradas.sort((a, b) => _compararNumero(a.numero, b.numero));
    return filtradas;
  }

  int _compararNumero(String a, String b) {
    final numeroA = int.tryParse(a);
    final numeroB = int.tryParse(b);
    if (numeroA != null && numeroB != null) {
      return numeroA.compareTo(numeroB);
    }
    return a.toLowerCase().compareTo(b.toLowerCase());
  }
}
