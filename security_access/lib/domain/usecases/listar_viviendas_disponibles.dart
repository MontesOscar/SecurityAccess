import 'package:security_access/domain/entities/estado_vivienda.dart';
import 'package:security_access/domain/entities/vivienda.dart';
import 'package:security_access/domain/usecases/consultar_viviendas.dart';

class ListarViviendasDisponibles {
  const ListarViviendasDisponibles(this._consultar);

  final ConsultarViviendas _consultar;

  Future<List<Vivienda>> call({String? incluirId}) async {
    final viviendas = await _consultar();
    return viviendas
        .where(
          (vivienda) =>
              vivienda.estado == EstadoVivienda.disponible ||
              (incluirId != null && vivienda.id == incluirId),
        )
        .toList();
  }
}
