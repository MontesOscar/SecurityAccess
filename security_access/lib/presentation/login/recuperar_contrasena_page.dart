import 'package:flutter/material.dart';
import 'package:security_access/app/dependencias_app.dart';
import 'package:security_access/domain/usecases/reglas_contrasena.dart';
import 'package:security_access/domain/usecases/resultado_recuperar_contrasena.dart';
import 'package:security_access/domain/usecases/solicitar_recuperacion.dart';
import 'package:security_access/presentation/comun/mostrar_aviso.dart';
import 'package:security_access/presentation/login/recuperar_contrasena_view_model.dart';

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
  RecuperarContrasenaViewModel? _viewModel;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_viewModel != null) {
      return;
    }
    final dependencias = DependenciasApp.of(context);
    _viewModel = RecuperarContrasenaViewModel(
      solicitar: dependencias.solicitarRecuperacion,
      validar: dependencias.validarCodigoRecuperacion,
      restablecer: dependencias.restablecerContrasena,
    );
  }

  @override
  void dispose() {
    _correo.dispose();
    _codigo.dispose();
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
      key: const Key('pagina-recuperar-contrasena'),
      appBar: AppBar(title: const Text('Recuperar contraseña')),
      body: ListenableBuilder(
        listenable: viewModel,
        builder: (context, _) {
          final error = viewModel.error;
          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              ...switch (viewModel.paso) {
                PasoRecuperacion.correo => _pasoCorreo(viewModel),
                PasoRecuperacion.codigo => _pasoCodigo(viewModel, tema),
                PasoRecuperacion.nuevaContrasena => _pasoNueva(viewModel),
              },
              if (error != null) ...[
                const SizedBox(height: 12),
                Text(
                  error,
                  key: const Key('error-recuperacion'),
                  style: TextStyle(color: tema.colorScheme.error),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  List<Widget> _pasoCorreo(RecuperarContrasenaViewModel viewModel) {
    return [
      const Text(
        'Escribe el correo con el que te registraste. '
        'Te enviaremos un código para crear una nueva contraseña.',
      ),
      const SizedBox(height: 16),
      TextField(
        key: const Key('campo-correo-recuperacion'),
        controller: _correo,
        keyboardType: TextInputType.emailAddress,
        decoration: const InputDecoration(
          labelText: 'Correo electrónico *',
          border: OutlineInputBorder(),
        ),
      ),
      const SizedBox(height: 16),
      FilledButton(
        key: const Key('boton-enviar-instrucciones'),
        onPressed: viewModel.ocupado
            ? null
            : () => viewModel.enviar(_correo.text),
        child: const Text('Enviar instrucciones'),
      ),
    ];
  }

  List<Widget> _pasoCodigo(
    RecuperarContrasenaViewModel viewModel,
    ThemeData tema,
  ) {
    return [
      Text(
        SolicitudRecuperacion.mensaje,
        key: const Key('mensaje-envio-recuperacion'),
        style: tema.textTheme.titleMedium,
      ),
      const SizedBox(height: 16),
      Card(
        key: const Key('codigo-demostracion'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Modo demostración', style: tema.textTheme.titleSmall),
              const SizedBox(height: 4),
              const Text(
                'Esta versión no envía correos. Este es el código que '
                'llegaría al correo, si está registrado:',
              ),
              const SizedBox(height: 8),
              SelectableText(
                viewModel.codigoDemostracion ?? '',
                key: const Key('valor-codigo-demostracion'),
                style: tema.textTheme.headlineSmall,
              ),
              const SizedBox(height: 4),
              Text(
                'Vence en ${SolicitarRecuperacion.vigencia.inMinutes} minutos.',
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 16),
      TextField(
        key: const Key('campo-codigo-recuperacion'),
        controller: _codigo,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          labelText: 'Código recibido *',
          border: OutlineInputBorder(),
        ),
      ),
      const SizedBox(height: 16),
      FilledButton(
        key: const Key('boton-validar-codigo'),
        onPressed: viewModel.ocupado
            ? null
            : () => viewModel.validarCodigo(_codigo.text),
        child: const Text('Continuar'),
      ),
    ];
  }

  List<Widget> _pasoNueva(RecuperarContrasenaViewModel viewModel) {
    return [
      TextField(
        key: const Key('campo-nueva-recuperacion'),
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
        key: const Key('campo-confirmar-recuperacion'),
        controller: _confirmacion,
        obscureText: true,
        decoration: const InputDecoration(
          labelText: 'Confirmar nueva contraseña *',
          border: OutlineInputBorder(),
        ),
      ),
      const SizedBox(height: 16),
      FilledButton(
        key: const Key('boton-restablecer-contrasena'),
        onPressed: viewModel.ocupado ? null : () => _restablecer(viewModel),
        child: const Text('Guardar nueva contraseña'),
      ),
      const SizedBox(height: 8),
      const Text(ReglasContrasena.mensajeRequisitos),
    ];
  }

  Future<void> _restablecer(RecuperarContrasenaViewModel viewModel) async {
    final mensaje = await viewModel.restablecer(
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
