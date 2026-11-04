import 'package:security_access/domain/repositories/auth_repository.dart';

class CerrarSesion {
  const CerrarSesion(this._repositorio);

  final AuthRepository _repositorio;

  Future<void> call() => _repositorio.cerrarSesion();
}
