import 'package:flutter/material.dart';
import 'package:security_access/app/dependencias_app.dart';
import 'package:security_access/domain/entities/vivienda.dart';
import 'package:security_access/presentation/viviendas/editar_vivienda_view_model.dart';
import 'package:security_access/presentation/viviendas/formulario_vivienda.dart';

class EditarViviendaPage extends StatefulWidget {
  const EditarViviendaPage({required this.vivienda, super.key});

  final Vivienda vivienda;

  static const mensajeExito = 'Vivienda actualizada correctamente';

  @override
  State<EditarViviendaPage> createState() => _EditarViviendaPageState();
}

class _EditarViviendaPageState extends State<EditarViviendaPage> {
  late final TextEditingController _numero = TextEditingController(
    text: widget.vivienda.numero,
  );
  late final TextEditingController _direccion = TextEditingController(
    text: widget.vivienda.direccion,
  );
  late final TextEditingController _residente = TextEditingController(
    text: widget.vivienda.residenteNombre ?? 'Sin residente',
  );
  EditarViviendaViewModel? _viewModel;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _viewModel ??= EditarViviendaViewModel(
      editar: DependenciasApp.of(context).editarVivienda,
      vivienda: widget.vivienda,
    );
  }

  @override
  void dispose() {
    _numero.dispose();
    _direccion.dispose();
    _residente.dispose();
    _viewModel?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = _viewModel!;
    return Scaffold(
      appBar: AppBar(title: const Text('Editar vivienda')),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: viewModel,
          builder: (context, _) {
            final estado = viewModel.state;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: FormularioVivienda(
                numero: _numero,
                direccion: _direccion,
                residente: _residente,
                numeroBloqueado: true,
                guardando: estado.guardando,
                textoBoton: 'Guardar cambios',
                errorDireccion: estado.errorDireccion,
                mensaje: estado.mensaje,
                onGuardar: _guardar,
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _guardar() async {
    final actualizada = await _viewModel!.guardar(_direccion.text);
    if (!actualizada || !mounted) {
      return;
    }
    Navigator.of(context).pop(EditarViviendaPage.mensajeExito);
  }
}
