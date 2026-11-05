import 'package:flutter/material.dart';

class FormularioVivienda extends StatelessWidget {
  const FormularioVivienda({
    required this.numero,
    required this.direccion,
    required this.residente,
    required this.numeroBloqueado,
    required this.guardando,
    required this.textoBoton,
    required this.onGuardar,
    this.errorNumero,
    this.errorDireccion,
    this.alCambiarNumero,
    this.alCambiarDireccion,
    super.key,
  });

  final TextEditingController numero;
  final TextEditingController direccion;
  final TextEditingController residente;
  final bool numeroBloqueado;
  final bool guardando;
  final String textoBoton;
  final VoidCallback onGuardar;
  final String? errorNumero;
  final String? errorDireccion;
  final VoidCallback? alCambiarNumero;
  final VoidCallback? alCambiarDireccion;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          key: const Key('campo-numero'),
          controller: numero,
          enabled: !numeroBloqueado,
          textInputAction: TextInputAction.next,
          onChanged: (_) => alCambiarNumero?.call(),
          decoration: InputDecoration(
            labelText: 'Número de vivienda *',
            errorText: errorNumero,
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          key: const Key('campo-direccion'),
          controller: direccion,
          textInputAction: TextInputAction.done,
          onChanged: (_) => alCambiarDireccion?.call(),
          onSubmitted: (_) => onGuardar(),
          decoration: InputDecoration(
            labelText: 'Dirección o referencia *',
            errorText: errorDireccion,
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          key: const Key('campo-residente'),
          controller: residente,
          enabled: false,
          decoration: const InputDecoration(
            labelText: 'Residente asignado',
            helperText: 'El residente se asigna al crear o editar el usuario.',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 20),
        FilledButton(
          key: const Key('boton-guardar-vivienda'),
          onPressed: guardando ? null : onGuardar,
          child: Text(textoBoton),
        ),
      ],
    );
  }
}
