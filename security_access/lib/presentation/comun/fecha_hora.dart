DateTime? combinarFechaHora(String fecha, String hora) {
  final partesFecha = fecha.trim().split('/');
  final partesHora = hora.trim().split(':');
  if (partesFecha.length != 3 || partesHora.length != 2) {
    return null;
  }
  final dia = int.tryParse(partesFecha[0]);
  final mes = int.tryParse(partesFecha[1]);
  final anio = int.tryParse(partesFecha[2]);
  final horas = int.tryParse(partesHora[0]);
  final minutos = int.tryParse(partesHora[1]);
  if (dia == null ||
      mes == null ||
      anio == null ||
      horas == null ||
      minutos == null) {
    return null;
  }
  if (mes < 1 || mes > 12 || dia < 1 || horas > 23 || minutos > 59) {
    return null;
  }
  final resultado = DateTime(anio, mes, dia, horas, minutos);
  if (resultado.day != dia ||
      resultado.month != mes ||
      resultado.year != anio) {
    return null;
  }
  return resultado;
}

DateTime? leerFecha(String fecha) {
  return combinarFechaHora(fecha, '00:00');
}

String formatearFecha(DateTime valor) {
  final dia = valor.day.toString().padLeft(2, '0');
  final mes = valor.month.toString().padLeft(2, '0');
  return '$dia/$mes/${valor.year}';
}

String formatearHora(DateTime valor) {
  final hora = valor.hour.toString().padLeft(2, '0');
  final minuto = valor.minute.toString().padLeft(2, '0');
  return '$hora:$minuto';
}

String formatearFechaHora(DateTime valor) {
  return '${formatearFecha(valor)} ${formatearHora(valor)}';
}
