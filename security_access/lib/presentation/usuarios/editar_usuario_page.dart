import 'package:flutter/material.dart';
import 'package:security_access/app/dependencias_app.dart';
import 'package:security_access/domain/entities/rol_usuario.dart';
import 'package:security_access/domain/entities/usuario.dart';
import 'package:security_access/domain/usecases/resultado_editar_usuario.dart';
import 'package:security_access/presentation/usuarios/aviso_usuario.dart';
import 'package:security_access/presentation/usuarios/editar_usuario_view_model.dart';
import 'package:security_access/presentation/usuarios/formulario_usuario.dart';

class EditarUsuarioPage extends StatefulWidget {
  const EditarUsuarioPage({required this.usuario, super.key});

  final Usuario usuario;

  static const mensajeExito = 'Usuario actualizado correctamente';

  @override
  State<EditarUsuarioPage> createState() => _EditarUsuarioPageState();
}

class _EditarUsuarioPageState extends State<EditarUsuarioPage> {
  late final TextEditingController _nombre = TextEditingController(
    text: widget.usuario.nombre,
  );
  late final TextEditingController _correo = TextEditingController(
    text: widget.usuario.correo,
  );
  late final TextEditingController _telefono = TextEditingController(
    text: widget.usuario.telefono,
  );
  EditarUsuarioViewModel? _viewModel;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_viewModel != null) {
      return;
    }
    final dependencias = DependenciasApp.of(context);
    _viewModel = EditarUsuarioViewModel(
      editar: dependencias.editarUsuario,
      listarViviendas: dependencias.listarViviendasDisponibles,
      usuario: widget.usuario,
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
    return Scaffold(
      appBar: AppBar(title: const Text('Editar usuario')),
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
                  correoBloqueado: true,
                  guardando: estado.guardando,
                  textoBoton: 'Guardar cambios',
                  errorNombre: estado.errorNombre,
                  errorTelefono: estado.errorTelefono,
                  errorVivienda: estado.errorVivienda,
                  alCambiarNombre: viewModel.corregirNombre,
                  alCambiarTelefono: viewModel.corregirTelefono,
                  onRol: viewModel.seleccionarRol,
                  onVivienda: viewModel.seleccionarVivienda,
                  onGuardar: _guardar,
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _guardar() async {
    final viewModel = _viewModel!;
    var confirmar = false;
    if (viewModel.cambiaAsignacion) {
      final acepta = await showDialog<bool>(
        context: context,
        builder: (context) {
          final dejaDeSerResidente =
              widget.usuario.esResidente &&
              viewModel.state.rol != RolUsuario.residente;
          return AlertDialog(
            title: const Text('Confirmar cambio'),
            content: Text(
              dejaDeSerResidente
                  ? 'El usuario dejará de ser residente y la vivienda anterior quedará Disponible.'
                  : 'La vivienda anterior quedará Disponible y la nueva quedará Asignada.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                key: const Key('confirmar-cambio-vivienda'),
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Confirmar'),
              ),
            ],
          );
        },
      );
      if (acepta != true || !mounted) {
        return;
      }
      confirmar = true;
    }

    final resultado = await viewModel.guardar(
      nombre: _nombre.text,
      telefono: _telefono.text,
      confirmarCambioVivienda: confirmar,
    );
    if (resultado is! UsuarioActualizado || !mounted) {
      return;
    }
    Navigator.of(context)
        .pop(const AvisoUsuario(EditarUsuarioPage.mensajeExito));
  }
}
