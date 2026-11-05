import 'package:flutter/material.dart';
import 'package:security_access/domain/entities/rol_usuario.dart';
import 'package:security_access/domain/entities/vivienda.dart';

class FormularioUsuario extends StatelessWidget {
  const FormularioUsuario({
    required this.nombre,
    required this.correo,
    required this.telefono,
    required this.rol,
    required this.viviendaId,
    required this.viviendas,
    required this.correoBloqueado,
    required this.guardando,
    required this.textoBoton,
    required this.onRol,
    required this.onVivienda,
    required this.onGuardar,
    this.errorNombre,
    this.errorCorreo,
    this.errorTelefono,
    this.errorRol,
    this.errorVivienda,
    this.alCambiarNombre,
    this.alCambiarCorreo,
    this.alCambiarTelefono,
    super.key,
  });

  final TextEditingController nombre;
  final TextEditingController correo;
  final TextEditingController telefono;
  final RolUsuario? rol;
  final String? viviendaId;
  final List<Vivienda> viviendas;
  final bool correoBloqueado;
  final bool guardando;
  final String textoBoton;
  final ValueChanged<RolUsuario?> onRol;
  final ValueChanged<String?> onVivienda;
  final VoidCallback onGuardar;
  final String? errorNombre;
  final String? errorCorreo;
  final String? errorTelefono;
  final String? errorRol;
  final String? errorVivienda;
  final VoidCallback? alCambiarNombre;
  final VoidCallback? alCambiarCorreo;
  final VoidCallback? alCambiarTelefono;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final esResidente = rol == RolUsuario.residente;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          key: const Key('campo-nombre-usuario'),
          controller: nombre,
          textInputAction: TextInputAction.next,
          onChanged: (_) => alCambiarNombre?.call(),
          decoration: InputDecoration(
            labelText: 'Nombre completo *',
            errorText: errorNombre,
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          key: const Key('campo-correo-usuario'),
          controller: correo,
          enabled: !correoBloqueado,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          onChanged: (_) => alCambiarCorreo?.call(),
          decoration: InputDecoration(
            labelText: 'Correo electrónico *',
            errorText: errorCorreo,
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          key: const Key('campo-telefono-usuario'),
          controller: telefono,
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.next,
          onChanged: (_) => alCambiarTelefono?.call(),
          decoration: InputDecoration(
            labelText: 'Teléfono *',
            errorText: errorTelefono,
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<RolUsuario>(
          key: const Key('selector-rol'),
          initialValue: rol,
          decoration: InputDecoration(
            labelText: 'Rol *',
            errorText: errorRol,
            border: const OutlineInputBorder(),
          ),
          items: [
            for (final opcion in RolUsuario.values)
              DropdownMenuItem(value: opcion, child: Text(opcion.etiqueta)),
          ],
          onChanged: guardando ? null : onRol,
        ),
        if (esResidente) ...[
          const SizedBox(height: 16),
          KeyedSubtree(
            key: const Key('selector-vivienda'),
            child: DropdownButtonFormField<String>(
              key: ValueKey(
                'selector-vivienda-${viviendas.length}-${viviendaId ?? ''}',
              ),
              initialValue:
                  viviendas.any((vivienda) => vivienda.id == viviendaId)
                  ? viviendaId
                  : null,
              decoration: InputDecoration(
                labelText: 'Vivienda asignada *',
                errorText: errorVivienda,
                border: const OutlineInputBorder(),
              ),
              items: [
                for (final vivienda in viviendas)
                  DropdownMenuItem(
                    value: vivienda.id,
                    child: Text(vivienda.numero),
                  ),
              ],
              onChanged: guardando ? null : onVivienda,
            ),
          ),
          if (viviendas.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'No hay viviendas disponibles.',
                style: tema.textTheme.bodySmall,
              ),
            ),
        ],
        const SizedBox(height: 20),
        FilledButton(
          key: const Key('boton-guardar-usuario'),
          onPressed: guardando ? null : onGuardar,
          child: Text(textoBoton),
        ),
      ],
    );
  }
}
