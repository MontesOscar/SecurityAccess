import 'package:security_access/domain/entities/usuario.dart';

sealed class ResultadoEditarUsuario {
  const ResultadoEditarUsuario();
}

class UsuarioActualizado extends ResultadoEditarUsuario {
  const UsuarioActualizado(this.usuario);

  final Usuario usuario;
}

class EdicionUsuarioRequiereConfirmacion extends ResultadoEditarUsuario {
  const EdicionUsuarioRequiereConfirmacion();
}

class DatosEdicionUsuarioInvalidos extends ResultadoEditarUsuario {
  const DatosEdicionUsuarioInvalidos();
}

class ViviendaEdicionObligatoria extends ResultadoEditarUsuario {
  const ViviendaEdicionObligatoria();
}

class ViviendaEdicionNoDisponible extends ResultadoEditarUsuario {
  const ViviendaEdicionNoDisponible();
}

class UsuarioEdicionNoEncontrado extends ResultadoEditarUsuario {
  const UsuarioEdicionNoEncontrado();
}
