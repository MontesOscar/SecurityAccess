import 'package:flutter/material.dart';
import 'package:security_access/app/dependencias_app.dart';
import 'package:security_access/domain/entities/rol_usuario.dart';
import 'package:security_access/presentation/home/menu_administrador_page.dart';
import 'package:security_access/presentation/home/menu_guardia_page.dart';
import 'package:security_access/presentation/home/menu_residente_page.dart';
import 'package:security_access/presentation/login/login_page.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final session = DependenciasApp.of(context).session;
    return ListenableBuilder(
      listenable: session,
      builder: (context, _) {
        final usuario = session.usuario;
        if (usuario == null) {
          return const LoginPage();
        }
        return switch (usuario.rol) {
          RolUsuario.administrador => const MenuAdministradorPage(),
          RolUsuario.residente => const MenuResidentePage(),
          RolUsuario.guardia => const MenuGuardiaPage(),
        };
      },
    );
  }
}
