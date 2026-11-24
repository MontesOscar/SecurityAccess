import 'package:flutter/material.dart';
import 'package:security_access/app/dependencias_app.dart';
import 'package:security_access/domain/usecases/recuperar_contrasena.dart';
import 'package:security_access/presentation/comun/mostrar_aviso.dart';

class RecuperarContrasenaPage extends StatefulWidget {
  const RecuperarContrasenaPage({super.key});

  @override
  State<RecuperarContrasenaPage> createState() =>
      _RecuperarContrasenaPageState();
}

class _RecuperarContrasenaPageState extends State<RecuperarContrasenaPage> {
  final _correo = TextEditingController();
  final _codigo = TextEditingController();
  final _nueva = TextEditingController();
  final _confirmacion = TextEditingController();
  var _instruccionesEnviadas = false;
  var _guardando = false;

  @override
  void dispose() {
    _correo.dispose();
    _codigo.dispose();
    _nueva.dispose();
    _confirmacion.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const Key('pagina-recuperar-contrasena'),
      appBar: AppBar(title: const Text('Recuperar contraseña')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          TextField(
            key: const Key('campo-correo-recuperacion'),
            controller: _correo,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Correo',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton(
            key: const Key('boton-solicitar-recuperacion'),
            onPressed: _guardando ? null : _solicitar,
            child: const Text('Enviar instrucciones'),
          ),
          if (_instruccionesEnviadas) ...[
            const SizedBox(height: 24),
            const Text(SolicitudRecuperacionEmitida.mensaje),
            const SizedBox(height: 8),
            const Text(
              'Revisa tu correo e ingresa el código. Es válido durante 15 minutos.',
            ),
            const SizedBox(height: 12),
            TextField(
              key: const Key('campo-codigo-recuperacion'),
              controller: _codigo,
              decoration: const InputDecoration(
                labelText: 'Código',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              key: const Key('campo-contrasena-nueva'),
              controller: _nueva,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Nueva contraseña',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              key: const Key('campo-contrasena-confirmacion'),
              controller: _confirmacion,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Confirmar contraseña',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            FilledButton(
              key: const Key('boton-restablecer-contrasena'),
              onPressed: _guardando ? null : _restablecer,
              child: const Text('Restablecer contraseña'),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _solicitar() async {
    setState(() => _guardando = true);
    final resultado = await DependenciasApp.of(context).recuperarContrasena
        .solicitar(_correo.text);
    if (!mounted) {
      return;
    }
    setState(() {
      _guardando = false;
      _instruccionesEnviadas = resultado is SolicitudRecuperacionEmitida;
    });
  }

  Future<void> _restablecer() async {
    setState(() => _guardando = true);
    final resultado = await DependenciasApp.of(context).recuperarContrasena
        .restablecer(
          codigo: _codigo.text,
          nueva: _nueva.text,
          confirmacion: _confirmacion.text,
        );
    if (!mounted) {
      return;
    }
    setState(() => _guardando = false);
    if (resultado is ContrasenaRestablecida) {
      FocusManager.instance.primaryFocus?.unfocus();
      mostrarAviso(context, ContrasenaRestablecida.mensaje);
      Navigator.of(context).pop();
      return;
    }
    if (resultado is RestablecimientoRechazado) {
      mostrarAviso(context, resultado.mensaje);
    }
  }
}
