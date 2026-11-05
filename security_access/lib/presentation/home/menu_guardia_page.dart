import 'package:flutter/material.dart';
import 'package:security_access/presentation/entrada/registrar_entrada_page.dart';
import 'package:security_access/presentation/home/menu_rol_page.dart';

class MenuGuardiaPage extends StatelessWidget {
  const MenuGuardiaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MenuRolPage(
      key: const Key('menu-guardia'),
      titulo: 'Menú del guardia',
      descripcion: 'Escanea el QR del visitante para registrar su entrada.',
      acciones: [
        MenuAccion(
          key: const Key('abrir-registrar-entrada'),
          etiqueta: 'Registrar entrada',
          icono: Icons.qr_code_scanner,
          alPresionar: (context) {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (context) => const RegistrarEntradaPage(),
              ),
            );
          },
        ),
      ],
    );
  }
}
