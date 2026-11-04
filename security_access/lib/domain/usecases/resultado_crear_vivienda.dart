import 'package:security_access/domain/entities/vivienda.dart';

sealed class ResultadoCrearVivienda {
  const ResultadoCrearVivienda();
}

class ViviendaCreada extends ResultadoCrearVivienda {
  const ViviendaCreada(this.vivienda);

  final Vivienda vivienda;
}

class ViviendaYaRegistrada extends ResultadoCrearVivienda {
  const ViviendaYaRegistrada();
}

class DatosViviendaInvalidos extends ResultadoCrearVivienda {
  const DatosViviendaInvalidos();
}
