import 'package:security_access/domain/entities/vivienda.dart';

sealed class ResultadoEditarVivienda {
  const ResultadoEditarVivienda();
}

class ViviendaActualizada extends ResultadoEditarVivienda {
  const ViviendaActualizada(this.vivienda);

  final Vivienda vivienda;
}

class EdicionRequiereConfirmacion extends ResultadoEditarVivienda {
  const EdicionRequiereConfirmacion();
}

class ViviendaEdicionNoEncontrada extends ResultadoEditarVivienda {
  const ViviendaEdicionNoEncontrada();
}

class DatosEdicionInvalidos extends ResultadoEditarVivienda {
  const DatosEdicionInvalidos();
}
