import 'package:flutter/material.dart';
import 'package:security_access/app/dependencias_app.dart';
import 'package:security_access/domain/entities/estado_cuenta.dart';
import 'package:security_access/domain/entities/rol_usuario.dart';
import 'package:security_access/domain/entities/usuario.dart';
import 'package:security_access/presentation/comun/mostrar_aviso.dart';
import 'package:security_access/presentation/usuarios/aviso_usuario.dart';
import 'package:security_access/presentation/usuarios/crear_usuario_page.dart';
import 'package:security_access/presentation/usuarios/editar_usuario_page.dart';
import 'package:security_access/presentation/usuarios/usuarios_view_model.dart';

class UsuariosPage extends StatefulWidget {
  const UsuariosPage({super.key});

  @override
  State<UsuariosPage> createState() => _UsuariosPageState();
}

class _UsuariosPageState extends State<UsuariosPage> {
  UsuariosViewModel? _viewModel;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_viewModel != null) {
      return;
    }
    final dependencias = DependenciasApp.of(context);
    _viewModel = UsuariosViewModel(
      consultar: dependencias.consultarUsuarios,
      cambiarEstado: dependencias.cambiarEstadoUsuario,
    );
    _viewModel!.cargar();
  }

  @override
  void dispose() {
    _viewModel?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = _viewModel!;
    return Scaffold(
      key: const Key('pagina-usuarios'),
      appBar: AppBar(title: const Text('Usuarios')),
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('boton-nuevo-usuario'),
        onPressed: () => _abrirFormulario(const CrearUsuarioPage()),
        icon: const Icon(Icons.person_add_alt_outlined),
        label: const Text('Nuevo usuario'),
      ),
      body: ListenableBuilder(
        listenable: viewModel,
        builder: (context, _) {
          final estado = viewModel.state;
          return ListView(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 96),
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  FilterChip(
                    key: const Key('filtro-rol-todos'),
                    label: const Text('Todos los roles'),
                    selected: estado.rol == null,
                    onSelected: (_) => viewModel.cambiarRol(null),
                  ),
                  for (final rol in RolUsuario.values)
                    FilterChip(
                      key: Key('filtro-rol-${rol.name}'),
                      label: Text(rol.etiqueta),
                      selected: estado.rol == rol,
                      onSelected: (_) => viewModel.cambiarRol(rol),
                    ),
                  FilterChip(
                    key: const Key('filtro-estado-todos'),
                    label: const Text('Todos los estados'),
                    selected: estado.estado == null,
                    onSelected: (_) => viewModel.cambiarEstadoFiltro(null),
                  ),
                  FilterChip(
                    key: const Key('filtro-estado-activo'),
                    label: const Text('Activo'),
                    selected: estado.estado == EstadoCuenta.activo,
                    onSelected: (_) =>
                        viewModel.cambiarEstadoFiltro(EstadoCuenta.activo),
                  ),
                  FilterChip(
                    key: const Key('filtro-estado-inactivo'),
                    label: const Text('Inactivo'),
                    selected: estado.estado == EstadoCuenta.inactivo,
                    onSelected: (_) =>
                        viewModel.cambiarEstadoFiltro(EstadoCuenta.inactivo),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (estado.usuarios.isEmpty)
                const Text('No hay usuarios para este filtro.')
              else
                for (final usuario in estado.usuarios)
                  _TarjetaUsuario(
                    usuario: usuario,
                    onEditar: () =>
                        _abrirFormulario(EditarUsuarioPage(usuario: usuario)),
                    onDesactivar: () => _confirmar(usuario, activar: false),
                    onReactivar: () => _confirmar(usuario, activar: true),
                  ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _abrirFormulario(Widget pagina) async {
    final aviso = await Navigator.of(context).push<AvisoUsuario>(
      MaterialPageRoute<AvisoUsuario>(builder: (context) => pagina),
    );
    if (!mounted || aviso == null) {
      return;
    }
    await _viewModel!.cargar();
    if (!mounted) {
      return;
    }
    mostrarAviso(context, aviso.mensaje, detalle: aviso.detalle);
  }

  Future<void> _confirmar(Usuario usuario, {required bool activar}) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(activar ? 'Reactivar usuario' : 'Desactivar usuario'),
          content: Text(
            activar ? 'El usuario podrá iniciar sesión de nuevo.' : 'El usuario no podrá iniciar sesión. Si es residente, su vivienda quedará Disponible.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              key: Key(
                activar
                    ? 'confirmar-reactivar-usuario'
                    : 'confirmar-desactivar-usuario',
              ),
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(activar ? 'Reactivar' : 'Desactivar'),
            ),
          ],
        );
      },
    );
    if (confirmar != true) {
      return;
    }
    final mensaje = activar
        ? await _viewModel!.reactivar(usuario.id)
        : await _viewModel!.desactivar(usuario.id);
    if (!mounted || mensaje == null) {
      return;
    }
    mostrarAviso(context, mensaje);
  }
}

class _TarjetaUsuario extends StatelessWidget {
  const _TarjetaUsuario({
    required this.usuario,
    required this.onEditar,
    required this.onDesactivar,
    required this.onReactivar,
  });

  final Usuario usuario;
  final VoidCallback onEditar;
  final VoidCallback onDesactivar;
  final VoidCallback onReactivar;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final activo = usuario.estaActivo;
    final color = activo ? tema.colorScheme.tertiary : tema.colorScheme.outline;
    final correo = usuario.correo;

    return Card(
      key: Key('usuario-$correo'),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    usuario.nombre,
                    style: tema.textTheme.titleMedium,
                  ),
                ),
                Chip(
                  label: Text(
                    activo ? 'Activo' : 'Inactivo',
                    key: Key('estado-usuario-$correo'),
                  ),
                  backgroundColor: color.withValues(alpha: 0.15),
                  side: BorderSide(color: color),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(correo),
            Text(usuario.rol.etiqueta),
            Text(
              'Vivienda: ${usuario.viviendaNumero ?? 'Sin vivienda'}',
              key: Key('vivienda-usuario-$correo'),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                TextButton(
                  key: Key('boton-editar-usuario-$correo'),
                  onPressed: onEditar,
                  child: const Text('Editar'),
                ),
                if (activo)
                  TextButton(
                    key: Key('boton-desactivar-usuario-$correo'),
                    onPressed: onDesactivar,
                    child: const Text('Desactivar'),
                  )
                else
                  TextButton(
                    key: Key('boton-reactivar-usuario-$correo'),
                    onPressed: onReactivar,
                    child: const Text('Reactivar'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
