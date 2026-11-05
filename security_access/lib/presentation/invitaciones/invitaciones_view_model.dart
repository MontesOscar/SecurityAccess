import 'package:flutter/foundation.dart';
import 'package:security_access/domain/entities/estado_invitacion.dart';
import 'package:security_access/domain/entities/invitacion.dart';
import 'package:security_access/domain/entities/usuario.dart';
import 'package:security_access/domain/usecases/consultar_invitaciones.dart';
import 'package:security_access/presentation/comun/fecha_hora.dart';

class InvitacionesState {
  const InvitacionesState({
    this.invitaciones = const [],
    this.estado,
    this.errorDesde,
    this.errorHasta,
  });

  final List<Invitacion> invitaciones;
  final EstadoInvitacion? estado;
  final String? errorDesde;
  final String? errorHasta;

  InvitacionesState copyWith({
    List<Invitacion>? invitaciones,
    EstadoInvitacion? estado,
    String? errorDesde,
    String? errorHasta,
    bool limpiarEstado = false,
    bool limpiarErrores = false,
  }) {
    return InvitacionesState(
      invitaciones: invitaciones ?? this.invitaciones,
      estado: limpiarEstado ? estado : estado ?? this.estado,
      errorDesde: limpiarErrores ? errorDesde : errorDesde ?? this.errorDesde,
      errorHasta: limpiarErrores ? errorHasta : errorHasta ?? this.errorHasta,
    );
  }
}

class InvitacionesViewModel extends ChangeNotifier {
  InvitacionesViewModel({required this._consultar, required this._residente});

  final ConsultarInvitaciones _consultar;
  final Usuario? _residente;
  InvitacionesState _state = const InvitacionesState();
  String _desde = '';
  String _hasta = '';

  InvitacionesState get state => _state;

  Future<void> cargar({String? desde, String? hasta}) async {
    _desde = desde ?? _desde;
    _hasta = hasta ?? _hasta;
    final residente = _residente;
    if (residente == null) {
      _state = _state.copyWith(invitaciones: const []);
      notifyListeners();
      return;
    }
    final fechaDesde = _desde.trim().isEmpty ? null : leerFecha(_desde);
    final fechaHasta = _hasta.trim().isEmpty ? null : leerFecha(_hasta);
    final errorDesde = _desde.trim().isNotEmpty && fechaDesde == null
        ? 'Ingresa la fecha como dd/MM/aaaa'
        : null;
    final errorHasta = _hasta.trim().isNotEmpty && fechaHasta == null
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
    final invitaciones = await _consultar(
      residente: residente,
      estado: _state.estado,
      desde: fechaDesde,
      hasta: fechaHasta,
    );
    _state = _state.copyWith(invitaciones: invitaciones, limpiarErrores: true);
    notifyListeners();
  }

  Future<void> cambiarEstado(EstadoInvitacion? estado) async {
    _state = _state.copyWith(estado: estado, limpiarEstado: true);
    notifyListeners();
    await cargar();
  }
}
