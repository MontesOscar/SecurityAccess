import 'package:flutter/material.dart';
import 'package:security_access/app/dependencias_app.dart';
import 'package:security_access/domain/entities/estado_invitacion.dart';
import 'package:security_access/domain/entities/invitacion.dart';
import 'package:security_access/presentation/comun/fecha_hora.dart';
import 'package:security_access/presentation/comun/mostrar_aviso.dart';
import 'package:security_access/presentation/invitaciones/aviso_invitacion.dart';
import 'package:security_access/presentation/invitaciones/crear_invitacion_page.dart';
import 'package:security_access/presentation/invitaciones/detalle_invitacion_page.dart';
import 'package:security_access/presentation/invitaciones/invitaciones_view_model.dart';

class InvitacionesPage extends StatefulWidget {
  const InvitacionesPage({super.key});

  @override
  State<InvitacionesPage> createState() => _InvitacionesPageState();
}

class _InvitacionesPageState extends State<InvitacionesPage> {
  final _desde = TextEditingController();
  final _hasta = TextEditingController();
  InvitacionesViewModel? _viewModel;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_viewModel != null) {
      return;
    }
    final dependencias = DependenciasApp.of(context);
    _viewModel = InvitacionesViewModel(
      consultar: dependencias.consultarInvitaciones,
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
      key: const Key('pagina-invitaciones'),
      appBar: AppBar(title: const Text('Invitaciones')),
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('boton-nueva-invitacion'),
        onPressed: _crear,
        icon: const Icon(Icons.qr_code_2_outlined),
        label: const Text('Nueva invitación'),
      ),
      body: ListenableBuilder(
        listenable: viewModel,
        builder: (context, _) {
          final estado = viewModel.state;
          return ListView(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 96),
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  FilterChip(
                    key: const Key('filtro-invitacion-todas'),
                    label: const Text('Todas'),
                    selected: estado.estado == null,
                    onSelected: (_) => viewModel.cambiarEstado(null),
                  ),
                  for (final valor in EstadoInvitacion.values)
                    FilterChip(
                      key: Key('filtro-invitacion-${valor.name}'),
                      label: Text(valor.etiqueta),
                      selected: estado.estado == valor,
                      onSelected: (_) => viewModel.cambiarEstado(valor),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                key: const Key('campo-desde-invitacion'),
                controller: _desde,
                decoration: InputDecoration(
                  labelText: 'Desde',
                  hintText: 'dd/MM/aaaa',
                  errorText: estado.errorDesde,
                ),
                onSubmitted: (_) => _filtrar(),
              ),
              const SizedBox(height: 12),
              TextField(
                key: const Key('campo-hasta-invitacion'),
                controller: _hasta,
                decoration: InputDecoration(
                  labelText: 'Hasta',
                  hintText: 'dd/MM/aaaa',
                  errorText: estado.errorHasta,
                ),
                onSubmitted: (_) => _filtrar(),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: OutlinedButton(
                  key: const Key('boton-filtrar-invitaciones'),
                  onPressed: _filtrar,
                  child: const Text('Filtrar'),
                ),
              ),
              const SizedBox(height: 16),
              if (estado.invitaciones.isEmpty)
                const Text('No hay invitaciones para este filtro.')
              else
                for (final invitacion in estado.invitaciones)
                  _TarjetaInvitacion(
                    invitacion: invitacion,
                    onAbrir: () => _abrirDetalle(invitacion.id),
                  ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _filtrar() async {
    await _viewModel!.cargar(desde: _desde.text, hasta: _hasta.text);
  }

  Future<void> _crear() async {
    final aviso = await Navigator.of(context).push<AvisoInvitacion>(
      MaterialPageRoute<AvisoInvitacion>(
        builder: (context) => const CrearInvitacionPage(),
      ),
    );
    if (!mounted || aviso == null) {
      return;
    }
    await _viewModel!.cargar(desde: _desde.text, hasta: _hasta.text);
    if (!mounted) {
      return;
    }
    mostrarAviso(context, aviso.mensaje, detalle: aviso.detalle);
  }

  Future<void> _abrirDetalle(String id) async {
    final aviso = await Navigator.of(context).push<AvisoInvitacion>(
      MaterialPageRoute<AvisoInvitacion>(
        builder: (context) => DetalleInvitacionPage(invitacionId: id),
      ),
    );
    if (!mounted) {
      return;
    }
    await _viewModel!.cargar(desde: _desde.text, hasta: _hasta.text);
    if (!mounted || aviso == null) {
      return;
    }
    mostrarAviso(context, aviso.mensaje, detalle: aviso.detalle);
  }
}

class _TarjetaInvitacion extends StatelessWidget {
  const _TarjetaInvitacion({required this.invitacion, required this.onAbrir});

  final Invitacion invitacion;
  final VoidCallback onAbrir;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Card(
      key: Key('invitacion-${invitacion.id}'),
      child: ListTile(
        title: Text(invitacion.nombreVisitante),
        subtitle: Text(
          '${formatearFechaHora(invitacion.entrada)} – ${formatearFechaHora(invitacion.salida)}\n${invitacion.estado.etiqueta} · ${invitacion.estadoVisita.etiqueta}',
        ),
        isThreeLine: true,
        trailing: Text(
          invitacion.estado.etiqueta,
          key: Key('estado-invitacion-${invitacion.id}'),
          style: tema.textTheme.labelLarge,
        ),
        onTap: onAbrir,
      ),
    );
  }
}
