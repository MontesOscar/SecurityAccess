import 'package:flutter/material.dart';
import 'package:security_access/app/dependencias_app.dart';

class MenuAccion {
  const MenuAccion({
    required this.etiqueta,
    required this.icono,
    required this.alPresionar,
    this.key,
  });

  final String etiqueta;
  final IconData icono;
  final void Function(BuildContext context) alPresionar;
  final Key? key;
}

class MenuRolPage extends StatelessWidget {
  const MenuRolPage({
    required this.titulo,
    required this.descripcion,
    this.acciones = const [],
    super.key,
  });

  final String titulo;
  final String descripcion;
  final List<MenuAccion> acciones;

  @override
  Widget build(BuildContext context) {
    final dependencias = DependenciasApp.of(context);
    final usuario = dependencias.session.usuario;
    final tema = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(titulo),
        actions: [
          PopupMenuButton<String>(
            key: const Key('menu-usuario'),
            tooltip: 'Menú de usuario',
            icon: const Icon(Icons.account_circle_outlined),
            onSelected: (opcion) {
              if (opcion == 'cerrar') {
                _cerrarSesion(dependencias);
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem<String>(
                value: 'cerrar',
                child: Text('Cerrar sesión'),
              ),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            usuario == null ? 'Bienvenido' : 'Bienvenido, ${usuario.nombre}',
            key: const Key('mensaje-bienvenida'),
            style: tema.textTheme.headlineSmall,
          ),
          if (usuario != null) ...[
            const SizedBox(height: 8),
            Text(usuario.correo, style: tema.textTheme.bodyMedium),
            const SizedBox(height: 4),
            Text(usuario.rol.etiqueta, style: tema.textTheme.labelLarge),
          ],
          const SizedBox(height: 24),
          Text(descripcion, style: tema.textTheme.bodyLarge),
          if (acciones.isNotEmpty) const SizedBox(height: 24),
          for (final accion in acciones) ...[
            FilledButton.icon(
              key: accion.key,
              onPressed: () => accion.alPresionar(context),
              icon: Icon(accion.icono),
              label: Text(accion.etiqueta),
            ),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }

  Future<void> _cerrarSesion(Dependencias dependencias) async {
    dependencias.navigatorKey.currentState?.popUntil((route) => route.isFirst);
    await dependencias.session.cerrar(dependencias.cerrarSesion);
  }
}
