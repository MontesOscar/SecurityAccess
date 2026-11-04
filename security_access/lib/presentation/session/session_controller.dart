import 'package:flutter/foundation.dart';
import 'package:security_access/domain/entities/usuario.dart';
import 'package:security_access/domain/usecases/cerrar_sesion.dart';

class SessionController extends ChangeNotifier {
  Usuario? _usuario;

  Usuario? get usuario => _usuario;

  void iniciar(Usuario usuario) {
    _usuario = usuario;
    notifyListeners();
  }

  Future<void> cerrar(CerrarSesion cerrarSesion) async {
    await cerrarSesion();
    _usuario = null;
    notifyListeners();
  }
}
