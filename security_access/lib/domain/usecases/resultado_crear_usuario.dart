import 'package:security_access/domain/entities/usuario.dart';

sealed class ResultadoCrearUsuario {
  const ResultadoCrearUsuario();
}

class UsuarioCreado extends ResultadoCrearUsuario {
  const UsuarioCreado(this.usuario, {required this.contrasenaInicial});

  final Usuario usuario;
  final String contrasenaInicial;
}

class CorreoYaRegistrado extends ResultadoCrearUsuario {
  const CorreoYaRegistrado();
}

class DatosUsuarioInvalidos extends ResultadoCrearUsuario {
  const DatosUsuarioInvalidos();
}

class ViviendaObligatoria extends ResultadoCrearUsuario {
  const ViviendaObligatoria();
}

class ViviendaNoDisponible extends ResultadoCrearUsuario {
  const ViviendaNoDisponible();
}
