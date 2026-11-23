import 'package:flutter/material.dart';
import 'package:security_access/app/dependencias_app.dart';
import 'package:security_access/domain/entities/visita.dart';
import 'package:security_access/presentation/comun/fecha_hora.dart';
import 'package:security_access/presentation/comun/mostrar_aviso.dart';
import 'package:security_access/presentation/salida/salida_manual_view_model.dart';
import 'package:security_access/presentation/salida/visitas_dentro_page.dart';

class SalidaManualPage extends StatefulWidget {
  const SalidaManualPage({super.key});

  @override
  State<SalidaManualPage> createState() => _SalidaManualPageState();
}

class _SalidaManualPageState extends State<SalidaManualPage> {
  final _busqueda = TextEditingController();
  SalidaManualViewModel? _viewModel;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_viewModel != null) {
      return;
    }
    final dependencias = DependenciasApp.of(context);
    _viewModel = SalidaManualViewModel(
      buscar: dependencias.buscarVisitasActivas,
      registrar: dependencias.registrarSalidaManual,
      guardia: dependencias.session.usuario,
    )..buscar();
  }

  @override
  void dispose() {
    _busqueda.dispose();
    _viewModel?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = _viewModel!;
    return Scaffold(
      key: const Key('pagina-salida-manual'),
      appBar: AppBar(title: const Text('Salida manual')),
      body: ListenableBuilder(
        listenable: viewModel,
        builder: (context, _) {
          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              TextField(
                key: const Key('campo-buscar-visita'),
                controller: _busqueda,
                decoration: const InputDecoration(
                  labelText: 'Buscar por vivienda, visitante o identificación',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                onChanged: viewModel.buscar,
              ),
              const SizedBox(height: 16),
              if (viewModel.cargando)
                const Center(child: CircularProgressIndicator())
              else if (viewModel.visitas.isEmpty)
                const Text(
                  'No hay visitas activas que coincidan.',
                  key: Key('sin-visitas-activas'),
                )
              else
                for (final visita in viewModel.visitas)
                  TarjetaVisitaDentro(
                    visita: visita,
                    alTocar: () => _cerrar(viewModel, visita),
                  ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _cerrar(SalidaManualViewModel viewModel, Visita visita) async {
    final motivo = await showDialog<String>(
      context: context,
      builder: (context) => _DialogoSalidaManual(visita: visita),
    );
    if (motivo == null || !mounted) {
      return;
    }
    final mensaje = await viewModel.cerrar(visita: visita, motivo: motivo);
    if (!mounted) {
      return;
    }
    mostrarAviso(context, mensaje);
  }
}

class _DialogoSalidaManual extends StatefulWidget {
  const _DialogoSalidaManual({required this.visita});

  final Visita visita;

  @override
  State<_DialogoSalidaManual> createState() => _DialogoSalidaManualState();
}

class _DialogoSalidaManualState extends State<_DialogoSalidaManual> {
  final _motivo = TextEditingController();

  @override
  void dispose() {
    _motivo.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final visita = widget.visita;
    final sinMotivo = _motivo.text.trim().isEmpty;
    return AlertDialog(
      title: const Text('¿Cerrar esta visita?'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Visitante: ${visita.nombreVisitante}'),
          Text('Vivienda: ${visita.viviendaNumero ?? visita.viviendaId}'),
          Text('Entrada: ${formatearFechaHora(visita.entrada!)}'),
          const SizedBox(height: 12),
          TextField(
            key: const Key('campo-motivo-salida-manual'),
            controller: _motivo,
            decoration: const InputDecoration(
              labelText: 'Motivo de salida manual *',
              border: OutlineInputBorder(),
            ),
            onChanged: (_) => setState(() {}),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Volver'),
        ),
        FilledButton(
          key: const Key('confirmar-salida-manual'),
          onPressed: sinMotivo
              ? null
              : () => Navigator.of(context).pop(_motivo.text),
          child: const Text('Confirmar salida'),
        ),
      ],
    );
  }
}
