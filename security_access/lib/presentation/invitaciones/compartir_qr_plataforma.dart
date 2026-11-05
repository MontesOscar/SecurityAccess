import 'dart:typed_data';

import 'package:security_access/presentation/invitaciones/resultado_compartir_qr.dart';

Future<ResultadoCompartirQr> compartirPng({
  required Uint8List png,
  required String nombre,
  required String texto,
}) async {
  throw UnsupportedError(
    'Compartir la imagen del QR no está disponible en esta plataforma.',
  );
}
