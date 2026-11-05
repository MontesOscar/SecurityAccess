import 'package:security_access/domain/entities/invitacion.dart';
import 'package:security_access/domain/entities/visita.dart';

abstract class InvitacionRepository {
  Future<List<Invitacion>> listar();

  Future<Invitacion?> buscarPorId(String id);

  Future<Invitacion?> buscarPorCodigo(String codigo);

  Future<String> reservarId();

  Future<String> reservarCodigo();

  Future<void> guardar(Invitacion invitacion);

  Future<List<Visita>> listarVisitas();
}
