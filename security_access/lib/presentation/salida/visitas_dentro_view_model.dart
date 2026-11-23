import 'package:flutter/foundation.dart';
import 'package:security_access/domain/entities/usuario.dart';
import 'package:security_access/domain/entities/visita.dart';
import 'package:security_access/domain/usecases/consultar_visitas_dentro.dart';

class OpcionVivienda {
  const OpcionVivienda({required this.id, required this.numero});

  final String id;
  final String numero;
}

class VisitasDentroViewModel extends ChangeNotifier {
  VisitasDentroViewModel({required this._consultar, required this._guardia});

  final ConsultarVisitasDentro _consultar;
  final Usuario? _guardia;

  List<Visita> _visitas = const [];
  List<OpcionVivienda> _viviendas = const [];
  String? _viviendaId;
  var _cargando = true;

  List<Visita> get visitas => _visitas;
  List<OpcionVivienda> get viviendas => _viviendas;
  String? get viviendaId => _viviendaId;
  bool get cargando => _cargando;

  Future<void> cargar() async {
    final guardia = _guardia;
    if (guardia == null) {
      _visitas = const [];
      _viviendas = const [];
      _cargando = false;
      notifyListeners();
      return;
    }
    final todas = await _consultar(guardia: guardia);
    final opciones = <String, String>{
      for (final visita in todas)
        visita.viviendaId: visita.viviendaNumero ?? visita.viviendaId,
    };
    _viviendas = [
      for (final entrada in opciones.entries)
        OpcionVivienda(id: entrada.key, numero: entrada.value),
    ]..sort((a, b) => a.numero.compareTo(b.numero));
    if (_viviendaId != null && !opciones.containsKey(_viviendaId)) {
      _viviendaId = null;
    }
    _visitas = _viviendaId == null
        ? todas
        : await _consultar(guardia: guardia, viviendaId: _viviendaId);
    _cargando = false;
    notifyListeners();
  }

  Future<void> filtrarPorVivienda(String? viviendaId) async {
    _viviendaId = viviendaId;
    await cargar();
  }
}
