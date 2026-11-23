import 'package:flutter/foundation.dart';
import 'package:security_access/domain/entities/usuario.dart';
import 'package:security_access/domain/entities/visita.dart';
import 'package:security_access/domain/usecases/buscar_visitas_activas.dart';
import 'package:security_access/domain/usecases/registrar_salida_manual.dart';
import 'package:security_access/domain/usecases/resultado_registrar_salida.dart';

class SalidaManualViewModel extends ChangeNotifier {
  SalidaManualViewModel({
    required this._buscar,
    required this._registrar,
    required this._guardia,
  });

  final BuscarVisitasActivas _buscar;
  final RegistrarSalidaManual _registrar;
  final Usuario? _guardia;

  List<Visita> _visitas = const [];
  String _texto = '';
  var _cargando = true;

  List<Visita> get visitas => _visitas;
  bool get cargando => _cargando;

  Future<void> buscar([String? texto]) async {
    _texto = texto ?? _texto;
    final guardia = _guardia;
    _visitas = guardia == null
        ? const []
        : await _buscar(guardia: guardia, texto: _texto);
    _cargando = false;
    notifyListeners();
  }

  Future<String> cerrar({
    required Visita visita,
    required String motivo,
  }) async {
    final guardia = _guardia;
    if (guardia == null) {
      return RegistrarSalidaManual.mensajeNoAutorizado;
    }
    final resultado = await _registrar(
      guardia: guardia,
      visitaId: visita.id,
      motivo: motivo,
    );
    await buscar();
    return switch (resultado) {
      SalidaRegistrada() => SalidaRegistrada.mensaje,
      SalidaNoRegistrada(:final mensaje) => mensaje,
    };
  }
}
