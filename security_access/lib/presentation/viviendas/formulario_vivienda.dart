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
    this.mensaje,
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
  final String? mensaje;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          key: const Key('campo-numero'),
          controller: numero,
          enabled: !numeroBloqueado,
          textInputAction: TextInputAction.next,
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
            helperText:
                'La asignación de residente se habilita al registrar usuarios.',
            border: OutlineInputBorder(),
          ),
        ),
        if (mensaje != null) ...[
          const SizedBox(height: 16),
          Text(
            mensaje!,
            key: const Key('mensaje-formulario-vivienda'),
            style: tema.textTheme.bodyMedium?.copyWith(
              color: tema.colorScheme.error,
            ),
          ),
        ],
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
