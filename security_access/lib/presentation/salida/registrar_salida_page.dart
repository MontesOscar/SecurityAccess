import 'package:flutter/material.dart';
import 'package:security_access/app/dependencias_app.dart';
import 'package:security_access/domain/usecases/resultado_registrar_salida.dart';
import 'package:security_access/presentation/comun/fecha_hora.dart';
import 'package:security_access/presentation/comun/mostrar_aviso.dart';
import 'package:security_access/presentation/entrada/escaner_qr.dart';
import 'package:security_access/presentation/entrada/simulador_lectura.dart';
import 'package:security_access/presentation/salida/registrar_salida_view_model.dart';

class RegistrarSalidaPage extends StatefulWidget {
  const RegistrarSalidaPage({super.key});

  @override
  State<RegistrarSalidaPage> createState() => _RegistrarSalidaPageState();
}

class _RegistrarSalidaPageState extends State<RegistrarSalidaPage> {
  final _codigo = TextEditingController();
  RegistrarSalidaViewModel? _viewModel;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_viewModel != null) {
      return;
    }
    final dependencias = DependenciasApp.of(context);
    _viewModel = RegistrarSalidaViewModel(
      buscar: dependencias.buscarEntradaActiva,
      registrar: dependencias.registrarSalida,
      guardia: dependencias.session.usuario,
    );
  }

  @override
  void dispose() {
    _codigo.dispose();
    _viewModel?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = _viewModel!;
    final tema = Theme.of(context);
    return Scaffold(
      key: const Key('pagina-registrar-salida'),
      appBar: AppBar(title: const Text('Registrar salida')),
      body: ListenableBuilder(
        listenable: viewModel,
        builder: (context, _) {
          final estado = viewModel.state;
          final busqueda = estado.busqueda;
          final salida = estado.salida;
          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              if (busqueda == null) ...[
                if (mostrarSimuladorLectura) ...[
                  TextField(
                    key: const Key('campo-codigo-salida'),
                    controller: _codigo,
                    decoration: const InputDecoration(
                      labelText: 'Código leído',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  FilledButton(
                    key: const Key('boton-leer-codigo-salida'),
                    onPressed: () => viewModel.leer(_codigo.text),
                    child: const Text('Leer código'),
                  ),
                ] else
                  EscanerQr(alLeer: viewModel.leer),
              ] else if (busqueda case SalidaNoDisponible(:final mensaje))
                Text(
                  mensaje,
                  key: const Key('mensaje-salida'),
                  style: tema.textTheme.titleLarge,
                )
              else if (busqueda case EntradaActivaEncontrada(
                :final visita,
              )) ...[
                Text(
                  salida == null ? 'Entrada activa' : 'Visita completada',
                  style: tema.textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                Text('Visitante: ${visita.nombreVisitante}'),
                Text('Vivienda: ${visita.viviendaNumero ?? visita.viviendaId}'),
                if (visita.numeroIdentificacion != null)
                  Text(
                    '${visita.tipoIdentificacion ?? 'Identificación'}: '
                    '${visita.numeroIdentificacion}',
                  ),
                if (visita.entrada != null)
                  Text('Entrada: ${formatearFechaHora(visita.entrada!)}'),
                const SizedBox(height: 16),
                if (salida == null)
                  FilledButton(
                    key: const Key('boton-confirmar-salida'),
                    onPressed: estado.puedeConfirmar
                        ? () => _confirmar(viewModel)
                        : null,
                    child: const Text('Confirmar salida'),
                  )
                else
                  Text(
                    'Hora de salida: ${formatearFechaHora(salida.salida!)}',
                    key: const Key('hora-salida'),
                    style: tema.textTheme.titleMedium,
                  ),
              ],
            ],
          );
        },
      ),
    );
  }

  Future<void> _confirmar(RegistrarSalidaViewModel viewModel) async {
    final mensaje = await viewModel.confirmar();
    if (!mounted || mensaje == null) {
      return;
    }
    mostrarAviso(context, mensaje);
  }
}
