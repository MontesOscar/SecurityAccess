import 'dart:js_interop';
import 'dart:typed_data';

import 'package:security_access/presentation/invitaciones/resultado_compartir_qr.dart';
import 'package:web/web.dart';

Future<ResultadoCompartirQr> compartirPng({
  required Uint8List png,
  required String nombre,
  required String texto,
}) async {
  final archivo = File(
    [png.buffer.toJS].toJS,
    nombre,
    FilePropertyBag()..type = 'image/png',
  );
  final datos = ShareData(
    files: [archivo].toJS,
    text: texto,
    title: 'Invitación de acceso',
  );
  final navegador = window.navigator;
  try {
    if (navegador.canShare(datos)) {
      await navegador.share(datos).toDart;
      return ResultadoCompartirQr.menu;
    }
    // ignore: invalid_runtime_check_with_js_interop_types
  } on DOMException catch (error) {
    if (error.name == 'AbortError') {
      return ResultadoCompartirQr.cancelado;
    }
  } catch (_) {
    // El navegador no ofrece el menú para archivos. Se descarga la imagen.
  }

  final enlace = document.createElement('a') as HTMLAnchorElement
    ..href = Uri.dataFromBytes(png, mimeType: 'image/png').toString()
    ..download = nombre
    ..style.display = 'none';
  document.body?.children.add(enlace);
  enlace.click();
  enlace.remove();
  return ResultadoCompartirQr.descarga;
}
