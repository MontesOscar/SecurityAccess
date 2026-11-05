import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class EscanerQr extends StatefulWidget {
  const EscanerQr({required this.alLeer, super.key});

  final ValueChanged<String> alLeer;

  @override
  State<EscanerQr> createState() => _EscanerQrState();
}

class _EscanerQrState extends State<EscanerQr> {
  final MobileScannerController _controlador = MobileScannerController();
  var _leido = false;

  @override
  void dispose() {
    _controlador.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      key: const Key('zona-camara'),
      height: 280,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: MobileScanner(
          controller: _controlador,
          onDetect: (captura) {
            if (_leido || captura.barcodes.isEmpty) {
              return;
            }
            final codigo = captura.barcodes.first.rawValue;
            if (codigo == null || codigo.trim().isEmpty) {
              return;
            }
            _leido = true;
            widget.alLeer(codigo);
          },
          errorBuilder: (context, error) {
            final denegado =
                error.errorCode == MobileScannerErrorCode.permissionDenied;
            return ColoredBox(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: Text(
                    denegado
                        ? 'El permiso de cámara está denegado. Actívalo en la configuración del navegador o del teléfono y vuelve a intentar.'
                        : 'No se pudo abrir la cámara.',
                    key: const Key('mensaje-camara'),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
