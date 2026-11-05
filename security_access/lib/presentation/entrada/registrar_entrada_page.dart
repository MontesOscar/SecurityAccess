import 'package:flutter/material.dart';
import 'package:security_access/app/dependencias_app.dart';
import 'package:security_access/domain/entities/motivo_rechazo.dart';
import 'package:security_access/domain/entities/tipo_identificacion.dart';
import 'package:security_access/presentation/comun/fecha_hora.dart';
import 'package:security_access/presentation/comun/mostrar_aviso.dart';
import 'package:security_access/presentation/entrada/escaner_qr.dart';
import 'package:security_access/presentation/entrada/registrar_entrada_view_model.dart';
import 'package:security_access/presentation/entrada/simulador_lectura.dart';

class RegistrarEntradaPage extends StatefulWidget {
  const RegistrarEntradaPage({super.key});

  @override
  State<RegistrarEntradaPage> createState() => _RegistrarEntradaPageState();
}

class _RegistrarEntradaPageState extends State<RegistrarEntradaPage> {
  final _codigo = TextEditingController();
  final _numero = TextEditingController();
  RegistrarEntradaViewModel? _viewModel;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_viewModel != null) {
      return;
    }
    final dependencias = DependenciasApp.of(context);
    _viewModel = RegistrarEntradaViewModel(
      leer: dependencias.leerQr,
      registrar: dependencias.registrarEntrada,
      rechazar: dependencias.rechazarAcceso,
      guardia: dependencias.session.usuario,
    );
  }

  @override
  void dispose() {
    _codigo.dispose();
    _numero.dispose();
    _viewModel?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = _viewModel!;
    final tema = Theme.of(context);
    return Scaffold(
      key: const Key('pagina-registrar-entrada'),
      appBar: AppBar(title: const Text('Registrar entrada')),
      body: ListenableBuilder(
        listenable: viewModel,
        builder: (context, _) {
          final estado = viewModel.state;
          final lectura = estado.lectura;
          final invitacion = lectura?.invitacion;
          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              if (lectura == null) ...[
                if (mostrarSimuladorLectura) ...[
                  TextField(
                    key: const Key('campo-codigo-leido'),
                    controller: _codigo,
                    decoration: const InputDecoration(
                      labelText: 'Código leído',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  FilledButton(
                    key: const Key('boton-leer-codigo'),
                    onPressed: () => viewModel.leer(_codigo.text),
                    child: const Text('Leer código'),
                  ),
                ] else
                  EscanerQr(alLeer: viewModel.leer),
                const SizedBox(height: 12),
                OutlinedButton(
                  key: const Key('boton-qr-ilegible'),
                  onPressed: viewModel.marcarIlegible,
                  child: const Text('No se pudo leer el código'),
                ),
              ] else ...[
                Text(
                  lectura.etiqueta,
                  key: const Key('mensaje-lectura'),
                  style: tema.textTheme.titleLarge,
                ),
                if (lectura.mensaje != lectura.etiqueta) ...[
                  const SizedBox(height: 4),
                  Text(lectura.mensaje),
                ],
                if (invitacion != null) ...[
                  const SizedBox(height: 16),
                  Text('Visitante: ${invitacion.nombreVisitante}'),
                  Text('Vivienda: ${invitacion.viviendaNumero}'),
                  Text('Entrada: ${formatearFechaHora(invitacion.entrada)}'),
                  Text('Salida: ${formatearFechaHora(invitacion.salida)}'),
                  Text('Visita: ${invitacion.estadoVisita.etiqueta}'),
                ],
                if (lectura.esValida) ...[
                  const SizedBox(height: 16),
                  DropdownButtonFormField<TipoIdentificacion>(
                    key: const Key('selector-tipo-identificacion'),
                    initialValue: estado.tipo,
                    decoration: const InputDecoration(
                      labelText: 'Tipo de identificación *',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      for (final tipo in TipoIdentificacion.values)
                        DropdownMenuItem(
                          value: tipo,
                          child: Text(tipo.etiqueta),
                        ),
                    ],
                    onChanged: viewModel.seleccionarTipo,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    key: const Key('campo-numero-identificacion'),
                    controller: _numero,
                    decoration: const InputDecoration(
                      labelText: 'Número de identificación *',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: viewModel.cambiarNumero,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '¿La identidad coincide con la invitación?',
                    style: tema.textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      ChoiceChip(
                        key: const Key('opcion-coincide'),
                        label: const Text('Coincide'),
                        selected: estado.coincide == true,
                        onSelected: (_) => viewModel.indicarCoincidencia(true),
                      ),
                      ChoiceChip(
                        key: const Key('opcion-no-coincide'),
                        label: const Text('No coincide'),
                        selected: estado.coincide == false,
                        onSelected: (_) => viewModel.indicarCoincidencia(false),
                      ),
                    ],
                  ),
                  if (estado.coincide == false) ...[
                    const SizedBox(height: 8),
                    const Text(
                      'Si la identidad no coincide, no se puede autorizar la entrada.',
                    ),
                  ],
                  const SizedBox(height: 16),
                  FilledButton(
                    key: const Key('boton-confirmar-entrada'),
                    onPressed: estado.puedeConfirmar
                        ? () => _confirmar(viewModel)
                        : null,
                    child: const Text('Confirmar'),
                  ),
                ],
                const SizedBox(height: 12),
                OutlinedButton(
                  key: const Key('boton-rechazar-acceso'),
                  onPressed: () => _rechazar(viewModel),
                  child: const Text('Rechazar acceso'),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Future<void> _confirmar(RegistrarEntradaViewModel viewModel) async {
    final mensaje = await viewModel.confirmar();
    if (!mounted || mensaje == null) {
      return;
    }
    mostrarAviso(context, mensaje);
  }

  Future<void> _rechazar(RegistrarEntradaViewModel viewModel) async {
    final resultado =
        await showDialog<({MotivoRechazo motivo, String descripcion})>(
          context: context,
          builder: (context) => const _DialogoRechazo(),
        );
    if (resultado == null || !mounted) {
      return;
    }
    final mensaje = await viewModel.rechazar(
      motivo: resultado.motivo,
      descripcion: resultado.descripcion,
    );
    if (!mounted || mensaje == null) {
      return;
    }
    mostrarAviso(context, mensaje);
  }
}

class _DialogoRechazo extends StatefulWidget {
  const _DialogoRechazo();

  @override
  State<_DialogoRechazo> createState() => _DialogoRechazoState();
}

class _DialogoRechazoState extends State<_DialogoRechazo> {
  MotivoRechazo? _motivo;
  final _descripcion = TextEditingController();

  @override
  void dispose() {
    _descripcion.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final otroIncompleto =
        _motivo == MotivoRechazo.otro && _descripcion.text.trim().isEmpty;
    return AlertDialog(
      title: const Text('Rechazar acceso'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<MotivoRechazo>(
            key: const Key('selector-motivo-rechazo'),
            initialValue: _motivo,
            decoration: const InputDecoration(
              labelText: 'Motivo *',
              border: OutlineInputBorder(),
            ),
            items: [
              for (final motivo in MotivoRechazo.values)
                DropdownMenuItem(value: motivo, child: Text(motivo.etiqueta)),
            ],
            onChanged: (motivo) => setState(() => _motivo = motivo),
          ),
          if (_motivo == MotivoRechazo.otro) ...[
            const SizedBox(height: 12),
            TextField(
              key: const Key('campo-descripcion-rechazo'),
              controller: _descripcion,
              decoration: const InputDecoration(
                labelText: 'Descripción *',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Volver'),
        ),
        FilledButton(
          key: const Key('confirmar-rechazo'),
          onPressed: _motivo == null || otroIncompleto
              ? null
              : () => Navigator.of(context)
                    .pop((motivo: _motivo!, descripcion: _descripcion.text)),
          child: const Text('Registrar rechazo'),
        ),
      ],
    );
  }
}
