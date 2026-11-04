import 'package:flutter/material.dart';
import 'package:security_access/app/dependencias_app.dart';
import 'package:security_access/presentation/login/login_view_model.dart';
import 'package:security_access/presentation/login/recuperar_contrasena_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _correo = TextEditingController();
  final _contrasena = TextEditingController();
  LoginViewModel? _viewModel;
  var _ocultarContrasena = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _viewModel ??= LoginViewModel(
      iniciarSesion: DependenciasApp.of(context).iniciarSesion,
      alIngresar: DependenciasApp.of(context).session.iniciar,
    );
  }

  @override
  void dispose() {
    _correo.dispose();
    _contrasena.dispose();
    _viewModel?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = _viewModel!;
    final cuentasDemo = DependenciasApp.of(context).cuentasDemo;
    final tema = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: ListenableBuilder(
                listenable: viewModel,
                builder: (context, _) {
                  final estado = viewModel.state;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Icon(
                        Icons.shield_outlined,
                        size: 56,
                        color: tema.colorScheme.primary,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Security Access',
                        textAlign: TextAlign.center,
                        style: tema.textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Control de accesos de la residencial',
                        textAlign: TextAlign.center,
                        style: tema.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 28),
                      TextField(
                        key: const Key('campo-correo'),
                        controller: _correo,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.email],
                        decoration: InputDecoration(
                          labelText: 'Correo electrónico *',
                          errorText: estado.errorCorreo,
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        key: const Key('campo-contrasena'),
                        controller: _contrasena,
                        obscureText: _ocultarContrasena,
                        textInputAction: TextInputAction.done,
                        autofillHints: const [AutofillHints.password],
                        onSubmitted: (_) => _enviar(),
                        decoration: InputDecoration(
                          labelText: 'Contraseña *',
                          errorText: estado.errorContrasena,
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            tooltip: _ocultarContrasena
                                ? 'Mostrar contraseña'
                                : 'Ocultar contraseña',
                            onPressed: () {
                              setState(() {
                                _ocultarContrasena = !_ocultarContrasena;
                              });
                            },
                            icon: Icon(
                              _ocultarContrasena
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                          ),
                        ),
                      ),
                      if (estado.mensaje != null) ...[
                        const SizedBox(height: 16),
                        Text(
                          estado.mensaje!,
                          key: const Key('mensaje-acceso'),
                          style: tema.textTheme.bodyMedium?.copyWith(
                            color: tema.colorScheme.error,
                          ),
                        ),
                      ],
                      const SizedBox(height: 20),
                      FilledButton(
                        key: const Key('boton-iniciar-sesion'),
                        onPressed: estado.cargando ? null : _enviar,
                        child: estado.cargando
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Iniciar sesión'),
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.center,
                        child: TextButton(
                          key: const Key('enlace-recuperar-contrasena'),
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (context) =>
                                    const RecuperarContrasenaPage(),
                              ),
                            );
                          },
                          child: const Text('Recuperar contraseña'),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Cuentas de demostración',
                        style: tema.textTheme.titleSmall,
                      ),
                      const SizedBox(height: 8),
                      for (final cuenta in cuentasDemo)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Text(
                            '${cuenta.nombre} · ${cuenta.detalle}\n'
                            '${cuenta.correo} · ${cuenta.contrasena}',
                            style: tema.textTheme.bodySmall,
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _enviar() {
    _viewModel?.enviar(correo: _correo.text, contrasena: _contrasena.text);
  }
}
