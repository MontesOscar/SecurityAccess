import 'package:flutter/foundation.dart';
import 'package:security_access/domain/entities/usuario.dart';
import 'package:security_access/domain/entities/visita.dart';
import 'package:security_access/domain/usecases/consultar_visitas_dentro.dart';
import 'package:security_access/domain/usecases/registrar_salida.dart';
import 'package:security_access/domain/usecases/resultado_registrar_salida.dart';

class VisitasDentroState {
  const VisitasDentroState({
    this.visitas = const [],
    this.consulta = '',
    this.fecha,
    this.cargando = false,
  });

  final List<Visita> visitas;
  final String consulta;
  final DateTime? fecha;
  final bool cargando;

  VisitasDentroState copyWith({
    List<Visita>? visitas,
    String? consulta,
    DateTime? fecha,
    bool? cargando,
    bool limpiarFecha = false,
  }) {
    return VisitasDentroState(
      visitas: visitas ?? this.visitas,
      consulta: consulta ?? this.consulta,
      fecha: limpiarFecha ? null : fecha ?? this.fecha,
      cargando: cargando ?? this.cargando,
    );
  }
}

class VisitasDentroViewModel extends ChangeNotifier {
  VisitasDentroViewModel({
    required this._consultar,
    required this._registrar,
    required this._guardia,
  });

  final ConsultarVisitasDentro _consultar;
  final RegistrarSalida _registrar;
  final Usuario? _guardia;
  var _state = const VisitasDentroState();

  VisitasDentroState get state => _state;

  Future<void> cargar() async {
    _state = _state.copyWith(cargando: true);
    notifyListeners();
    final visitas = await _consultar(
      consulta: _state.consulta,
      fecha: _state.fecha,
    );
    _state = _state.copyWith(visitas: visitas, cargando: false);
    notifyListeners();
  }

  Future<void> filtrar({
    required String consulta,
    DateTime? fecha,
    bool limpiarFecha = false,
  }) async {
    _state = _state.copyWith(
      consulta: consulta,
      fecha: fecha,
      limpiarFecha: limpiarFecha,
    );
    await cargar();
  }

  Future<ResultadoRegistrarSalida?> registrarManual({
    required String visitaId,
    required String motivo,
  }) async {
    final guardia = _guardia;
    if (guardia == null) {
      return const SalidaNoRegistrada('No hay una sesión activa');
    }
    final resultado = await _registrar.manual(
      guardia: guardia,
      visitaId: visitaId,
      motivo: motivo,
    );
    if (resultado is SalidaRegistrada) {
      await cargar();
    }
    return resultado;
  }
}
