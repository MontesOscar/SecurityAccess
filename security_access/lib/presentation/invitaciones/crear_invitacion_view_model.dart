import 'package:flutter/foundation.dart';
import 'package:security_access/domain/entities/usuario.dart';
import 'package:security_access/domain/usecases/crear_invitacion.dart';
import 'package:security_access/domain/usecases/resultado_crear_invitacion.dart';
import 'package:security_access/presentation/comun/fecha_hora.dart';
import 'package:security_access/presentation/comun/validacion_formulario.dart';

class CrearInvitacionState {
  const CrearInvitacionState({
    this.guardando = false,
    this.errorNombre,
    this.errorFechaEntrada,
    this.errorHoraEntrada,
    this.errorFechaSalida,
    this.errorHoraSalida,
    this.errorGeneral,
  });

  final bool guardando;
  final String? errorNombre;
  final String? errorFechaEntrada;
  final String? errorHoraEntrada;
  final String? errorFechaSalida;
  final String? errorHoraSalida;
  final String? errorGeneral;

  CrearInvitacionState copyWith({
    bool? guardando,
    String? errorNombre,
    String? errorFechaEntrada,
    String? errorHoraEntrada,
    String? errorFechaSalida,
    String? errorHoraSalida,
    String? errorGeneral,
    bool limpiarErrores = false,
  }) {
    return CrearInvitacionState(
      guardando: guardando ?? this.guardando,
      errorNombre: limpiarErrores
          ? errorNombre
          : errorNombre ?? this.errorNombre,
      errorFechaEntrada: limpiarErrores
          ? errorFechaEntrada
          : errorFechaEntrada ?? this.errorFechaEntrada,
      errorHoraEntrada: limpiarErrores
          ? errorHoraEntrada
          : errorHoraEntrada ?? this.errorHoraEntrada,
      errorFechaSalida: limpiarErrores
          ? errorFechaSalida
          : errorFechaSalida ?? this.errorFechaSalida,
      errorHoraSalida: limpiarErrores
          ? errorHoraSalida
          : errorHoraSalida ?? this.errorHoraSalida,
      errorGeneral: limpiarErrores
          ? errorGeneral
          : errorGeneral ?? this.errorGeneral,
    );
  }
}

const _sinCambio = Object();

class CrearInvitacionViewModel extends ChangeNotifier {
  CrearInvitacionViewModel({required this._crear, required this._residente});

  final CrearInvitacion _crear;
  final Usuario? _residente;
  CrearInvitacionState _state = const CrearInvitacionState();

  CrearInvitacionState get state => _state;

  void corregirNombre() => _conservar(errorNombre: null);

  void corregirFechaEntrada() => _conservar(errorFechaEntrada: null);

  void corregirHoraEntrada() => _conservar(errorHoraEntrada: null);

  void corregirFechaSalida() => _conservar(errorFechaSalida: null);

  void corregirHoraSalida() => _conservar(errorHoraSalida: null);

  void _conservar({
    Object? errorNombre = _sinCambio,
    Object? errorFechaEntrada = _sinCambio,
    Object? errorHoraEntrada = _sinCambio,
    Object? errorFechaSalida = _sinCambio,
    Object? errorHoraSalida = _sinCambio,
  }) {
    _state = _state.copyWith(
      limpiarErrores: true,
      errorNombre: errorNombre == _sinCambio
          ? _state.errorNombre
          : errorNombre as String?,
      errorFechaEntrada: errorFechaEntrada == _sinCambio
          ? _state.errorFechaEntrada
          : errorFechaEntrada as String?,
      errorHoraEntrada: errorHoraEntrada == _sinCambio
          ? _state.errorHoraEntrada
          : errorHoraEntrada as String?,
      errorFechaSalida: errorFechaSalida == _sinCambio
          ? _state.errorFechaSalida
          : errorFechaSalida as String?,
      errorHoraSalida: errorHoraSalida == _sinCambio
          ? _state.errorHoraSalida
          : errorHoraSalida as String?,
    );
    notifyListeners();
  }

  Future<InvitacionCreada?> guardar({
    required String nombre,
    required String fechaEntrada,
    required String horaEntrada,
    required String fechaSalida,
    required String horaSalida,
  }) async {
    final residente = _residente;
    final errorNombre = ValidacionFormulario.nombre(nombre);
    final entrada = combinarFechaHora(fechaEntrada, horaEntrada);
    final salida = combinarFechaHora(fechaSalida, horaSalida);
    final errorFechaEntrada = fechaEntrada.trim().isEmpty
        ? 'La fecha de entrada es obligatoria'
        : entrada == null
        ? 'Ingresa la fecha como dd/MM/aaaa'
        : null;
    final errorHoraEntrada = horaEntrada.trim().isEmpty
        ? 'La hora de entrada es obligatoria'
        : entrada == null && fechaEntrada.trim().isNotEmpty
        ? 'Ingresa la hora como HH:mm'
        : null;
    final errorFechaSalida = fechaSalida.trim().isEmpty
        ? 'La fecha de salida es obligatoria'
        : salida == null
        ? 'Ingresa la fecha como dd/MM/aaaa'
        : null;
    final errorHoraSalida = horaSalida.trim().isEmpty
        ? 'La hora de salida es obligatoria'
        : salida == null && fechaSalida.trim().isNotEmpty
        ? 'Ingresa la hora como HH:mm'
        : null;

    if (residente == null ||
        errorNombre != null ||
        errorFechaEntrada != null ||
        errorHoraEntrada != null ||
        errorFechaSalida != null ||
        errorHoraSalida != null) {
      _state = _state.copyWith(
        limpiarErrores: true,
        errorNombre: errorNombre,
        errorFechaEntrada: errorFechaEntrada,
        errorHoraEntrada: errorHoraEntrada,
        errorFechaSalida: errorFechaSalida,
        errorHoraSalida: errorHoraSalida,
      );
      notifyListeners();
      return null;
    }

    _state = _state.copyWith(guardando: true, limpiarErrores: true);
    notifyListeners();
    final resultado = await _crear(
      residente: residente,
      nombreVisitante: nombre,
      entrada: entrada!,
      salida: salida!,
    );
    final mensaje = switch (resultado) {
      ViviendaNoActiva() => ViviendaNoActiva.mensaje,
      EntradaAnterior() => EntradaAnterior.mensaje,
      SalidaInvalida() => SalidaInvalida.mensaje,
      VisitanteInvalido() => 'Ingresa un nombre válido',
      InvitacionCreada() => null,
    };
    _state = _state.copyWith(
      guardando: false,
      limpiarErrores: true,
      errorGeneral: mensaje,
      errorFechaEntrada: resultado is EntradaAnterior
          ? EntradaAnterior.mensaje
          : null,
      errorHoraSalida: resultado is SalidaInvalida
          ? SalidaInvalida.mensaje
          : null,
    );
    notifyListeners();
    return resultado is InvitacionCreada ? resultado : null;
  }
}
