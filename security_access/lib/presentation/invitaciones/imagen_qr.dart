import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

Future<Uint8List> pngDelQr(String codigo) async {
  const lado = 720.0;
  final pintor = QrPainter(
    data: codigo,
    version: QrVersions.auto,
    gapless: true,
    eyeStyle: const QrEyeStyle(
      eyeShape: QrEyeShape.square,
      color: Color(0xFF000000),
    ),
    dataModuleStyle: const QrDataModuleStyle(
      dataModuleShape: QrDataModuleShape.square,
      color: Color(0xFF000000),
    ),
  );
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  canvas.drawRect(
    const Rect.fromLTWH(0, 0, lado, lado),
    Paint()..color = const Color(0xFFFFFFFF),
  );
  pintor.paint(canvas, const Size(lado, lado));
  final imagen = await recorder.endRecording().toImage(
    lado.toInt(),
    lado.toInt(),
  );
  final bytes = await imagen.toByteData(format: ui.ImageByteFormat.png);
  if (bytes == null) {
    throw StateError('No se pudo generar la imagen del QR.');
  }
  return bytes.buffer.asUint8List();
}
