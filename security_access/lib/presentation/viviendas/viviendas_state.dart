import 'package:security_access/domain/entities/estado_vivienda.dart';
import 'package:security_access/domain/entities/vivienda.dart';

class ViviendasState {
  const ViviendasState({
    this.cargando = false,
    this.viviendas = const [],
    this.filtro,
    this.busqueda = '',
    this.mensaje,
  });

  final bool cargando;
  final List<Vivienda> viviendas;
  final EstadoVivienda? filtro;
  final String busqueda;
  final String? mensaje;

  ViviendasState copyWith({
    bool? cargando,
    List<Vivienda>? viviendas,
    EstadoVivienda? filtro,
    String? busqueda,
    String? mensaje,
    bool limpiarFiltro = false,
    bool limpiarMensaje = false,
  }) {
    return ViviendasState(
      cargando: cargando ?? this.cargando,
      viviendas: viviendas ?? this.viviendas,
      filtro: limpiarFiltro ? filtro : filtro ?? this.filtro,
      busqueda: busqueda ?? this.busqueda,
      mensaje: limpiarMensaje ? mensaje : mensaje ?? this.mensaje,
    );
  }
}
