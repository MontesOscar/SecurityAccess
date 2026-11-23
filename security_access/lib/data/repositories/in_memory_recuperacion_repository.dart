import 'package:security_access/domain/entities/codigo_recuperacion.dart';
import 'package:security_access/domain/repositories/recuperacion_repository.dart';

class InMemoryRecuperacionRepository implements RecuperacionRepository {
  final Map<String, CodigoRecuperacion> _codigos = {};

  @override
  Future<void> guardar(CodigoRecuperacion codigo) async {
    _codigos[codigo.correo] = codigo;
  }

  @override
  Future<CodigoRecuperacion?> buscarPorCorreo(String correo) async {
    return _codigos[correo];
  }

  @override
  Future<void> eliminar(String correo) async {
    _codigos.remove(correo);
  }
}
