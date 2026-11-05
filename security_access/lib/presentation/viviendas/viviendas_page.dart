import 'package:flutter/material.dart';
import 'package:security_access/app/dependencias_app.dart';
import 'package:security_access/domain/entities/estado_vivienda.dart';
import 'package:security_access/domain/entities/vivienda.dart';
import 'package:security_access/presentation/comun/mostrar_aviso.dart';
import 'package:security_access/presentation/viviendas/crear_vivienda_page.dart';
import 'package:security_access/presentation/viviendas/editar_vivienda_page.dart';
import 'package:security_access/presentation/viviendas/historial_vivienda_page.dart';
import 'package:security_access/presentation/viviendas/viviendas_view_model.dart';

class ViviendasPage extends StatefulWidget {
  const ViviendasPage({super.key});

  @override
  State<ViviendasPage> createState() => _ViviendasPageState();
}

class _ViviendasPageState extends State<ViviendasPage> {
  final _busqueda = TextEditingController();
  ViviendasViewModel? _viewModel;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_viewModel != null) {
      return;
    }
    final dependencias = DependenciasApp.of(context);
    _viewModel = ViviendasViewModel(
      consultar: dependencias.consultarViviendas,
      cambiarEstado: dependencias.cambiarEstadoVivienda,
    );
    _viewModel!.cargar();
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
      key: const Key('pagina-viviendas'),
      appBar: AppBar(title: const Text('Viviendas')),
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('boton-nueva-vivienda'),
        onPressed: () => _abrirFormulario(const CrearViviendaPage()),
        icon: const Icon(Icons.add),
        label: const Text('Nueva vivienda'),
      ),
      body: ListenableBuilder(
        listenable: viewModel,
        builder: (context, _) {
          final estado = viewModel.state;
          return ListView(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 96),
            children: [
              TextField(
                key: const Key('campo-buscar-vivienda'),
                controller: _busqueda,
                decoration: const InputDecoration(
                  labelText: 'Buscar por número o residente',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: viewModel.buscar,
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                children: [
                  FilterChip(
                    key: const Key('filtro-todas'),
                    label: const Text('Todas'),
                    selected: estado.filtro == null,
                    onSelected: (_) => viewModel.cambiarFiltro(null),
                  ),
                  for (final filtro in EstadoVivienda.values)
                    FilterChip(
                      key: Key('filtro-${filtro.name}'),
                      label: Text(filtro.etiqueta),
                      selected: estado.filtro == filtro,
                      onSelected: (_) => viewModel.cambiarFiltro(filtro),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              if (estado.viviendas.isEmpty)
                Text(
                  estado.busqueda.trim().isEmpty && estado.filtro == null
                      ? 'No hay viviendas registradas.'
                      : 'No hay viviendas para este filtro.',
                )
              else
                for (final vivienda in estado.viviendas)
                  _TarjetaVivienda(
                    vivienda: vivienda,
                    onEditar: () => _abrirFormulario(
                      EditarViviendaPage(vivienda: vivienda),
                    ),
                    onHistorial: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (context) =>
                              HistorialViviendaPage(vivienda: vivienda),
                        ),
                      );
                    },
                    onDesactivar: () =>
                        _confirmarCambio(vivienda: vivienda, activar: false),
                    onReactivar: () =>
                        _confirmarCambio(vivienda: vivienda, activar: true),
                  ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _abrirFormulario(Widget pagina) async {
    final mensaje = await Navigator.of(context)
        .push<String>(MaterialPageRoute<String>(builder: (context) => pagina));
    if (!mounted || mensaje == null) {
      return;
    }
    await _viewModel!.cargar();
    if (!mounted) {
      return;
    }
    mostrarAviso(context, mensaje);
  }

  Future<void> _confirmarCambio({
    required Vivienda vivienda,
    required bool activar,
  }) async {
    final titulo = activar ? 'Reactivar vivienda' : 'Desactivar vivienda';
    final contenido = activar
        ? vivienda.tieneResidente
              ? 'La vivienda volverá a estado Asignada.'
              : 'La vivienda volverá a estado Disponible.'
        : 'La vivienda pasará a estado Inactiva y no aparecerá en los desplegables de asignación. El historial se conserva.';
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(titulo),
          content: Text(contenido),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              key: Key(
                activar ? 'confirmar-reactivar' : 'confirmar-desactivar',
              ),
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(activar ? 'Reactivar' : 'Desactivar'),
            ),
          ],
        );
      },
    );
    if (confirmar != true || !mounted) {
      return;
    }
    final aviso = activar
        ? await _viewModel!.reactivar(vivienda.id)
        : await _viewModel!.desactivar(vivienda.id);
    if (!mounted || aviso == null) {
      return;
    }
    mostrarAviso(context, aviso);
  }
}

class _TarjetaVivienda extends StatelessWidget {
  const _TarjetaVivienda({
    required this.vivienda,
    required this.onEditar,
    required this.onHistorial,
    required this.onDesactivar,
    required this.onReactivar,
  });

  final Vivienda vivienda;
  final VoidCallback onEditar;
  final VoidCallback onHistorial;
  final VoidCallback onDesactivar;
  final VoidCallback onReactivar;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final color = switch (vivienda.estado) {
      EstadoVivienda.disponible => tema.colorScheme.tertiary,
      EstadoVivienda.asignada => tema.colorScheme.primary,
      EstadoVivienda.inactiva => tema.colorScheme.outline,
    };
    final numero = vivienda.numero;

    return Card(
      key: Key('vivienda-$numero'),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(numero, style: tema.textTheme.titleLarge)),
                Chip(
                  label: Text(
                    vivienda.estado.etiqueta,
                    key: Key('estado-$numero'),
                  ),
                  backgroundColor: color.withValues(alpha: 0.15),
                  side: BorderSide(color: color),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(vivienda.direccion),
            const SizedBox(height: 4),
            Text(
              'Responsable: ${vivienda.residenteNombre ?? 'Sin residente'}',
              key: Key('responsable-$numero'),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                TextButton(
                  key: Key('boton-editar-$numero'),
                  onPressed: onEditar,
                  child: const Text('Editar'),
                ),
                TextButton(
                  key: Key('boton-historial-$numero'),
                  onPressed: onHistorial,
                  child: const Text('Ver historial'),
                ),
                if (vivienda.estado == EstadoVivienda.inactiva)
                  TextButton(
                    key: Key('boton-reactivar-$numero'),
                    onPressed: onReactivar,
                    child: const Text('Reactivar'),
                  )
                else
                  TextButton(
                    key: Key('boton-desactivar-$numero'),
                    onPressed: onDesactivar,
                    child: const Text('Desactivar'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
