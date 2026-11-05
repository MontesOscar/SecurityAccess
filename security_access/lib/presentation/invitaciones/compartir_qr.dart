import 'dart:typed_data';

import 'package:security_access/presentation/invitaciones/compartir_qr_plataforma.dart'
    if (dart.library.js_interop) 'package:security_access/presentation/invitaciones/compartir_qr_web.dart'
    as plataforma;
import 'package:security_access/presentation/invitaciones/imagen_qr.dart';
import 'package:security_access/presentation/invitaciones/resultado_compartir_qr.dart';

typedef CompartirQrPrueba = Future<ResultadoCompartirQr> Function(
  Uint8List png,
  String nombre,
  String texto,
);

CompartirQrPrueba? compartirQrParaPruebas;

Future<ResultadoCompartirQr> compartirImagenQr({
  required String codigo,
  required String texto,
}) async {
  final png = await pngDelQr(codigo);
  final nombre = 'qr-$codigo.png';
  final prueba = compartirQrParaPruebas;
  if (prueba != null) {
    return prueba(png, nombre, texto);
  }
  return plataforma.compartirPng(png: png, nombre: nombre, texto: texto);
}
