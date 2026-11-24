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
          final visita = estado.visita;
          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              if (visita == null) ...[
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
              ] else ...[
                Text('Salida pendiente', style: tema.textTheme.titleLarge),
                const SizedBox(height: 16),
                Text('Visitante: ${visita.nombreVisitante}'),
                Text('Vivienda: ${visita.viviendaNumero}'),
                Text(
                  'Entrada: ${formatearFechaHora(visita.entrada ?? visita.fecha)}',
                ),
                if (visita.numeroIdentificacion != null)
                  Text(
                    'Identificación: ${visita.tipoIdentificacion ?? ''} ${visita.numeroIdentificacion}',
                  ),
                const SizedBox(height: 16),
                FilledButton(
                  key: const Key('boton-confirmar-salida'),
                  onPressed: estado.puedeConfirmar
                      ? () => _confirmar(viewModel)
                      : null,
                  child: const Text('Confirmar salida'),
                ),
              ],
              if (estado.mensaje != null) ...[
                const SizedBox(height: 16),
                Text(estado.mensaje!, key: const Key('mensaje-salida')),
              ],
            ],
          );
        },
      ),
    );
  }

  Future<void> _confirmar(RegistrarSalidaViewModel viewModel) async {
    final resultado = await viewModel.confirmar();
    if (!mounted || resultado is! SalidaRegistrada) {
      return;
    }
    final hora = formatearFechaHora(resultado.visita.salida ?? DateTime.now());
    mostrarAviso(
      context,
      SalidaRegistrada.mensaje,
      detalle: 'Hora de salida: $hora',
    );
  }
}
