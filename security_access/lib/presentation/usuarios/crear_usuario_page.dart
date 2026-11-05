import 'package:flutter/material.dart';
import 'package:security_access/app/dependencias_app.dart';
import 'package:security_access/domain/usecases/crear_usuario.dart';
import 'package:security_access/presentation/usuarios/aviso_usuario.dart';
import 'package:security_access/presentation/usuarios/crear_usuario_view_model.dart';
import 'package:security_access/presentation/usuarios/formulario_usuario.dart';

class CrearUsuarioPage extends StatefulWidget {
  const CrearUsuarioPage({super.key});

  static const mensajeExito = 'Usuario registrado correctamente';

  @override
  State<CrearUsuarioPage> createState() => _CrearUsuarioPageState();
}

class _CrearUsuarioPageState extends State<CrearUsuarioPage> {
  final _nombre = TextEditingController();
  final _correo = TextEditingController();
  final _telefono = TextEditingController();
  CrearUsuarioViewModel? _viewModel;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_viewModel != null) {
      return;
    }
    final dependencias = DependenciasApp.of(context);
    _viewModel = CrearUsuarioViewModel(
      crear: dependencias.crearUsuario,
      listarViviendas: dependencias.listarViviendasDisponibles,
    );
    _viewModel!.cargar();
  }

  @override
  void dispose() {
    _nombre.dispose();
    _correo.dispose();
    _telefono.dispose();
    _viewModel?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = _viewModel!;
    final tema = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Nuevo usuario')),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: viewModel,
          builder: (context, _) {
            final estado = viewModel.state;
            return ListView(
              padding: const EdgeInsets.all(24),
              children: [
                FormularioUsuario(
                  nombre: _nombre,
                  correo: _correo,
                  telefono: _telefono,
                  rol: estado.rol,
                  viviendaId: estado.viviendaId,
                  viviendas: estado.viviendas,
                  correoBloqueado: false,
                  guardando: estado.guardando,
                  textoBoton: 'Guardar',
                  errorNombre: estado.errorNombre,
                  errorCorreo: estado.errorCorreo,
                  errorTelefono: estado.errorTelefono,
                  errorRol: estado.errorRol,
                  errorVivienda: estado.errorVivienda,
                  alCambiarNombre: viewModel.corregirNombre,
                  alCambiarCorreo: viewModel.corregirCorreo,
                  alCambiarTelefono: viewModel.corregirTelefono,
                  onRol: viewModel.seleccionarRol,
                  onVivienda: viewModel.seleccionarVivienda,
                  onGuardar: _guardar,
                ),
                const SizedBox(height: 16),
                Text(
                  'La contraseña inicial será ${CrearUsuario.contrasenaInicial}.',
                  style: tema.textTheme.bodySmall,
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _guardar() async {
    final creado = await _viewModel!.guardar(
      nombre: _nombre.text,
      correo: _correo.text,
      telefono: _telefono.text,
    );
    if (creado == null || !mounted) {
      return;
    }
    Navigator.of(context).pop(
      AvisoUsuario(
        CrearUsuarioPage.mensajeExito,
        detalle: 'Contraseña inicial: ${creado.contrasenaInicial}',
      ),
    );
  }
}
