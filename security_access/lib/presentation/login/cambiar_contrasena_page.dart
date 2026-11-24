import 'package:flutter/material.dart';
import 'package:security_access/app/dependencias_app.dart';
import 'package:security_access/domain/usecases/cambiar_contrasena.dart';
import 'package:security_access/presentation/comun/mostrar_aviso.dart';

class CambiarContrasenaPage extends StatefulWidget {
  const CambiarContrasenaPage({super.key});

  @override
  State<CambiarContrasenaPage> createState() => _CambiarContrasenaPageState();
}

class _CambiarContrasenaPageState extends State<CambiarContrasenaPage> {
  final _formulario = GlobalKey<FormState>();
  final _actual = TextEditingController();
  final _nueva = TextEditingController();
  final _confirmacion = TextEditingController();
  var _guardando = false;

  @override
  void dispose() {
    _actual.dispose();
    _nueva.dispose();
    _confirmacion.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const Key('pagina-cambiar-contrasena'),
      appBar: AppBar(title: const Text('Cambiar contraseña')),
      body: Form(
        key: _formulario,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            TextFormField(
              key: const Key('campo-contrasena-actual'),
              controller: _actual,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Contraseña actual *',
                border: OutlineInputBorder(),
              ),
              validator: (valor) => (valor == null || valor.isEmpty)
                  ? 'Ingresa la contraseña actual'
                  : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              key: const Key('campo-contrasena-nueva'),
              controller: _nueva,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Nueva contraseña *',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              key: const Key('campo-contrasena-confirmacion'),
              controller: _confirmacion,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Confirmar contraseña *',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              key: const Key('boton-guardar-contrasena'),
              onPressed: _guardando ? null : _guardar,
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _guardar() async {
    if (!_formulario.currentState!.validate()) {
      return;
    }
    final dependencias = DependenciasApp.of(context);
    final usuario = dependencias.session.usuario;
    if (usuario == null) {
      return;
    }
    setState(() => _guardando = true);
    final resultado = await dependencias.cambiarContrasena(
      usuario: usuario,
      actual: _actual.text,
      nueva: _nueva.text,
      confirmacion: _confirmacion.text,
    );
    if (!mounted) {
      return;
    }
    setState(() => _guardando = false);
    if (resultado is ContrasenaActualizada) {
      FocusManager.instance.primaryFocus?.unfocus();
      mostrarAviso(context, ContrasenaActualizada.mensaje);
      Navigator.of(context).pop();
      return;
    }
    if (resultado is CambioRechazado) {
      mostrarAviso(context, resultado.mensaje);
    }
  }
}
