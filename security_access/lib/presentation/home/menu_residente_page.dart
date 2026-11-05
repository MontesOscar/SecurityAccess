import 'package:flutter/material.dart';
import 'package:security_access/presentation/home/menu_rol_page.dart';
import 'package:security_access/presentation/invitaciones/historial_visitas_page.dart';
import 'package:security_access/presentation/invitaciones/invitaciones_page.dart';

class MenuResidentePage extends StatelessWidget {
  const MenuResidentePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MenuRolPage(
      key: const Key('menu-residente'),
      titulo: 'Menú del residente',
      descripcion: 'Crea invitaciones con código QR y consulta las visitas de tu vivienda.',
      acciones: [
        MenuAccion(
          key: const Key('abrir-invitaciones'),
          etiqueta: 'Invitaciones',
          icono: Icons.qr_code_2_outlined,
          alPresionar: (context) {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (context) => const InvitacionesPage(),
              ),
            );
          },
        ),
        MenuAccion(
          key: const Key('abrir-historial'),
          etiqueta: 'Historial de visitas',
          icono: Icons.history,
          alPresionar: (context) {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (context) => const HistorialVisitasPage(),
              ),
            );
          },
        ),
      ],
    );
  }
}
