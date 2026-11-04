import 'package:flutter/material.dart';
import 'package:security_access/domain/entities/vivienda.dart';

class HistorialViviendaPage extends StatelessWidget {
  const HistorialViviendaPage({required this.vivienda, super.key});

  final Vivienda vivienda;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const Key('pagina-historial-vivienda'),
      appBar: AppBar(title: Text('Historial ${vivienda.numero}')),
      body: const Center(child: Text('Aún no hay visitas registradas.')),
    );
  }
}
