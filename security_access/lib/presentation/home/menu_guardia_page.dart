import 'package:flutter/material.dart';
import 'package:security_access/presentation/home/menu_rol_page.dart';

class MenuGuardiaPage extends StatelessWidget {
  const MenuGuardiaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const MenuRolPage(
      key: Key('menu-guardia'),
      titulo: 'Menú del guardia',
      descripcion: 'El registro de entradas y salidas se habilita en los siguientes sprints.',
    );
  }
}
