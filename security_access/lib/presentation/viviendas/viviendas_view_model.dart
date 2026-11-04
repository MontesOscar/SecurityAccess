import 'package:flutter/foundation.dart';
import 'package:security_access/domain/entities/estado_vivienda.dart';
import 'package:security_access/domain/usecases/cambiar_estado_vivienda.dart';
import 'package:security_access/domain/usecases/consultar_viviendas.dart';
import 'package:security_access/domain/usecases/resultado_cambio_estado_vivienda.dart';
import 'package:security_access/presentation/viviendas/viviendas_state.dart';

class ViviendasViewModel extends ChangeNotifier {
  ViviendasViewModel({required this._consultar, required this._cambiarEstado});

  final ConsultarViviendas _consultar;
  final CambiarEstadoVivienda _cambiarEstado;

  ViviendasState state = const ViviendasState();

  static const desactivada = 'Vivienda desactivada correctamente';
  static const reactivada = 'Vivienda reactivada correctamente';

  Future<void> cargar() async {
    final viviendas = await _consultar(
      estado: state.filtro,
      texto: state.busqueda,
    );
    state = state.copyWith(viviendas: viviendas, cargando: false);
    notifyListeners();
  }

  Future<void> cambiarFiltro(EstadoVivienda? filtro) async {
    state = state.copyWith(filtro: filtro, limpiarFiltro: true);
    await cargar();
  }

  Future<void> buscar(String texto) async {
    state = state.copyWith(busqueda: texto);
    await cargar();
  }

  void publicarMensaje(String mensaje) {
    state = state.copyWith(mensaje: mensaje);
    notifyListeners();
  }

  Future<void> desactivar(String id) async {
    await _cambiar(id: id, activar: false, mensaje: desactivada);
  }

  Future<void> reactivar(String id) async {
    await _cambiar(id: id, activar: true, mensaje: reactivada);
  }

  Future<void> _cambiar({
    required String id,
    required bool activar,
    required String mensaje,
  }) async {
    final resultado = await _cambiarEstado(id: id, activar: activar);
    if (resultado is! EstadoViviendaActualizado) {
      return;
    }
    state = state.copyWith(mensaje: mensaje);
    await cargar();
  }
}
