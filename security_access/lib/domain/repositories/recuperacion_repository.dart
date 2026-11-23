import 'package:security_access/domain/entities/codigo_recuperacion.dart';

abstract class RecuperacionRepository {
  Future<void> guardar(CodigoRecuperacion codigo);

  Future<CodigoRecuperacion?> buscarPorCorreo(String correo);

  Future<void> eliminar(String correo);
}
