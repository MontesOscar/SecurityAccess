import 'package:flutter/material.dart';
import 'package:security_access/app/dependencias_app.dart';
import 'package:security_access/presentation/invitaciones/aviso_invitacion.dart';
import 'package:security_access/presentation/invitaciones/crear_invitacion_view_model.dart';

class CrearInvitacionPage extends StatefulWidget {
  const CrearInvitacionPage({super.key});

  static const mensajeExito = 'Invitación registrada correctamente';

  @override
  State<CrearInvitacionPage> createState() => _CrearInvitacionPageState();
}

class _CrearInvitacionPageState extends State<CrearInvitacionPage> {
  final _nombre = TextEditingController();
  final _fechaEntrada = TextEditingController();
  final _horaEntrada = TextEditingController();
  final _fechaSalida = TextEditingController();
  final _horaSalida = TextEditingController();
  CrearInvitacionViewModel? _viewModel;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_viewModel != null) {
      return;
    }
    final dependencias = DependenciasApp.of(context);
    _viewModel = CrearInvitacionViewModel(
      crear: dependencias.crearInvitacion,
      residente: dependencias.session.usuario,
    );
  }

  @override
  void dispose() {
    _nombre.dispose();
    _fechaEntrada.dispose();
    _horaEntrada.dispose();
    _fechaSalida.dispose();
    _horaSalida.dispose();
    _viewModel?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = _viewModel!;
    return Scaffold(
      appBar: AppBar(title: const Text('Nueva invitación')),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: viewModel,
          builder: (context, _) {
            final estado = viewModel.state;
            return ListView(
              padding: const EdgeInsets.all(24),
              children: [
                TextField(
                  key: const Key('campo-nombre-visitante'),
                  controller: _nombre,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: 'Nombre del visitante *',
                    errorText: estado.errorNombre,
                  ),
                  onChanged: (_) => viewModel.corregirNombre(),
                ),
                const SizedBox(height: 16),
                TextField(
                  key: const Key('campo-fecha-entrada'),
                  controller: _fechaEntrada,
                  decoration: InputDecoration(
                    labelText: 'Fecha de entrada *',
                    hintText: 'dd/MM/aaaa',
                    errorText: estado.errorFechaEntrada,
                  ),
                  onChanged: (_) => viewModel.corregirFechaEntrada(),
                ),
                const SizedBox(height: 16),
                TextField(
                  key: const Key('campo-hora-entrada'),
                  controller: _horaEntrada,
                  decoration: InputDecoration(
                    labelText: 'Hora de entrada *',
                    hintText: 'HH:mm',
                    errorText: estado.errorHoraEntrada,
                  ),
                  onChanged: (_) => viewModel.corregirHoraEntrada(),
                ),
                const SizedBox(height: 16),
                TextField(
                  key: const Key('campo-fecha-salida'),
                  controller: _fechaSalida,
                  decoration: InputDecoration(
                    labelText: 'Fecha de salida *',
                    hintText: 'dd/MM/aaaa',
                    errorText: estado.errorFechaSalida,
                  ),
                  onChanged: (_) => viewModel.corregirFechaSalida(),
                ),
                const SizedBox(height: 16),
                TextField(
                  key: const Key('campo-hora-salida'),
                  controller: _horaSalida,
                  decoration: InputDecoration(
                    labelText: 'Hora de salida *',
                    hintText: 'HH:mm',
                    errorText: estado.errorHoraSalida,
                  ),
                  onChanged: (_) => viewModel.corregirHoraSalida(),
                ),
                if (estado.errorGeneral != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    estado.errorGeneral!,
                    key: const Key('error-invitacion'),
                  ),
                ],
                const SizedBox(height: 24),
                FilledButton(
                  key: const Key('boton-guardar-invitacion'),
                  onPressed: estado.guardando ? null : _guardar,
                  child: const Text('Guardar'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _guardar() async {
    final creada = await _viewModel!.guardar(
      nombre: _nombre.text,
      fechaEntrada: _fechaEntrada.text,
      horaEntrada: _horaEntrada.text,
      fechaSalida: _fechaSalida.text,
      horaSalida: _horaSalida.text,
    );
    if (creada == null || !mounted) {
      return;
    }
    Navigator.of(context).pop(
      AvisoInvitacion(
        CrearInvitacionPage.mensajeExito,
        detalle: 'Código QR: ${creada.invitacion.codigoQr}',
      ),
    );
  }
}
