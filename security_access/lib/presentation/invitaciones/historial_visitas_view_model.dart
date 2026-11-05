import 'package:flutter/foundation.dart';
import 'package:security_access/domain/entities/usuario.dart';
import 'package:security_access/domain/entities/visita.dart';
import 'package:security_access/domain/usecases/consultar_historial_visitas.dart';
import 'package:security_access/presentation/comun/fecha_hora.dart';

class HistorialVisitasState {
  const HistorialVisitasState({
    this.visitas = const [],
    this.errorDesde,
    this.errorHasta,
  });

  final List<Visita> visitas;
  final String? errorDesde;
  final String? errorHasta;

  HistorialVisitasState copyWith({
    List<Visita>? visitas,
    String? errorDesde,
    String? errorHasta,
    bool limpiarErrores = false,
  }) {
    return HistorialVisitasState(
      visitas: visitas ?? this.visitas,
      errorDesde: limpiarErrores ? errorDesde : errorDesde ?? this.errorDesde,
      errorHasta: limpiarErrores ? errorHasta : errorHasta ?? this.errorHasta,
    );
  }
}

class HistorialVisitasViewModel extends ChangeNotifier {
  HistorialVisitasViewModel({
    required this._consultar,
    required this._residente,
  });

  final ConsultarHistorialVisitas _consultar;
  final Usuario? _residente;
  HistorialVisitasState _state = const HistorialVisitasState();

  HistorialVisitasState get state => _state;

  Future<void> cargar({String desde = '', String hasta = ''}) async {
    final residente = _residente;
    if (residente == null) {
      _state = _state.copyWith(visitas: const []);
      notifyListeners();
      return;
    }
    final fechaDesde = desde.trim().isEmpty ? null : leerFecha(desde);
    final fechaHasta = hasta.trim().isEmpty ? null : leerFecha(hasta);
    final errorDesde = desde.trim().isNotEmpty && fechaDesde == null
        ? 'Ingresa la fecha como dd/MM/aaaa'
        : null;
    final errorHasta = hasta.trim().isNotEmpty && fechaHasta == null
        ? 'Ingresa la fecha como dd/MM/aaaa'
        : null;
    if (errorDesde != null || errorHasta != null) {
      _state = _state.copyWith(
        limpiarErrores: true,
        errorDesde: errorDesde,
        errorHasta: errorHasta,
      );
      notifyListeners();
      return;
    }
    final visitas = await _consultar(
      residente: residente,
      desde: fechaDesde,
      hasta: fechaHasta,
    );
    _state = _state.copyWith(visitas: visitas, limpiarErrores: true);
    notifyListeners();
  }
}
