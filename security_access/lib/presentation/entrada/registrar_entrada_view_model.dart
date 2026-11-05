import 'package:flutter/foundation.dart';
import 'package:security_access/domain/entities/motivo_rechazo.dart';
import 'package:security_access/domain/entities/tipo_identificacion.dart';
import 'package:security_access/domain/entities/usuario.dart';
import 'package:security_access/domain/usecases/leer_qr.dart';
import 'package:security_access/domain/usecases/rechazar_acceso.dart';
import 'package:security_access/domain/usecases/registrar_entrada.dart';
import 'package:security_access/domain/usecases/resultado_lectura_qr.dart';
import 'package:security_access/domain/usecases/resultado_rechazar_acceso.dart';
import 'package:security_access/domain/usecases/resultado_registrar_entrada.dart';

class RegistrarEntradaState {
  const RegistrarEntradaState({
    this.lectura,
    this.tipo,
    this.numero = '',
    this.coincide,
    this.guardando = false,
  });

  final ResultadoLecturaQr? lectura;
  final TipoIdentificacion? tipo;
  final String numero;
  final bool? coincide;
  final bool guardando;

  bool get puedeConfirmar =>
      lectura?.esValida == true &&
      tipo != null &&
      numero.trim().isNotEmpty &&
      coincide == true &&
      !guardando;

  RegistrarEntradaState copyWith({
    ResultadoLecturaQr? lectura,
    TipoIdentificacion? tipo,
    String? numero,
    bool? coincide,
    bool? guardando,
    bool limpiarTipo = false,
    bool limpiarCoincidencia = false,
  }) {
    return RegistrarEntradaState(
      lectura: lectura ?? this.lectura,
      tipo: limpiarTipo ? tipo : tipo ?? this.tipo,
      numero: numero ?? this.numero,
      coincide: limpiarCoincidencia ? coincide : coincide ?? this.coincide,
      guardando: guardando ?? this.guardando,
    );
  }
}

class RegistrarEntradaViewModel extends ChangeNotifier {
  RegistrarEntradaViewModel({
    required this._leer,
    required this._registrar,
    required this._rechazar,
    required this._guardia,
  });

  final LeerQr _leer;
  final RegistrarEntrada _registrar;
  final RechazarAcceso _rechazar;
  final Usuario? _guardia;
  RegistrarEntradaState _state = const RegistrarEntradaState();

  RegistrarEntradaState get state => _state;

  Future<void> leer(String codigo) async {
    final lectura = await _leer(codigo);
    _state = RegistrarEntradaState(lectura: lectura);
    notifyListeners();
  }

  Future<void> marcarIlegible() async {
    _state = const RegistrarEntradaState(
      lectura: ResultadoLecturaQr(
        clasificacion: ClasificacionQr.invalida,
        mensaje: LeerQr.mensajeIlegible,
        codigo: '',
      ),
    );
    notifyListeners();
  }

  void seleccionarTipo(TipoIdentificacion? tipo) {
    _state = _state.copyWith(tipo: tipo, limpiarTipo: true);
    notifyListeners();
  }

  void cambiarNumero(String numero) {
    _state = _state.copyWith(numero: numero);
    notifyListeners();
  }

  void indicarCoincidencia(bool coincide) {
    _state = _state.copyWith(coincide: coincide, limpiarCoincidencia: true);
    notifyListeners();
  }

  Future<String?> confirmar() async {
    final guardia = _guardia;
    final lectura = _state.lectura;
    if (guardia == null || lectura == null || !_state.puedeConfirmar) {
      return null;
    }
    _state = _state.copyWith(guardando: true);
    notifyListeners();
    final resultado = await _registrar(
      guardia: guardia,
      codigo: lectura.codigo,
      tipo: _state.tipo,
      numero: _state.numero,
      identidadCoincide: _state.coincide == true,
    );
    _state = _state.copyWith(guardando: false);
    notifyListeners();
    return switch (resultado) {
      EntradaRegistrada() => EntradaRegistrada.mensaje,
      EntradaNoAutorizada(:final mensaje) => mensaje,
    };
  }

  Future<String?> rechazar({
    required MotivoRechazo? motivo,
    required String descripcion,
  }) async {
    final guardia = _guardia;
    final lectura = _state.lectura;
    if (guardia == null || lectura == null) {
      return 'Debe existir un código escaneado';
    }
    final resultado = await _rechazar(
      guardia: guardia,
      lectura: lectura,
      motivo: motivo,
      descripcion: descripcion,
    );
    return switch (resultado) {
      AccesoRechazadoRegistrado() => AccesoRechazadoRegistrado.mensaje,
      RechazoInvalido(:final mensaje) => mensaje,
    };
  }
}
