import 'package:flutter/material.dart';
import 'package:security_access/app/dependencias_app.dart';
import 'package:security_access/domain/entities/notificacion.dart';

class NotificacionesPage extends StatefulWidget {
  const NotificacionesPage({super.key});

  @override
  State<NotificacionesPage> createState() => _NotificacionesPageState();
}

class _NotificacionesPageState extends State<NotificacionesPage> {
  Future<List<Notificacion>>? _avisos;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_avisos != null) {
      return;
    }
    final dependencias = DependenciasApp.of(context);
    final residente = dependencias.session.usuario;
    _avisos = residente == null
        ? Future.value(const <Notificacion>[])
        : dependencias.consultarNotificaciones(residente);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const Key('pagina-notificaciones'),
      appBar: AppBar(title: const Text('Notificaciones')),
      body: FutureBuilder<List<Notificacion>>(
        future: _avisos ?? Future.value(const <Notificacion>[]),
        builder: (context, snapshot) {
          final avisos = snapshot.data ?? const <Notificacion>[];
          if (avisos.isEmpty) {
            return const Padding(
              padding: EdgeInsets.all(24),
              child: Text('Aún no hay notificaciones.'),
            );
          }
          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              for (final aviso in avisos)
                Card(
                  key: Key('notificacion-${aviso.id}'),
                  child: ListTile(
                    title: Text(aviso.tipo.etiqueta),
                    subtitle: Text(aviso.texto),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
