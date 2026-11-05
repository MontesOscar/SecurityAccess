import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:security_access/app/dependencias_app.dart';
import 'package:security_access/domain/entities/invitacion.dart';
import 'package:security_access/presentation/comun/fecha_hora.dart';
import 'package:security_access/presentation/comun/mostrar_aviso.dart';
import 'package:security_access/presentation/invitaciones/aviso_invitacion.dart';
import 'package:security_access/presentation/invitaciones/compartir_qr.dart';
import 'package:security_access/presentation/invitaciones/detalle_invitacion_view_model.dart';
import 'package:security_access/presentation/invitaciones/resultado_compartir_qr.dart';

class DetalleInvitacionPage extends StatefulWidget {
  const DetalleInvitacionPage({required this.invitacionId, super.key});

  final String invitacionId;

  @override
  State<DetalleInvitacionPage> createState() => _DetalleInvitacionPageState();
}

class _DetalleInvitacionPageState extends State<DetalleInvitacionPage> {
  DetalleInvitacionViewModel? _viewModel;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_viewModel != null) {
      return;
    }
    final dependencias = DependenciasApp.of(context);
    _viewModel = DetalleInvitacionViewModel(
      buscar: dependencias.buscarInvitacion,
      cancelar: dependencias.cancelarInvitacion,
      residente: dependencias.session.usuario,
      invitacionId: widget.invitacionId,
    );
    _viewModel!.cargar();
  }

  @override
  void dispose() {
    _viewModel?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = _viewModel!;
    final tema = Theme.of(context);
    return Scaffold(
      key: const Key('pagina-detalle-invitacion'),
      appBar: AppBar(title: const Text('Detalle de invitación')),
      body: ListenableBuilder(
        listenable: viewModel,
        builder: (context, _) {
          final invitacion = viewModel.state.invitacion;
          if (viewModel.state.cargando) {
            return const Center(child: CircularProgressIndicator());
          }
          if (invitacion == null) {
            return const Center(
              child: Text('La invitación no está disponible.'),
            );
          }
          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Text(
                invitacion.nombreVisitante,
                style: tema.textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text('Vivienda ${invitacion.viviendaNumero}'),
              Text('Entrada: ${formatearFechaHora(invitacion.entrada)}'),
              Text('Salida: ${formatearFechaHora(invitacion.salida)}'),
              const SizedBox(height: 8),
              Text(
                invitacion.estado.etiqueta,
                key: const Key('detalle-estado-invitacion'),
              ),
              Text(
                invitacion.estadoVisita.etiqueta,
                key: const Key('detalle-estado-visita'),
              ),
              const SizedBox(height: 24),
              Center(
                child: QrImageView(
                  key: const Key('imagen-qr'),
                  data: invitacion.codigoQr,
                  size: 180,
                ),
              ),
              const SizedBox(height: 12),
              SelectableText(
                invitacion.codigoQr,
                key: const Key('codigo-qr'),
                textAlign: TextAlign.center,
                style: tema.textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                key: const Key('boton-compartir-qr'),
                onPressed: () => _compartir(invitacion),
                icon: const Icon(Icons.share_outlined),
                label: const Text('Compartir QR'),
              ),
              if (invitacion.puedeCancelarse) ...[
                const SizedBox(height: 12),
                FilledButton(
                  key: const Key('boton-cancelar-invitacion'),
                  onPressed: _cancelar,
                  child: const Text('Cancelar invitación'),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Future<void> _compartir(Invitacion invitacion) async {
    final texto = [
      'Invitación de acceso',
      'Visitante: ${invitacion.nombreVisitante}',
      'Vivienda: ${invitacion.viviendaNumero}',
      'Entrada: ${formatearFechaHora(invitacion.entrada)}',
      'Salida: ${formatearFechaHora(invitacion.salida)}',
    ].join('\n');
    try {
      final resultado = await compartirImagenQr(
        codigo: invitacion.codigoQr,
        texto: texto,
      );
      if (!mounted || resultado != ResultadoCompartirQr.descarga) {
        return;
      }
      mostrarAviso(
        context,
        'Se descargó la imagen del QR',
        detalle: 'qr-${invitacion.codigoQr}.png',
      );
    } on Exception {
      if (!mounted) {
        return;
      }
      mostrarAviso(context, 'No se pudo compartir el código QR');
    }
  }

  Future<void> _cancelar() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Cancelar invitación'),
          content: const Text(
            'El código QR dejará de permitir el acceso. La invitación permanecerá en el historial.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Volver'),
            ),
            FilledButton(
              key: const Key('confirmar-cancelar-invitacion'),
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Cancelar invitación'),
            ),
          ],
        );
      },
    );
    if (confirmar != true || !mounted) {
      return;
    }
    final mensaje = await _viewModel!.cancelar();
    if (!mounted || mensaje == null) {
      return;
    }
    Navigator.of(context).pop(AvisoInvitacion(mensaje));
  }
}
