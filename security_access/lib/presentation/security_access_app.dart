import 'package:flutter/material.dart';
import 'package:security_access/app/dependencias_app.dart';
import 'package:security_access/presentation/auth_gate.dart';

class SecurityAccessApp extends StatelessWidget {
  const SecurityAccessApp({required this.dependencias, super.key});

  final Dependencias dependencias;

  @override
  Widget build(BuildContext context) {
    return DependenciasApp(
      dependencias: dependencias,
      child: MaterialApp(
        navigatorKey: dependencias.navigatorKey,
        title: 'Security Access',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF143D59)),
          useMaterial3: true,
        ),
        home: const AuthGate(),
      ),
    );
  }
}
