import 'package:security_access/domain/entities/acceso_rechazado.dart';
import 'package:security_access/domain/entities/invitacion.dart';
import 'package:security_access/domain/entities/visita.dart';
import 'package:security_access/domain/repositories/invitacion_repository.dart';

class InMemoryInvitacionRepository implements InvitacionRepository {
  InMemoryInvitacionRepository({
    List<Invitacion> invitaciones = const [],
    List<Visita> visitas = const [],
  }) : _invitaciones = List<Invitacion>.of(invitaciones),
       _visitas = List<Visita>.of(visitas);

  final List<Invitacion> _invitaciones;
  final List<Visita> _visitas;
  final List<AccesoRechazado> _rechazos = [];
  var _secuencia = 0;
  var _secuenciaVisitas = 0;
  var _secuenciaRechazos = 0;

  @override
  Future<List<Invitacion>> listar() async {
    return List<Invitacion>.of(_invitaciones);
  }

  @override
  Future<Invitacion?> buscarPorId(String id) async {
    for (final invitacion in _invitaciones) {
      if (invitacion.id == id) {
        return invitacion;
      }
    }
    return null;
  }

  @override
  Future<Invitacion?> buscarPorCodigo(String codigo) async {
    for (final invitacion in _invitaciones) {
      if (invitacion.codigoQr == codigo) {
        return invitacion;
      }
    }
    return null;
  }

  @override
  Future<String> reservarId() async {
    _secuencia += 1;
    return 'inv-$_secuencia';
  }

  @override
  Future<String> reservarCodigo() async {
    return 'SA-${_secuencia.toString().padLeft(6, '0')}';
  }

  @override
  Future<void> guardar(Invitacion invitacion) async {
    final indice = _invitaciones.indexWhere(
      (actual) => actual.id == invitacion.id,
    );
    if (indice >= 0) {
      _invitaciones[indice] = invitacion;
      return;
    }
    final repetido = await buscarPorCodigo(invitacion.codigoQr);
    if (repetido != null) {
      throw StateError('El código QR ya existe.');
    }
    _invitaciones.add(invitacion);
  }

  @override
  Future<List<Visita>> listarVisitas() async {
    return List<Visita>.of(_visitas);
  }

  @override
  Future<void> guardarVisita(Visita visita) async {
    final indice = _visitas.indexWhere((actual) => actual.id == visita.id);
    if (indice >= 0) {
      _visitas[indice] = visita;
      return;
    }
    _visitas.add(visita);
  }

  @override
  Future<String> reservarIdVisita() async {
    _secuenciaVisitas += 1;
    return 'vis-$_secuenciaVisitas';
  }

  @override
  Future<List<AccesoRechazado>> listarRechazos() async {
    return List<AccesoRechazado>.of(_rechazos);
  }

  @override
  Future<void> guardarRechazo(AccesoRechazado rechazo) async {
    _rechazos.add(rechazo);
  }

  @override
  Future<String> reservarIdRechazo() async {
    _secuenciaRechazos += 1;
    return 'rec-$_secuenciaRechazos';
  }
}
