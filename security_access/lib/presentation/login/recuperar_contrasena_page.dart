import 'package:flutter/material.dart';

class RecuperarContrasenaPage extends StatelessWidget {
  const RecuperarContrasenaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const Key('pagina-recuperar-contrasena'),
      appBar: AppBar(title: const Text('Recuperar contraseña')),
    );
  }
}
