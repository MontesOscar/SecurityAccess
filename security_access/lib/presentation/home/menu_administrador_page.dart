import 'package:flutter/material.dart';
import 'package:security_access/presentation/home/menu_rol_page.dart';
import 'package:security_access/presentation/usuarios/usuarios_page.dart';
import 'package:security_access/presentation/viviendas/viviendas_page.dart';

class MenuAdministradorPage extends StatelessWidget {
  const MenuAdministradorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MenuRolPage(
      key: const Key('menu-administrador'),
      titulo: 'Menú del administrador',
      descripcion: 'Registra viviendas y usuarios de la residencial.',
      acciones: [
        MenuAccion(
          key: const Key('abrir-viviendas'),
          etiqueta: 'Viviendas',
          icono: Icons.home_work_outlined,
          alPresionar: (context) {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (context) => const ViviendasPage(),
              ),
            );
          },
        ),
        MenuAccion(
          key: const Key('abrir-usuarios'),
          etiqueta: 'Usuarios',
          icono: Icons.people_outline,
          alPresionar: (context) {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (context) => const UsuariosPage(),
              ),
            );
          },
        ),
      ],
    );
  }
}
