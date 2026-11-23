import 'package:flutter/material.dart';
import 'package:security_access/app/dependencias_app.dart';
import 'package:security_access/domain/usecases/reglas_contrasena.dart';
import 'package:security_access/presentation/comun/mostrar_aviso.dart';
import 'package:security_access/presentation/cuenta/cambiar_contrasena_view_model.dart';

class CambiarContrasenaPage extends StatefulWidget {
  const CambiarContrasenaPage({super.key});

  @override
  State<CambiarContrasenaPage> createState() => _CambiarContrasenaPageState();
}

class _CambiarContrasenaPageState extends State<CambiarContrasenaPage> {
  final _actual = TextEditingController();
  final _nueva = TextEditingController();
  final _confirmacion = TextEditingController();
  CambiarContrasenaViewModel? _viewModel;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_viewModel != null) {
      return;
    }
    final dependencias = DependenciasApp.of(context);
    _viewModel = CambiarContrasenaViewModel(
      cambiar: dependencias.cambiarContrasena,
      usuario: dependencias.session.usuario,
    );
  }

  @override
  void dispose() {
    _actual.dispose();
    _nueva.dispose();
    _confirmacion.dispose();
    _viewModel?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = _viewModel!;
    final tema = Theme.of(context);
    return Scaffold(
      key: const Key('pagina-cambiar-contrasena'),
      appBar: AppBar(title: const Text('Cambiar contraseña')),
      body: ListenableBuilder(
        listenable: viewModel,
        builder: (context, _) {
          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              TextField(
                key: const Key('campo-contrasena-actual'),
                controller: _actual,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Contraseña actual *',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                key: const Key('campo-contrasena-nueva'),
                controller: _nueva,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Nueva contraseña *',
                  helperText: 'Mínimo 8 caracteres, una mayúscula y un número',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                key: const Key('campo-contrasena-confirmacion'),
                controller: _confirmacion,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Confirmar nueva contraseña *',
                  border: OutlineInputBorder(),
                ),
              ),
              if (viewModel.error != null) ...[
                const SizedBox(height: 12),
                Text(
                  viewModel.error!,
                  key: const Key('error-cambiar-contrasena'),
                  style: TextStyle(color: tema.colorScheme.error),
                ),
              ],
              const SizedBox(height: 16),
              FilledButton(
                key: const Key('boton-guardar-contrasena'),
                onPressed: viewModel.guardando ? null : () => _guardar(),
                child: const Text('Guardar'),
              ),
              const SizedBox(height: 8),
              Text(
                ReglasContrasena.mensajeRequisitos,
                style: tema.textTheme.bodySmall,
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _guardar() async {
    final mensaje = await _viewModel!.guardar(
      actual: _actual.text,
      nueva: _nueva.text,
      confirmacion: _confirmacion.text,
    );
    if (!mounted || mensaje == null) {
      return;
    }
    mostrarAviso(context, mensaje);
    Navigator.of(context).pop();
  }
}
