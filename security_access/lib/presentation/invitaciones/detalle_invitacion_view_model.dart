import 'package:flutter/foundation.dart';
import 'package:security_access/domain/entities/invitacion.dart';
import 'package:security_access/domain/entities/usuario.dart';
import 'package:security_access/domain/usecases/buscar_invitacion.dart';
import 'package:security_access/domain/usecases/cancelar_invitacion.dart';
import 'package:security_access/domain/usecases/resultado_cancelar_invitacion.dart';

class DetalleInvitacionState {
  const DetalleInvitacionState({this.invitacion, this.cargando = true});

  final Invitacion? invitacion;
  final bool cargando;

  DetalleInvitacionState copyWith({Invitacion? invitacion, bool? cargando}) {
    return DetalleInvitacionState(
      invitacion: invitacion ?? this.invitacion,
      cargando: cargando ?? this.cargando,
    );
  }
}

class DetalleInvitacionViewModel extends ChangeNotifier {
  DetalleInvitacionViewModel({
    required this._buscar,
    required this._cancelar,
    required this._residente,
    required this.invitacionId,
  });

  final BuscarInvitacion _buscar;
  final CancelarInvitacion _cancelar;
  final Usuario? _residente;
  final String invitacionId;
  DetalleInvitacionState _state = const DetalleInvitacionState();

  DetalleInvitacionState get state => _state;

  Future<void> cargar() async {
    final residente = _residente;
    final encontrada = residente == null
        ? null
        : await _buscar(residente: residente, invitacionId: invitacionId);
    _state = DetalleInvitacionState(invitacion: encontrada, cargando: false);
    notifyListeners();
  }

  Future<String?> cancelar() async {
    final residente = _residente;
    if (residente == null) {
      return InvitacionNoCancelable.mensaje;
    }
    final resultado = await _cancelar(
      residente: residente,
      invitacionId: invitacionId,
    );
    if (resultado is InvitacionCancelada) {
      _state = DetalleInvitacionState(
        invitacion: resultado.invitacion,
        cargando: false,
      );
      notifyListeners();
      return InvitacionCancelada.mensaje;
    }
    return InvitacionNoCancelable.mensaje;
  }
}
