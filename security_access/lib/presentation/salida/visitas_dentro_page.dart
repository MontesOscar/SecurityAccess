import 'package:flutter/material.dart';
import 'package:security_access/app/dependencias_app.dart';
import 'package:security_access/domain/usecases/registrar_salida.dart';
import 'package:security_access/domain/usecases/resultado_registrar_salida.dart';
import 'package:security_access/presentation/comun/fecha_hora.dart';
import 'package:security_access/presentation/comun/mostrar_aviso.dart';
import 'package:security_access/presentation/salida/visitas_dentro_view_model.dart';

class VisitasDentroPage extends StatefulWidget {
  const VisitasDentroPage({super.key});

  @override
  State<VisitasDentroPage> createState() => _VisitasDentroPageState();
}

class _VisitasDentroPageState extends State<VisitasDentroPage> {
  final _consulta = TextEditingController();
  final _fecha = TextEditingController();
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
      registrar: dependencias.registrarSalida,
      guardia: dependencias.session.usuario,
    )..cargar();
  }

  @override
  void dispose() {
    _consulta.dispose();
    _fecha.dispose();
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
          final estado = viewModel.state;
          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              TextField(
                key: const Key('campo-buscar-visita'),
                controller: _consulta,
                decoration: const InputDecoration(
                  labelText: 'Vivienda, visitante o identificación',
                  border: OutlineInputBorder(),
                ),
                onSubmitted: (_) => _filtrar(viewModel),
              ),
              const SizedBox(height: 12),
              TextField(
                key: const Key('campo-fecha-visita'),
                controller: _fecha,
                decoration: const InputDecoration(
                  labelText: 'Fecha de entrada (dd/MM/aaaa)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              FilledButton(
                key: const Key('boton-filtrar-visitas'),
                onPressed: () => _filtrar(viewModel),
                child: const Text('Filtrar'),
              ),
              const SizedBox(height: 16),
              if (estado.visitas.isEmpty)
                const Text('No hay visitas dentro del conjunto')
              else
                for (final visita in estado.visitas)
                  Card(
                    key: Key('visita-dentro-${visita.id}'),
                    child: ListTile(
                      title: Text(visita.nombreVisitante),
                      subtitle: Text(
                        'Vivienda ${visita.viviendaNumero.isEmpty ? visita.viviendaId : visita.viviendaNumero}\n'
                        'Entrada: ${formatearFechaHora(visita.entrada ?? visita.fecha)}'
                        '${visita.numeroIdentificacion == null ? '' : '\n${visita.tipoIdentificacion ?? ''} ${visita.numeroIdentificacion}'}',
                      ),
                      isThreeLine: true,
                      trailing: TextButton(
                        key: Key('boton-salida-manual-${visita.id}'),
                        onPressed: () => _pedirMotivo(viewModel, visita.id),
                        child: const Text('Salida manual'),
                      ),
                    ),
                  ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _filtrar(VisitasDentroViewModel viewModel) async {
    final texto = _fecha.text.trim();
    if (texto.isEmpty) {
      await viewModel.filtrar(consulta: _consulta.text, limpiarFecha: true);
      return;
    }
    final fecha = leerFecha(texto);
    if (fecha == null) {
      if (mounted) {
        mostrarAviso(context, 'La fecha no es válida');
      }
      return;
    }
    await viewModel.filtrar(consulta: _consulta.text, fecha: fecha);
  }

  Future<void> _pedirMotivo(
    VisitasDentroViewModel viewModel,
    String visitaId,
  ) async {
    var motivo = '';
    final aceptado = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Registrar salida manual'),
          content: TextField(
            key: const Key('campo-motivo-salida'),
            decoration: const InputDecoration(
              labelText: 'Motivo *',
              border: OutlineInputBorder(),
            ),
            onChanged: (valor) => motivo = valor,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              key: const Key('confirmar-salida-manual'),
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Confirmar'),
            ),
          ],
        );
      },
    );
    if (aceptado != true || !mounted) {
      return;
    }
    final resultado = await viewModel.registrarManual(
      visitaId: visitaId,
      motivo: motivo,
    );
    if (!mounted || resultado == null) {
      return;
    }
    if (resultado is SalidaRegistrada) {
      final hora = formatearFechaHora(
        resultado.visita.salida ?? DateTime.now(),
      );
      mostrarAviso(context, SalidaRegistrada.mensaje, detalle: hora);
      return;
    }
    if (resultado is SalidaNoRegistrada) {
      mostrarAviso(context, resultado.mensaje);
    }
  }
}
