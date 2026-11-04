import 'package:security_access/domain/entities/vivienda.dart';

sealed class ResultadoCambioEstadoVivienda {
  const ResultadoCambioEstadoVivienda();
}

class EstadoViviendaActualizado extends ResultadoCambioEstadoVivienda {
  const EstadoViviendaActualizado(this.vivienda);

  final Vivienda vivienda;
}

class ViviendaEstadoNoEncontrada extends ResultadoCambioEstadoVivienda {
  const ViviendaEstadoNoEncontrada();
}
