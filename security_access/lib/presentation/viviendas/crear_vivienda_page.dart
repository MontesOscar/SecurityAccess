import 'package:flutter/material.dart';
import 'package:security_access/app/dependencias_app.dart';
import 'package:security_access/presentation/viviendas/crear_vivienda_view_model.dart';
import 'package:security_access/presentation/viviendas/formulario_vivienda.dart';

class CrearViviendaPage extends StatefulWidget {
  const CrearViviendaPage({super.key});

  static const mensajeExito = 'Vivienda registrada correctamente';

  @override
  State<CrearViviendaPage> createState() => _CrearViviendaPageState();
}

class _CrearViviendaPageState extends State<CrearViviendaPage> {
  final _numero = TextEditingController();
  final _direccion = TextEditingController();
  final _residente = TextEditingController(text: 'Sin residente');
  CrearViviendaViewModel? _viewModel;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _viewModel ??= CrearViviendaViewModel(
      DependenciasApp.of(context).crearVivienda,
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
      appBar: AppBar(title: const Text('Nueva vivienda')),
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
                numeroBloqueado: false,
                guardando: estado.guardando,
                textoBoton: 'Guardar',
                errorNumero: estado.errorNumero,
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
    final creada = await _viewModel!.guardar(
      numero: _numero.text,
      direccion: _direccion.text,
    );
    if (!creada || !mounted) {
      return;
    }
    Navigator.of(context).pop(CrearViviendaPage.mensajeExito);
  }
}
