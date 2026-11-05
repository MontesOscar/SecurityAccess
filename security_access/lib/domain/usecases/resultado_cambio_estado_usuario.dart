import 'package:security_access/domain/entities/usuario.dart';

sealed class ResultadoCambioEstadoUsuario {
  const ResultadoCambioEstadoUsuario();
}

class EstadoUsuarioActualizado extends ResultadoCambioEstadoUsuario {
  const EstadoUsuarioActualizado(this.usuario);

  final Usuario usuario;
}

class UsuarioEstadoNoEncontrado extends ResultadoCambioEstadoUsuario {
  const UsuarioEstadoNoEncontrado();
}
