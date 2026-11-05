import 'package:flutter/material.dart';

void mostrarAviso(BuildContext context, String mensaje, {String? detalle}) {
  final messenger = ScaffoldMessenger.of(context);
  messenger.hideCurrentSnackBar();
  messenger.showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 4),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [Text(mensaje), if (detalle != null) Text(detalle)],
      ),
    ),
  );
}
