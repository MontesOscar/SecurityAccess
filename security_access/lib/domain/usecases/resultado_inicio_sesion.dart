import 'package:security_access/domain/entities/usuario.dart';

sealed class ResultadoInicioSesion {
  const ResultadoInicioSesion();
}

class InicioSesionExitoso extends ResultadoInicioSesion {
  const InicioSesionExitoso(this.usuario);

  final Usuario usuario;
}

class InicioSesionCredencialesInvalidas extends ResultadoInicioSesion {
  const InicioSesionCredencialesInvalidas();
}

class InicioSesionCuentaInactiva extends ResultadoInicioSesion {
  const InicioSesionCuentaInactiva();
}
