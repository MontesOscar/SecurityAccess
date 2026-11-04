import 'package:flutter/material.dart';
import 'package:security_access/presentation/home/menu_rol_page.dart';

class MenuResidentePage extends StatelessWidget {
  const MenuResidentePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const MenuRolPage(
      key: Key('menu-residente'),
      titulo: 'Menú del residente',
      descripcion: 'Invitaciones e historial de visitas se habilitan en los siguientes sprints.',
    );
  }
}
