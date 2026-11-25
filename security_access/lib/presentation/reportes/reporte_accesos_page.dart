import 'package:flutter/material.dart';
import 'package:security_access/app/dependencias_app.dart';
import 'package:security_access/domain/entities/estado_visita.dart';
import 'package:security_access/domain/entities/fila_reporte_acceso.dart';
import 'package:security_access/domain/usecases/consultar_reporte_accesos.dart';
import 'package:security_access/presentation/comun/fecha_hora.dart';
import 'package:security_access/presentation/comun/mostrar_aviso.dart';

class ReporteAccesosPage extends StatefulWidget {
  const ReporteAccesosPage({super.key});

  @override
  State<ReporteAccesosPage> createState() => _ReporteAccesosPageState();
}

class _ReporteAccesosPageState extends State<ReporteAccesosPage> {
  final _vivienda = TextEditingController();
  final _desde = TextEditingController();
  final _hasta = TextEditingController();
  String? _estado;
  var _inicio = false;
  var _filas = const <FilaReporteAcceso>[];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_inicio) {
      return;
    }
    _inicio = true;
    _cargar();
  }

  @override
  void dispose() {
    _vivienda.dispose();
    _desde.dispose();
    _hasta.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const Key('pagina-reporte'),
      appBar: AppBar(title: const Text('Reporte de accesos')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          TextField(
            key: const Key('campo-vivienda-reporte'),
            controller: _vivienda,
            decoration: const InputDecoration(
              labelText: 'Vivienda',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            key: const Key('campo-desde-reporte'),
            controller: _desde,
            decoration: const InputDecoration(
              labelText: 'Desde (dd/MM/aaaa)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            key: const Key('campo-hasta-reporte'),
            controller: _hasta,
            decoration: const InputDecoration(
              labelText: 'Hasta (dd/MM/aaaa)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String?>(
            key: ValueKey('estado-${_estado ?? 'todos'}'),
            initialValue: _estado,
            decoration: const InputDecoration(
              labelText: 'Estado',
              border: OutlineInputBorder(),
            ),
            items: [
              const DropdownMenuItem(value: null, child: Text('Todos')),
              DropdownMenuItem(
                value: EstadoVisita.dentro.etiqueta,
                child: Text(EstadoVisita.dentro.etiqueta),
              ),
              DropdownMenuItem(
                value: EstadoVisita.completada.etiqueta,
                child: Text(EstadoVisita.completada.etiqueta),
              ),
              const DropdownMenuItem(
                value: ConsultarReporteAccesos.estadoRechazado,
                child: Text(ConsultarReporteAccesos.estadoRechazado),
              ),
            ],
            onChanged: (valor) => setState(() => _estado = valor),
          ),
          const SizedBox(height: 12),
          FilledButton(
            key: const Key('boton-filtrar-reporte'),
            onPressed: _cargar,
            child: const Text('Filtrar'),
          ),
          const SizedBox(height: 16),
          if (_filas.isEmpty)
            const Text('No hay accesos para mostrar.')
          else
            for (final fila in _filas) _TarjetaReporte(fila: fila),
        ],
      ),
    );
  }

  Future<void> _cargar() async {
    final desde = _fecha(_desde.text);
    final hasta = _fecha(_hasta.text);
    if ((_desde.text.trim().isNotEmpty && desde == null) ||
        (_hasta.text.trim().isNotEmpty && hasta == null)) {
      if (mounted) {
        mostrarAviso(context, 'La fecha no es válida');
      }
      return;
    }
    final filas = await DependenciasApp.of(context).consultarReporteAccesos(
      desde: desde,
      hasta: hasta,
      vivienda: _vivienda.text,
      estado: _estado,
    );
    if (!mounted) {
      return;
    }
    setState(() => _filas = filas);
  }

  DateTime? _fecha(String texto) {
    if (texto.trim().isEmpty) {
      return null;
    }
    return leerFecha(texto);
  }
}

class _TarjetaReporte extends StatelessWidget {
  const _TarjetaReporte({required this.fila});

  final FilaReporteAcceso fila;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final entrada = fila.entrada == null
        ? 'Sin entrada'
        : formatearFechaHora(fila.entrada!);
    final salida = fila.salida == null
        ? 'Sin salida'
        : formatearFechaHora(fila.salida!);
    return Card(
      key: Key('fila-reporte-${fila.id}'),
      child: ListTile(
        title: Text('${fila.visitante} · Vivienda ${fila.viviendaNumero}'),
        subtitle: Text(
          'Entrada: $entrada\nSalida: $salida\n'
          'Guardia: ${fila.guardia}\n'
          '${fila.identificacion.isEmpty ? '' : 'Identificación: ${fila.identificacion}\n'}'
          'Estado: ${fila.estado}',
        ),
        isThreeLine: true,
        trailing: fila.sinSalida
            ? Text(
                'Sin salida',
                key: Key('marca-sin-salida-${fila.id}'),
                style: tema.textTheme.labelLarge?.copyWith(
                  color: tema.colorScheme.error,
                ),
              )
            : null,
      ),
    );
  }
}
