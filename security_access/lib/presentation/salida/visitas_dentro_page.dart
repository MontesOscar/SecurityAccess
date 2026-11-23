import 'package:flutter/material.dart';
import 'package:security_access/app/dependencias_app.dart';
import 'package:security_access/domain/entities/visita.dart';
import 'package:security_access/presentation/comun/fecha_hora.dart';
import 'package:security_access/presentation/salida/visitas_dentro_view_model.dart';

class VisitasDentroPage extends StatefulWidget {
  const VisitasDentroPage({super.key});

  @override
  State<VisitasDentroPage> createState() => _VisitasDentroPageState();
}

class _VisitasDentroPageState extends State<VisitasDentroPage> {
  VisitasDentroViewModel? _viewModel;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_viewModel != null) {
      return;
    }
    final dependencias = DependenciasApp.of(context);
    _viewModel = VisitasDentroViewModel(
      consultar: dependencias.consultarVisitasDentro,
      guardia: dependencias.session.usuario,
    )..cargar();
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
      key: const Key('pagina-visitas-dentro'),
      appBar: AppBar(title: const Text('Visitas dentro')),
      body: ListenableBuilder(
        listenable: viewModel,
        builder: (context, _) {
          if (viewModel.cargando) {
            return const Center(child: CircularProgressIndicator());
          }
          return RefreshIndicator(
            onRefresh: viewModel.cargar,
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                DropdownButtonFormField<String?>(
                  key: const Key('filtro-vivienda-dentro'),
                  initialValue: viewModel.viviendaId,
                  decoration: const InputDecoration(
                    labelText: 'Vivienda',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem<String?>(child: Text('Todas')),
                    for (final vivienda in viewModel.viviendas)
                      DropdownMenuItem<String?>(
                        value: vivienda.id,
                        child: Text(vivienda.numero),
                      ),
                  ],
                  onChanged: viewModel.filtrarPorVivienda,
                ),
                const SizedBox(height: 16),
                if (viewModel.visitas.isEmpty)
                  const Text(
                    'No hay visitas dentro de la residencial.',
                    key: Key('sin-visitas-dentro'),
                  )
                else
                  for (final visita in viewModel.visitas)
                    TarjetaVisitaDentro(visita: visita),
              ],
            ),
          );
        },
      ),
    );
  }
}

class TarjetaVisitaDentro extends StatelessWidget {
  const TarjetaVisitaDentro({required this.visita, this.alTocar, super.key});

  final Visita visita;
  final VoidCallback? alTocar;

  @override
  Widget build(BuildContext context) {
    final identificacion = visita.numeroIdentificacion == null
        ? 'Sin identificación'
        : '${visita.tipoIdentificacion ?? 'Identificación'}: '
              '${visita.numeroIdentificacion}';
    return Card(
      key: Key('visita-dentro-${visita.id}'),
      child: ListTile(
        title: Text(visita.nombreVisitante),
        subtitle: Text(
          'Vivienda: ${visita.viviendaNumero ?? visita.viviendaId}\n'
          '$identificacion\n'
          'Entrada: ${formatearFechaHora(visita.entrada!)}',
        ),
        isThreeLine: true,
        onTap: alTocar,
      ),
    );
  }
}
