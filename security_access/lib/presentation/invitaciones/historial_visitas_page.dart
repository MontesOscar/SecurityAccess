import 'package:flutter/material.dart';
import 'package:security_access/app/dependencias_app.dart';
import 'package:security_access/domain/entities/visita.dart';
import 'package:security_access/presentation/comun/fecha_hora.dart';
import 'package:security_access/presentation/invitaciones/historial_visitas_view_model.dart';

class HistorialVisitasPage extends StatefulWidget {
  const HistorialVisitasPage({super.key});

  @override
  State<HistorialVisitasPage> createState() => _HistorialVisitasPageState();
}

class _HistorialVisitasPageState extends State<HistorialVisitasPage> {
  final _desde = TextEditingController();
  final _hasta = TextEditingController();
  HistorialVisitasViewModel? _viewModel;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_viewModel != null) {
      return;
    }
    final dependencias = DependenciasApp.of(context);
    _viewModel = HistorialVisitasViewModel(
      consultar: dependencias.consultarHistorialVisitas,
      residente: dependencias.session.usuario,
    );
    _viewModel!.cargar();
  }

  @override
  void dispose() {
    _desde.dispose();
    _hasta.dispose();
    _viewModel?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = _viewModel!;
    return Scaffold(
      key: const Key('pagina-historial'),
      appBar: AppBar(title: const Text('Historial de visitas')),
      body: ListenableBuilder(
        listenable: viewModel,
        builder: (context, _) {
          final estado = viewModel.state;
          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              TextField(
                key: const Key('campo-desde-historial'),
                controller: _desde,
                decoration: InputDecoration(
                  labelText: 'Desde',
                  hintText: 'dd/MM/aaaa',
                  errorText: estado.errorDesde,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                key: const Key('campo-hasta-historial'),
                controller: _hasta,
                decoration: InputDecoration(
                  labelText: 'Hasta',
                  hintText: 'dd/MM/aaaa',
                  errorText: estado.errorHasta,
                ),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: OutlinedButton(
                  key: const Key('boton-filtrar-historial'),
                  onPressed: () =>
                      viewModel.cargar(desde: _desde.text, hasta: _hasta.text),
                  child: const Text('Filtrar'),
                ),
              ),
              const SizedBox(height: 16),
              if (estado.visitas.isEmpty)
                const Text('Aún no hay visitas registradas.')
              else
                for (final visita in estado.visitas)
                  _TarjetaVisita(visita: visita),
            ],
          );
        },
      ),
    );
  }
}

class _TarjetaVisita extends StatelessWidget {
  const _TarjetaVisita({required this.visita});

  final Visita visita;

  @override
  Widget build(BuildContext context) {
    final entrada = visita.entrada == null
        ? 'Sin entrada'
        : formatearFechaHora(visita.entrada!);
    final salida = visita.salida == null
        ? 'Sin salida'
        : formatearFechaHora(visita.salida!);
    return Card(
      key: Key('visita-${visita.id}'),
      child: ListTile(
        title: Text(visita.nombreVisitante),
        subtitle: Text(
          '${formatearFecha(visita.fecha)}\nEntrada: $entrada\nSalida: $salida',
        ),
        isThreeLine: true,
        trailing: Text(visita.estado.etiqueta),
      ),
    );
  }
}
